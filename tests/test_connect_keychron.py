#!/usr/bin/env python3
"""Exercise reconnection and pairing without accessing Bluetooth hardware."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
TEST_ADDRESS = "02:00:00:00:00:01"


class KeychronTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="test-keychron-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.state_path = self.root / "state.json"
        self.log = self.root / "calls"
        self.state = {"Powered": "yes", "Pairable": "no", "Paired": "yes",
                      "Bonded": "yes", "Trusted": "yes", "Connected": "no", "Blocked": "no"}
        self.save_state()
        stub = self.root / "bluetoothctl"
        stub.write_text("""#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
while args and args[0].startswith('--'):
    args = args[2:]
command = args[0]
with open(os.environ['BT_LOG'], 'a') as log:
    log.write(' '.join(args) + '\\n')
state_path = pathlib.Path(os.environ['BT_STATE'])
state = json.loads(state_path.read_text())
if os.environ.get('BT_FAIL') == command:
    print('Failed', file=sys.stderr)
    sys.exit(1)
if command == 'show':
    print('Controller 02:00:00:00:00:99 (public)')
    for key in ('Powered', 'Pairable'):
        print(f'    {key}: {state[key]}')
elif command == 'devices':
    print('Device 02:00:00:00:00:01 Keychron K3 Pro')
    if os.environ.get('BT_MULTIPLE'):
        print('Device 02:00:00:00:00:02 Keychron K2')
elif command == 'info':
    print(f'Device {args[1]} (public)')
    for key in ('Paired', 'Bonded', 'Trusted', 'Connected', 'Blocked'):
        print(f'    {key}: {state[key]}')
elif command == 'power':
    state['Powered'] = 'yes' if args[1] == 'on' else 'no'
elif command == 'pairable':
    state['Pairable'] = 'yes' if args[1] == 'on' else 'no'
elif command == 'pair':
    state['Paired'] = state['Bonded'] = 'yes'
elif command == 'trust' and not os.environ.get('BT_FALSE_TRUST'):
    state['Trusted'] = 'yes'
elif command == 'connect' and not os.environ.get('BT_FALSE_SUCCESS'):
    state['Connected'] = 'yes'
state_path.write_text(json.dumps(state))
""")
        stub.chmod(0o755)
        self.env = dict(os.environ, PATH=f"{self.root}:/usr/bin:/bin",
                        BT_STATE=str(self.state_path), BT_LOG=str(self.log))
        self.env.pop("KEYCHRON_BT_MAC", None)

    def save_state(self):
        self.state_path.write_text(json.dumps(self.state))

    def run_helper(self, *args, **env):
        return subprocess.run(
            ["bash", str(REPO / "bin/connect-keychron.sh"), *args],
            env=dict(self.env, **env), text=True, capture_output=True,
        )

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_reconnects_without_pairing(self):
        result = self.run_helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"connect {TEST_ADDRESS}", self.calls())
        self.assertFalse(any(call.startswith("pair ") for call in self.calls()))

    def test_missing_bond_is_not_treated_as_a_connection(self):
        self.state["Bonded"] = "no"
        self.save_state()
        result = self.run_helper()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--pair", result.stderr)
        self.assertFalse(any(call.startswith("connect ") for call in self.calls()))

    def test_status_is_read_only_even_with_power_off(self):
        self.state["Powered"] = "no"
        self.save_state()
        result = self.run_helper("--status")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), ["show", "devices", f"info {TEST_ADDRESS}"])
        self.assertEqual(json.loads(self.state_path.read_text()), self.state)

    def test_pairs_trusts_connects_and_restores_pairable(self):
        self.state.update(Paired="no", Bonded="no", Trusted="no")
        self.save_state()
        result = self.run_helper("--pair")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"pair {TEST_ADDRESS}", self.calls())
        self.assertIn(f"trust {TEST_ADDRESS}", self.calls())
        self.assertEqual(self.calls()[-1], "pairable no")
        state = json.loads(self.state_path.read_text())
        for key in ("Paired", "Bonded", "Trusted", "Connected"):
            self.assertEqual(state[key], "yes")
        self.assertEqual(state["Pairable"], "no")

    def test_pair_failure_also_restores_pairable(self):
        self.state.update(Paired="no", Bonded="no")
        self.save_state()
        result = self.run_helper("--pair", BT_FAIL="pair")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.calls()[-1], "pairable no")
        self.assertFalse(any(call.startswith("connect ") for call in self.calls()))

    def test_healthy_pairing_is_not_replaced(self):
        result = self.run_helper("--pair")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(call.startswith("pair ") for call in self.calls()))

    def test_successful_exit_without_connection_is_rejected(self):
        result = self.run_helper(BT_FALSE_SUCCESS="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("still disconnected", result.stderr)
        self.assertNotIn("Keychron connected", result.stdout)

    def test_successful_exit_without_trust_is_rejected(self):
        self.state["Trusted"] = "no"
        self.save_state()
        result = self.run_helper(BT_FALSE_TRUST="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Trusted", result.stderr)

    def test_multiple_keyboards_require_explicit_selection(self):
        result = self.run_helper(BT_MULTIPLE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--mac", result.stderr)
        result = self.run_helper("--mac", TEST_ADDRESS, BT_MULTIPLE="1")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_mac_is_rejected_before_bluetooth_access(self):
        result = self.run_helper("--mac", "not-an-address")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.calls(), [])


if __name__ == "__main__":
    unittest.main()
