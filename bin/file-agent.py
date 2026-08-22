#!/usr/bin/env python3
"""Local Ollama-backed file management agent.

The model is only the planner. Actual filesystem access is constrained to a
single root directory and implemented through a small set of safe local tools.
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen


DEFAULT_MODEL = os.environ.get("FILE_AGENT_MODEL", "qwen2.5-coder:1.5b")
DEFAULT_OLLAMA_URL = os.environ.get("OLLAMA_HOST", "http://127.0.0.1:11434")
DEFAULT_MAX_STEPS_ENV = os.environ.get("FILE_AGENT_MAX_STEPS")
DEFAULT_NUM_PREDICT = int(os.environ.get("FILE_AGENT_NUM_PREDICT", "256"))
BIN_DIR = Path(__file__).resolve().parent
MODE_DEFAULT_MAX_STEPS = {
    "plan": 3,
    "organize": 4,
    "apply": 6,
}


class AgentError(Exception):
    """Raised for user-facing tool failures."""


@dataclass
class AgentContext:
    root: Path
    apply_changes: bool
    verbose: bool

    def resolve_path(self, raw_path: str, must_exist: bool = True) -> Path:
        candidate = Path(raw_path).expanduser()
        if not candidate.is_absolute():
            candidate = self.root / candidate
        candidate = candidate.resolve(strict=False)

        try:
            candidate.relative_to(self.root)
        except ValueError as exc:
            raise AgentError(
                f"path escapes allowed root: {candidate} (root: {self.root})"
            ) from exc

        if must_exist and not candidate.exists():
            raise AgentError(f"path does not exist: {candidate}")
        return candidate

    def display_path(self, path: Path) -> str:
        try:
            rel = path.relative_to(self.root)
        except ValueError:
            return str(path)
        return "." if str(rel) == "." else str(rel)


def usage_examples() -> str:
    return """Examples:
  file-agent plan ~/Downloads
  file-agent plan ~/Downloads "Find duplicates and suggest a cleanup plan"
  file-agent organize ~/Downloads
  file-agent organize ~/Downloads --confirm
  file-agent apply ~/Downloads --confirm "Normalize file names and sort mixed files"
  file-agent apply /media/$USER/ExternalDrive --confirm "Move archives into an archives folder and trash obvious duplicates"
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="file-agent",
        description=(
            "Use a local Ollama model as a planning agent for managing files "
            "inside one chosen root directory."
        ),
        epilog=usage_examples(),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "mode",
        choices=("plan", "organize", "apply"),
        help="plan only, organize with the default cleanup prompt, or apply a custom instruction",
    )
    parser.add_argument(
        "root",
        help="allowed root directory; all file operations stay inside this path",
    )
    parser.add_argument(
        "instruction",
        nargs="*",
        help="optional instruction for the model",
    )
    parser.add_argument(
        "--confirm",
        action="store_true",
        help="allow write operations; without this, action tools stay in dry-run mode",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"Ollama model to use (default: {DEFAULT_MODEL})",
    )
    parser.add_argument(
        "--ollama-url",
        default=DEFAULT_OLLAMA_URL,
        help=f"Ollama API base URL (default: {DEFAULT_OLLAMA_URL})",
    )
    parser.add_argument(
        "--max-steps",
        type=int,
        default=None,
        help=(
            "maximum tool-calling rounds "
            "(default: auto; plan=3, organize=4, apply=6, or FILE_AGENT_MAX_STEPS)"
        ),
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="print tool calls as they happen",
    )
    return parser.parse_args()


def build_user_instruction(args: argparse.Namespace) -> str:
    custom = " ".join(args.instruction).strip()
    if custom:
        return custom
    if args.mode == "plan":
        return (
            "Analyze this directory and propose a practical cleanup and "
            "organization plan. Focus on duplicates, messy names, obvious "
            "category folders, and safe next steps."
        )
    if args.mode == "organize":
        return (
            "Organize this directory in a practical, conservative way. Prefer "
            "using normalize_names and sort_library where they fit. Avoid risky "
            "or destructive changes unless they are clearly justified."
        )
    return (
        "Carry out a careful file-management task inside this directory. Use "
        "the available tools conservatively and explain what you changed."
    )


def tool_schema(name: str, description: str, properties: dict[str, Any], required: list[str] | None = None) -> dict[str, Any]:
    return {
        "type": "function",
        "function": {
            "name": name,
            "description": description,
            "parameters": {
                "type": "object",
                "properties": properties,
                "required": required or [],
            },
        },
    }


TOOLS: list[dict[str, Any]] = [
    tool_schema(
        "list_dir",
        "List files and folders under a path inside the allowed root.",
        {
            "path": {"type": "string", "description": "Directory path relative to the allowed root, e.g. '.' or 'Downloads'"},
            "recursive": {"type": "boolean", "description": "Whether to walk recursively"},
            "limit": {"type": "integer", "description": "Maximum number of entries to return"},
            "include_hidden": {"type": "boolean", "description": "Whether to include dotfiles and hidden directories"},
        },
    ),
    tool_schema(
        "search_files",
        "Search for files or folders by name inside the allowed root.",
        {
            "pattern": {"type": "string", "description": "Case-insensitive substring or regular expression"},
            "path": {"type": "string", "description": "Starting path relative to the allowed root"},
            "limit": {"type": "integer", "description": "Maximum number of matches"},
            "use_regex": {"type": "boolean", "description": "Interpret pattern as a regular expression"},
            "include_hidden": {"type": "boolean", "description": "Whether to include dotfiles and hidden directories"},
        },
        required=["pattern"],
    ),
    tool_schema(
        "file_info",
        "Inspect a file or directory inside the allowed root.",
        {
            "path": {"type": "string", "description": "Path relative to the allowed root"},
        },
        required=["path"],
    ),
    tool_schema(
        "read_text_file",
        "Read a text file inside the allowed root.",
        {
            "path": {"type": "string", "description": "File path relative to the allowed root"},
            "max_chars": {"type": "integer", "description": "Maximum number of characters to return"},
        },
        required=["path"],
    ),
    tool_schema(
        "normalize_names",
        "Normalize file and folder names into a POSIX-friendly style using the existing helper script.",
        {
            "path": {"type": "string", "description": "Target directory relative to the allowed root"},
            "mode": {"type": "string", "description": "One of: all, files, folders"},
        },
    ),
    tool_schema(
        "sort_library",
        "Sort a mixed library folder into categories using the existing helper script.",
        {
            "source": {"type": "string", "description": "Source directory relative to the allowed root"},
            "destination": {"type": "string", "description": "Destination directory relative to the allowed root; defaults to source"},
            "recursive": {"type": "boolean", "description": "Whether to scan recursively"},
            "copy": {"type": "boolean", "description": "Copy instead of move when supported"},
        },
    ),
    tool_schema(
        "safe_copy",
        "Copy files or directories safely and resumably using the existing rsync helper.",
        {
            "source": {
                "type": "array",
                "items": {"type": "string"},
                "description": "One or more source paths relative to the allowed root",
            },
            "destination": {"type": "string", "description": "Destination path relative to the allowed root"},
            "verify": {"type": "boolean", "description": "Run checksum verification after copying"},
            "ignore_existing": {"type": "boolean", "description": "Skip destination files that already exist"},
        },
        required=["source", "destination"],
    ),
    tool_schema(
        "make_directory",
        "Create a directory inside the allowed root.",
        {
            "path": {"type": "string", "description": "Directory path relative to the allowed root"},
        },
        required=["path"],
    ),
    tool_schema(
        "move_path",
        "Move or rename a file or folder inside the allowed root without overwriting an existing target.",
        {
            "source": {"type": "string", "description": "Existing source path relative to the allowed root"},
            "destination": {"type": "string", "description": "Target path relative to the allowed root"},
        },
        required=["source", "destination"],
    ),
    tool_schema(
        "trash_path",
        "Send a file or folder to the desktop trash instead of deleting it permanently.",
        {
            "path": {"type": "string", "description": "Path relative to the allowed root"},
        },
        required=["path"],
    ),
]


def is_hidden(path: Path) -> bool:
    return any(part.startswith(".") for part in path.parts if part not in (".", ".."))


def format_stat(path: Path) -> dict[str, Any]:
    stat = path.stat()
    return {
        "path": str(path),
        "type": "directory" if path.is_dir() else "file" if path.is_file() else "other",
        "size": stat.st_size,
        "mtime": datetime.fromtimestamp(stat.st_mtime).isoformat(timespec="seconds"),
    }


def tool_list_dir(ctx: AgentContext, path: str = ".", recursive: bool = False, limit: int = 200, include_hidden: bool = False) -> dict[str, Any]:
    target = ctx.resolve_path(path)
    if not target.is_dir():
        raise AgentError(f"not a directory: {target}")

    entries: list[dict[str, Any]] = []
    truncated = False

    def maybe_add(candidate: Path) -> None:
        nonlocal truncated
        if len(entries) >= limit:
            truncated = True
            return
        if not include_hidden and is_hidden(candidate.relative_to(ctx.root)):
            return
        item = format_stat(candidate)
        item["relative_path"] = ctx.display_path(candidate)
        entries.append(item)

    if recursive:
        for candidate in sorted(target.rglob("*")):
            maybe_add(candidate)
            if truncated:
                break
    else:
        for candidate in sorted(target.iterdir()):
            maybe_add(candidate)
            if truncated:
                break

    return {
        "root": str(ctx.root),
        "path": ctx.display_path(target),
        "recursive": recursive,
        "count": len(entries),
        "truncated": truncated,
        "entries": entries,
    }


def tool_search_files(
    ctx: AgentContext,
    pattern: str,
    path: str = ".",
    limit: int = 200,
    use_regex: bool = False,
    include_hidden: bool = False,
) -> dict[str, Any]:
    target = ctx.resolve_path(path)
    if not target.is_dir():
        raise AgentError(f"not a directory: {target}")

    matcher: Any
    if use_regex:
        regex = re.compile(pattern, re.IGNORECASE)
        matcher = lambda text: bool(regex.search(text))
    else:
        needle = pattern.casefold()
        matcher = lambda text: needle in text.casefold()

    matches: list[str] = []
    for candidate in sorted(target.rglob("*")):
        rel = candidate.relative_to(ctx.root)
        if not include_hidden and is_hidden(rel):
            continue
        rel_text = str(rel)
        if matcher(rel_text):
            matches.append(rel_text)
            if len(matches) >= limit:
                break

    return {
        "path": ctx.display_path(target),
        "pattern": pattern,
        "use_regex": use_regex,
        "count": len(matches),
        "matches": matches,
    }


def tool_file_info(ctx: AgentContext, path: str) -> dict[str, Any]:
    target = ctx.resolve_path(path)
    info = format_stat(target)
    info["relative_path"] = ctx.display_path(target)
    info["mime_type"] = mimetypes.guess_type(str(target))[0]

    if target.is_dir():
        children = list(target.iterdir())
        info["children"] = len(children)
        info["sample_children"] = [ctx.display_path(p) for p in sorted(children)[:20]]
    elif target.is_file():
        with target.open("rb") as handle:
            prefix = handle.read(512)
        info["binary_like"] = b"\x00" in prefix
    return info


def tool_read_text_file(ctx: AgentContext, path: str, max_chars: int = 8000) -> dict[str, Any]:
    target = ctx.resolve_path(path)
    if not target.is_file():
        raise AgentError(f"not a file: {target}")

    with target.open("rb") as handle:
        prefix = handle.read(1024)
    if b"\x00" in prefix:
        raise AgentError(f"refusing to read binary-looking file as text: {target}")

    text = target.read_text(encoding="utf-8", errors="replace")
    truncated = len(text) > max_chars
    if truncated:
        text = text[:max_chars]

    return {
        "path": ctx.display_path(target),
        "truncated": truncated,
        "content": text,
    }


def run_local_script(argv: list[str]) -> dict[str, Any]:
    proc = subprocess.run(argv, capture_output=True, text=True, check=False)
    return {
        "command": " ".join(shlex_quote(part) for part in argv),
        "exit_code": proc.returncode,
        "stdout": proc.stdout.strip(),
        "stderr": proc.stderr.strip(),
    }


def shlex_quote(text: str) -> str:
    return subprocess.list2cmdline([text]) if os.name == "nt" else "'" + text.replace("'", "'\"'\"'") + "'"


def clean_terminal_artifacts(text: str) -> str:
    text = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", text)
    text = re.sub(r".\x08", "", text)
    return text.strip()


def tool_normalize_names(ctx: AgentContext, path: str = ".", mode: str = "all") -> dict[str, Any]:
    target = ctx.resolve_path(path)
    if not target.is_dir():
        raise AgentError(f"not a directory: {target}")

    cmd = [str(BIN_DIR / "normalize-filenames.sh")]
    if ctx.apply_changes:
        cmd.append("--apply")
    if mode == "files":
        cmd.append("--files-only")
    elif mode == "folders":
        cmd.append("--folders-only")
    elif mode != "all":
        raise AgentError("mode must be one of: all, files, folders")
    cmd.append(str(target))
    return run_local_script(cmd)


def tool_sort_library(
    ctx: AgentContext,
    source: str = ".",
    destination: str | None = None,
    recursive: bool = True,
    copy: bool = False,
) -> dict[str, Any]:
    src = ctx.resolve_path(source)
    if not src.is_dir():
        raise AgentError(f"not a directory: {src}")
    dst = ctx.resolve_path(destination or source, must_exist=False)

    cmd = [str(BIN_DIR / "sort-library.sh"), "--source", str(src), "--dest", str(dst)]
    if ctx.apply_changes:
        cmd.append("--apply")
    if recursive:
        cmd.append("--recursive")
    if copy:
        cmd.append("--copy")
    return run_local_script(cmd)


def tool_safe_copy(
    ctx: AgentContext,
    source: list[str],
    destination: str,
    verify: bool = False,
    ignore_existing: bool = False,
) -> dict[str, Any]:
    if not source:
        raise AgentError("at least one source path is required")
    sources = [ctx.resolve_path(item) for item in source]
    dest = ctx.resolve_path(destination, must_exist=False)

    cmd = [str(BIN_DIR / "safe-copy.sh")]
    if not ctx.apply_changes:
        cmd.append("--dry-run")
    if verify:
        cmd.append("--verify")
    if ignore_existing:
        cmd.append("--ignore-existing")
    cmd.extend(str(item) for item in sources)
    cmd.append(str(dest))
    return run_local_script(cmd)


def tool_make_directory(ctx: AgentContext, path: str) -> dict[str, Any]:
    target = ctx.resolve_path(path, must_exist=False)
    if ctx.apply_changes:
        target.mkdir(parents=True, exist_ok=True)
        status = "created"
    else:
        status = "would create"
    return {"path": ctx.display_path(target), "status": status}


def tool_move_path(ctx: AgentContext, source: str, destination: str) -> dict[str, Any]:
    src = ctx.resolve_path(source)
    dst = ctx.resolve_path(destination, must_exist=False)
    if dst.exists():
        raise AgentError(f"destination already exists: {dst}")
    if ctx.apply_changes:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dst))
        status = "moved"
    else:
        status = "would move"
    return {"source": ctx.display_path(src), "destination": ctx.display_path(dst), "status": status}


def tool_trash_path(ctx: AgentContext, path: str) -> dict[str, Any]:
    target = ctx.resolve_path(path)
    if ctx.apply_changes:
        proc = subprocess.run(["trash-put", "--", str(target)], capture_output=True, text=True, check=False)
        if proc.returncode != 0:
            raise AgentError(proc.stderr.strip() or f"failed to trash {target}")
        status = "trashed"
    else:
        status = "would trash"
    return {"path": ctx.display_path(target), "status": status}


TOOL_FUNCTIONS = {
    "list_dir": tool_list_dir,
    "search_files": tool_search_files,
    "file_info": tool_file_info,
    "read_text_file": tool_read_text_file,
    "normalize_names": tool_normalize_names,
    "sort_library": tool_sort_library,
    "safe_copy": tool_safe_copy,
    "make_directory": tool_make_directory,
    "move_path": tool_move_path,
    "trash_path": tool_trash_path,
}


def call_ollama(base_url: str, payload: dict[str, Any]) -> dict[str, Any]:
    body = json.dumps(payload).encode("utf-8")
    request = Request(
        f"{base_url.rstrip('/')}/api/chat",
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urlopen(request, timeout=600) as response:
            return json.loads(response.read().decode("utf-8"))
    except HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise AgentError(f"Ollama API error: {exc.code} {detail}") from exc
    except URLError as exc:
        raise AgentError(
            "Could not reach the Ollama API. Make sure `ollama serve` is running "
            f"at {base_url}."
        ) from exc


def parse_tool_arguments(raw: Any) -> dict[str, Any]:
    if isinstance(raw, dict):
        return raw
    if isinstance(raw, str):
        try:
            value = json.loads(raw)
        except json.JSONDecodeError as exc:
            raise AgentError(f"tool call arguments were not valid JSON: {raw}") from exc
        if not isinstance(value, dict):
            raise AgentError(f"tool call arguments must decode to an object: {raw}")
        return value
    raise AgentError(f"unsupported tool argument format: {raw!r}")


def tool_trace(name: str, arguments: dict[str, Any]) -> str:
    return f"tool {name}({json.dumps(arguments, ensure_ascii=False)})"


def looks_like_generic_clarifying_question(content: str) -> bool:
    text = content.strip().casefold()
    if not text:
        return False
    markers = (
        "what would you like me to do",
        "how would you like me to proceed",
        "what would you like me to do with",
        "please tell me what you want",
    )
    if any(marker in text for marker in markers):
        return True
    return text.endswith("?") and "i can " in text


def maybe_parse_pseudo_tool_calls(content: str) -> list[dict[str, Any]]:
    raw = content.strip()
    if not raw:
        return []

    if raw.startswith("```") and raw.endswith("```"):
        lines = raw.splitlines()
        if len(lines) >= 3:
            raw = "\n".join(lines[1:-1]).strip()

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        return []

    items: list[Any]
    if isinstance(payload, dict):
        items = [payload]
    elif isinstance(payload, list):
        items = payload
    else:
        return []

    pseudo_calls: list[dict[str, Any]] = []
    for item in items:
        if not isinstance(item, dict):
            continue
        name = item.get("name")
        arguments = item.get("arguments", {})
        if name in TOOL_FUNCTIONS and isinstance(arguments, dict):
            pseudo_calls.append({"function": {"name": name, "arguments": arguments}})
    return pseudo_calls


def build_system_prompt(ctx: AgentContext, mode: str) -> str:
    return f"""You are a careful local file-management assistant.

You can only work inside this allowed root:
{ctx.root}

Rules:
- Never refer to or attempt paths outside the allowed root.
- Do not ask generic follow-up questions like "what would you like me to do?" when a request is already present.
- Explore with read-only tools first before proposing or applying changes.
- Do not call the same tool with identical arguments repeatedly unless fresh data is genuinely needed.
- Prefer conservative, reversible actions.
- `trash_path` is safer than deletion.
- Prefer `normalize_names` and `sort_library` over large batches of manual renames or moves.
- If changes are not confirmed, action tools run in dry-run mode. Treat those results as previews and explain that no real changes were made.
- If changes are confirmed, keep the scope minimal and practical.
- Always end with a clear summary of findings and next actions.

Current mode: {mode}
Writes enabled: {"yes" if ctx.apply_changes else "no"}
"""


def build_initial_snapshot(ctx: AgentContext) -> dict[str, Any]:
    snapshot = tool_list_dir(ctx, path=".", recursive=False, limit=12, include_hidden=False)
    directories = 0
    files = 0
    others = 0
    for entry in snapshot["entries"]:
        entry_type = entry.get("type")
        if entry_type == "directory":
            directories += 1
        elif entry_type == "file":
            files += 1
        else:
            others += 1
    concise_entries = []
    for entry in snapshot["entries"]:
        concise_entry = {
            "path": entry["relative_path"],
            "type": entry["type"],
        }
        if entry["type"] == "file":
            concise_entry["size"] = entry["size"]
        concise_entries.append(concise_entry)

    return {
        "root": snapshot["path"],
        "count": snapshot["count"],
        "truncated": snapshot["truncated"],
        "summary": {
            "directories": directories,
            "files": files,
            "others": others,
        },
        "entries": concise_entries,
    }


def request_final_summary(
    *,
    base_url: str,
    model: str,
    messages: list[dict[str, Any]],
    mode: str,
) -> str:
    follow_up = {
        "role": "user",
        "content": (
            "Stop calling tools now. Based only on the information already gathered, "
            "produce your final answer. "
            "If the mode is plan, give a concrete cleanup plan. "
            "If the mode is organize without confirmation, describe the dry-run actions "
            "you would take. "
            "If the mode is organize or apply with confirmation, summarize the changes "
            "already made or the safest next actions."
        ),
    }
    response = call_ollama(
        base_url,
        {
            "model": model,
            "messages": messages + [follow_up],
            "stream": False,
            "think": False,
            "options": {"temperature": 0.1, "num_predict": DEFAULT_NUM_PREDICT},
        },
    )
    return response.get("message", {}).get("content", "").strip()


def request_single_shot_plan(
    *,
    base_url: str,
    model: str,
    mode: str,
    root: Path,
    user_instruction: str,
    initial_snapshot: dict[str, Any],
    writes_enabled: bool,
) -> str:
    system = (
        "You are a careful local file-management assistant. "
        "You are given a snapshot of one allowed root directory. "
        "Do not ask generic follow-up questions. "
        "Give a practical, conservative answer based only on the provided snapshot. "
        "Prefer safe local helpers such as normalize-filenames, sort-library, safe-copy, "
        "and trash-put/trash_path. Avoid recommending destructive rm commands. "
        "Do not invent helper names or flags."
    )

    if mode == "plan":
        mode_instruction = (
            "Produce a concrete cleanup and organization plan. "
            "Focus on duplicates, messy names, likely categories, and safe next steps."
        )
    else:
        mode_instruction = (
            "Produce a conservative dry-run organization plan. "
            "Describe what you would do first, what should be reviewed manually, "
            "and which changes are safest to apply."
        )

    command_reference = (
        "Available helper commands and real syntax:\n"
        "- normalize-filenames [--apply] [--folders-only|--files-only] DIRECTORY\n"
        "- sort-library --source DIRECTORY --dest DIRECTORY [--recursive] [--apply]\n"
        "- safe-copy SOURCE... DEST\n"
        "- trash-put -- PATH\n"
        "Only suggest commands from this list when you give concrete shell examples."
    )

    prompt = (
        f"{system}\n\n"
        f"Allowed root: {root}\n"
        f"Mode: {mode}\n"
        f"Writes enabled: {'yes' if writes_enabled else 'no'}\n"
        f"Request: {user_instruction}\n"
        f"Instruction: {mode_instruction}\n"
        f"{command_reference}\n"
        f"Snapshot: {json.dumps(initial_snapshot, ensure_ascii=False)}\n"
    )

    env = os.environ.copy()
    env["OLLAMA_HOST"] = base_url
    proc = subprocess.run(
        ["ollama", "run", model, prompt],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    if proc.returncode != 0:
        stderr = proc.stderr.strip() or proc.stdout.strip()
        raise AgentError(f"ollama run failed: {stderr}")
    return clean_terminal_artifacts(proc.stdout)


def main() -> int:
    args = parse_args()
    root = Path(args.root).expanduser().resolve(strict=False)
    if not root.exists() or not root.is_dir():
        print(f"file-agent: root directory not found: {root}", file=sys.stderr)
        return 1

    if args.mode == "apply" and not args.instruction:
        print("file-agent: apply mode expects an instruction.", file=sys.stderr)
        return 1

    if args.max_steps is not None:
        max_steps = args.max_steps
    elif DEFAULT_MAX_STEPS_ENV is not None:
        max_steps = int(DEFAULT_MAX_STEPS_ENV)
    else:
        max_steps = MODE_DEFAULT_MAX_STEPS[args.mode]

    ctx = AgentContext(root=root, apply_changes=args.confirm, verbose=args.verbose)
    user_instruction = build_user_instruction(args)
    initial_snapshot = build_initial_snapshot(ctx)
    has_custom_instruction = bool(args.instruction)

    if args.mode == "plan" or (
        args.mode == "organize" and not args.confirm and not has_custom_instruction
    ):
        single_shot = request_single_shot_plan(
            base_url=args.ollama_url,
            model=args.model,
            mode=args.mode,
            root=ctx.root,
            user_instruction=user_instruction,
            initial_snapshot=initial_snapshot,
            writes_enabled=ctx.apply_changes,
        )
        if single_shot:
            print(single_shot)
            return 0

    messages: list[dict[str, Any]] = [
        {"role": "system", "content": build_system_prompt(ctx, args.mode)},
        {
            "role": "user",
            "content": (
                f"Allowed root: {ctx.root}\n"
                f"Request: {user_instruction}\n"
                f"Mode: {args.mode}\n"
                f"Writes enabled: {'yes' if ctx.apply_changes else 'no'}"
            ),
        },
        {
            "role": "user",
            "content": (
                "Initial root snapshot is already available below. Start working from "
                "this without asking a generic follow-up question. Use more tools only "
                "if you genuinely need more detail.\n"
                f"{json.dumps(initial_snapshot, ensure_ascii=False)}"
            ),
        },
    ]
    tool_cache: dict[str, Any] = {}
    nudged_after_generic_question = False

    for step in range(max_steps):
        response = call_ollama(
            args.ollama_url,
            {
                "model": args.model,
                "messages": messages,
                "tools": TOOLS,
                "stream": False,
                "think": False,
                "options": {"temperature": 0.2, "num_predict": DEFAULT_NUM_PREDICT},
            },
        )

        message = response.get("message", {})
        assistant_record: dict[str, Any] = {"role": "assistant"}
        if "content" in message:
            assistant_record["content"] = message.get("content", "")
        if message.get("tool_calls"):
            assistant_record["tool_calls"] = message["tool_calls"]
        messages.append(assistant_record)

        tool_calls = message.get("tool_calls") or []
        if not tool_calls:
            tool_calls = maybe_parse_pseudo_tool_calls(message.get("content", ""))
        if not tool_calls:
            content = message.get("content", "").strip()
            if (
                looks_like_generic_clarifying_question(content)
                and not nudged_after_generic_question
            ):
                nudged_after_generic_question = True
                messages.append(
                    {
                        "role": "user",
                        "content": (
                            "Do not ask me what I want in general. Use the existing request, "
                            "inspect the allowed root if needed, and either provide a concrete "
                            "plan or carry out a dry-run organization pass depending on the mode."
                        ),
                    }
                )
                continue
            if content:
                print(content)
                return 0
            print("file-agent: model returned no content.", file=sys.stderr)
            return 2

        for call in tool_calls:
            function = call.get("function", {})
            name = function.get("name")
            if name not in TOOL_FUNCTIONS:
                result = {"error": f"unknown tool: {name}"}
            else:
                try:
                    arguments = parse_tool_arguments(function.get("arguments", {}))
                    if ctx.verbose:
                        print(tool_trace(name, arguments), file=sys.stderr)
                    cache_key = json.dumps(
                        {"name": name, "arguments": arguments},
                        ensure_ascii=False,
                        sort_keys=True,
                    )
                    if cache_key in tool_cache:
                        result = {
                            "note": "duplicate tool call; use the cached result below instead of repeating the same request",
                            "cached_result": tool_cache[cache_key],
                        }
                    else:
                        result = TOOL_FUNCTIONS[name](ctx, **arguments)
                        tool_cache[cache_key] = result
                except Exception as exc:  # tool errors should flow back to the model
                    result = {"error": str(exc)}
            messages.append(
                {
                    "role": "tool",
                    "tool_name": name or "unknown",
                    "content": json.dumps(result, ensure_ascii=False),
                }
            )

    final_summary = request_final_summary(
        base_url=args.ollama_url,
        model=args.model,
        messages=messages,
        mode=args.mode,
    )
    if final_summary:
        print(final_summary)
        return 0

    print(
        f"file-agent: reached max tool-calling steps ({max_steps}) before finishing.",
        file=sys.stderr,
    )
    return 3


if __name__ == "__main__":
    sys.exit(main())
