#!/usr/bin/env python3
"""Run without network or root: python3 -m unittest discover -s tests -v."""

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


def executable(path, content):
    path.write_text(content)
    path.chmod(0o755)


@unittest.skipUnless(shutil.which("dpkg-deb") and shutil.which("jq"), "requires dpkg-deb and jq")
class GhosttyUpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="test-ghostty-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls"
        self.state = self.root / "installed"
        self.state.write_text("1.3.1-6~trixie")
        self.release = self.root / "release.json"
        self.archive = self.root / "ghostty.deb"
        self.suite = subprocess.check_output(
            ["bash", "-c", '. /etc/os-release; printf "%s" "$VERSION_CODENAME"'], text=True
        )
        self.version = f"1.4.0-2~{self.suite}"
        package = self.root / "package"
        (package / "DEBIAN").mkdir(parents=True)
        (package / "DEBIAN/control").write_text(
            f"Package: ghostty\nVersion: {self.version}\nArchitecture: amd64\n"
            "Maintainer: Test <test@example.invalid>\nDescription: Test fixture\n"
        )
        subprocess.run(
            ["dpkg-deb", "--root-owner-group", "--build", str(package), str(self.archive)],
            check=True, stdout=subprocess.DEVNULL,
        )
        self.asset = {
            "name": f"ghostty_1.4.0-2.{self.suite}_amd64.deb",
            "browser_download_url": "https://github.com/dariogriffo/ghostty-debian/releases/download/test/ghostty.deb",
            "digest": "sha256:" + hashlib.sha256(self.archive.read_bytes()).hexdigest(),
        }
        self.write_release()
        shutil.copyfile(REPO / "bin/update-ghostty.sh", self.bin / "update-ghostty")
        executable(self.bin / "protect-neovim-appimage.sh", '#!/bin/sh\necho prepare >> "$CALL_LOG"\n')
        executable(self.bin / "curl", """#!/usr/bin/env python3
import os, pathlib, sys
args = sys.argv[1:]
is_api = any(arg.startswith('https://api.github.com/') for arg in args)
with open(os.environ['CALL_LOG'], 'a') as log:
    log.write(('api' if is_api else 'download') + '\\n')
if os.environ.get('FAIL_CURL') == ('api' if is_api else 'download'):
    sys.exit(22)
data = pathlib.Path(os.environ['RELEASE_JSON'] if is_api else os.environ['ARCHIVE']).read_bytes()
if '-o' in args:
    pathlib.Path(args[args.index('-o') + 1]).write_bytes(data)
else:
    sys.stdout.buffer.write(data)
""")
        executable(self.bin / "dpkg", """#!/bin/sh
if [ "$1" = --print-architecture ]; then
    echo "${TEST_ARCH:-amd64}"
else
    exec /usr/bin/dpkg "$@"
fi
""")
        executable(self.bin / "dpkg-query", """#!/usr/bin/env python3
import os, pathlib, sys
state = pathlib.Path(os.environ['INSTALLED_STATE'])
if not state.exists():
    sys.exit(1)
print('install ok installed' if 'Status' in sys.argv[2] else state.read_text(), end='')
""")
        executable(self.bin / "apt-get", """#!/usr/bin/env python3
import os, pathlib, sys
with open(os.environ['CALL_LOG'], 'a') as log:
    log.write('install ' + ' '.join(sys.argv[1:]) + '\\n')
status = int(os.environ.get('FAIL_APT', '0'))
if status:
    sys.exit(status)
pathlib.Path(os.environ['INSTALLED_STATE']).write_text(os.environ['TEST_VERSION'])
""")
        executable(self.bin / "sudo", '#!/bin/sh\nexec "$@"\n')
        self.env = dict(os.environ, PATH=f"{self.bin}:/usr/bin:/bin",
                        CALL_LOG=str(self.log), INSTALLED_STATE=str(self.state),
                        RELEASE_JSON=str(self.release), ARCHIVE=str(self.archive),
                        TEST_VERSION=self.version)

    def write_release(self, assets=None):
        self.release.write_text(json.dumps({"assets": assets if assets is not None else [self.asset]}))

    def run_updater(self, *args, **env):
        return subprocess.run(
            ["bash", str(self.bin / "update-ghostty"), *args],
            env=dict(self.env, **env), text=True, capture_output=True,
        )

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def assert_no_install(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertFalse(any(call.startswith("install ") for call in self.calls()))
        self.assertEqual(self.state.read_text(), "1.3.1-6~trixie")

    def test_check_does_not_prepare_download_or_install(self):
        result = self.run_updater("--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(self.version, result.stdout)
        self.assertEqual(self.calls(), ["api"])

    def test_selects_only_matching_terminal_package(self):
        others = [dict(self.asset, name=name) for name in (
            f"ghostty-dbgsym_1.4.0-2.{self.suite}_amd64.deb",
            f"libghostty-vt0_1.4.0-2.{self.suite}_amd64.deb",
            f"ghostty_1.4.0-2.{self.suite}_arm64.deb",
            "ghostty_1.4.0-2.wrongrelease_amd64.deb",
        )]
        self.write_release([*others, self.asset])
        result = self.run_updater("--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.state.read_text(), self.version)
        self.assertTrue(any("--no-remove -y" in call for call in self.calls()))

    def test_tilde_style_asset_names(self):
        self.asset["name"] = f"ghostty_{self.version}_amd64.deb"
        self.write_release()
        result = self.run_updater("--yes")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_or_ambiguous_package_never_falls_back(self):
        for assets in ([], [self.asset, self.asset]):
            with self.subTest(assets=len(assets)):
                self.write_release(assets)
                self.assert_no_install(self.run_updater("--yes"))

    def test_unsupported_architecture_is_rejected(self):
        self.assert_no_install(self.run_updater("--yes", TEST_ARCH="i386"))
        self.assertEqual(self.calls(), [])

    def test_download_and_api_failures_preserve_installation(self):
        for stage in ("api", "download"):
            with self.subTest(stage=stage):
                self.assert_no_install(self.run_updater("--yes", FAIL_CURL=stage))

    def test_checksum_mismatch_is_rejected(self):
        self.asset["digest"] = "sha256:" + "0" * 64
        self.write_release()
        self.assert_no_install(self.run_updater("--yes"))

    def test_missing_digest_is_rejected(self):
        del self.asset["digest"]
        self.write_release()
        self.assert_no_install(self.run_updater("--yes"))

    def test_embedded_version_is_checked(self):
        self.asset["name"] = f"ghostty_1.4.0-3.{self.suite}_amd64.deb"
        self.write_release()
        self.assert_no_install(self.run_updater("--yes"))

    def test_apt_failure_is_reported(self):
        result = self.run_updater("--yes", FAIL_APT="42")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("APT installation failed", result.stderr)
        self.assertNotIn("installed successfully", result.stdout)
        self.assertEqual(self.state.read_text(), "1.3.1-6~trixie")

    def test_current_installation_is_not_downloaded_again(self):
        self.state.write_text(self.version)
        result = self.run_updater("--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), ["api", "prepare"])

    def test_install_missing_requires_explicit_flag(self):
        self.state.unlink()
        result = self.run_updater("--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [])
        result = self.run_updater("--install", "--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.state.read_text(), self.version)


class RepositoryMigrationTests(unittest.TestCase):
    def test_migration_preserves_backups_and_is_idempotent(self):
        with tempfile.TemporaryDirectory(prefix="test-griffo-migration-") as directory:
            root = Path(directory)
            apt = root / "apt"
            preferences = apt / "preferences.d"
            sources = apt / "sources.list.d"
            preferences.mkdir(parents=True)
            sources.mkdir()
            pin = preferences / "99-griffo-ghostty-only"
            pin.write_text("Package: ghostty\nPin: origin debian.griffo.io\nPin-Priority: 990\n")
            (preferences / "99-neovim-appimage").write_text("old pin\n")
            legacy = sources / "debian.griffo.io.list"
            legacy.write_text("deb https://debian.griffo.io/apt trixie main\n")
            prior_backup = sources / "debian.griffo.io.list.disabled"
            prior_backup.write_text("previous backup\n")
            (sources / "deb.griffo.io.sources").write_text("URIs: https://deb.griffo.io/apt\n")
            free = sources / "deb-free.griffo.io.list"
            free.write_text("deb https://deb-free.griffo.io/apt trixie main\n")
            executable(root / "sudo", '#!/bin/sh\nexec "$@"\n')
            # Redirect the real migration's fixed system paths into this fixture.
            script = (REPO / "bin/protect-neovim-appimage.sh").read_text().replace(
                "/etc/apt/", str(apt) + "/"
            )
            env = dict(os.environ, PATH=f"{root}:/usr/bin:/bin")
            first = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
            self.assertEqual(first.returncode, 0, first.stderr)
            self.assertFalse(legacy.exists())
            self.assertFalse((sources / "deb.griffo.io.sources").exists())
            self.assertEqual(prior_backup.read_text(), "previous backup\n")
            self.assertEqual(len(list(sources.glob("debian.griffo.io.list.*.disabled"))), 1)
            self.assertTrue(free.exists())
            self.assertNotIn("990", pin.read_text())
            self.assertIn("Pin: origin deb.griffo.io", pin.read_text())
            second = subprocess.run(["bash"], input=script, env=env, text=True, capture_output=True)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertNotIn("Updated APT policy", second.stdout)
            self.assertNotIn("Disabled ", second.stdout)


class AaaFailureHandlingTests(unittest.TestCase):
    def test_stops_at_each_failed_stage_even_in_conditional(self):
        stages = ["prepare", "update", "upgrade", "update-ghostty", "update-nvim",
                  "update-github-desktop", "autoremove", "clean"]
        with tempfile.TemporaryDirectory(prefix="test-aaa-") as directory:
            root = Path(directory)
            stub = root / "stub"
            executable(stub, """#!/bin/bash
name="${0##*/}"
if [ "$name" = sudo ]; then
    stage="$2"
elif [ "$name" = update-ghostty ] && [ "${1-}" = --prepare ]; then
    stage=prepare
else
    stage="$name"
fi
printf '%s\\n' "$stage" >> "$CALL_LOG"
if [ "$stage" = "$FAIL_STAGE" ]; then exit 23; fi
""")
            for name in ("sudo", "nala", "update-ghostty", "update-nvim", "update-github-desktop"):
                (root / name).symlink_to(stub)
            log = root / "calls"
            for fail in [*stages, "none"]:
                with self.subTest(stage=fail):
                    log.write_text("")
                    result = subprocess.run(
                        ["bash", "--noprofile", "--norc", "-c",
                         'source "$1"; if aaa; then exit 0; else exit $?; fi',
                         "test-aaa", str(REPO / "home/bash_aliases")],
                        env=dict(os.environ, PATH=f"{root}:/usr/bin:/bin",
                                 CALL_LOG=str(log), FAIL_STAGE=fail),
                        capture_output=True, text=True,
                    )
                    expected = stages if fail == "none" else stages[:stages.index(fail) + 1]
                    self.assertEqual(log.read_text().splitlines(), expected)
                    self.assertEqual(result.returncode, 0 if fail == "none" else 23)
                    if fail != "none":
                        self.assertIn("Stopping", result.stderr)
                        self.assertNotIn("completed successfully", result.stdout)


if __name__ == "__main__":
    unittest.main()
