#!/usr/bin/env python3
"""Safely unpack only approved solver-facing files from the bundle."""
from __future__ import annotations
import sys
import zipfile
from pathlib import Path, PurePosixPath

ALLOWED = {
    "LICENSE_AND_ATTRIBUTION.md",
    "README_solver.md",
    "data/source_manifest.csv",
    "data/task_input.json",
    "docs/submission_template.json",
    "docs/human_review_rubric.md",
    "instruction.md",
    "schemas/submission.schema.json",
    "schemas/task_input.schema.json",
}
REQUIRED = {
    "README_solver.md",
    "data/task_input.json",
    "instruction.md",
    "schemas/submission.schema.json",
    "schemas/task_input.schema.json",
}

def main() -> int:
    if len(sys.argv) != 3:
        print("usage: unpack_solver.py ARCHIVE DESTINATION", file=sys.stderr)
        return 2
    archive = Path(sys.argv[1])
    destination = Path(sys.argv[2]).resolve()
    destination.mkdir(parents=True, exist_ok=True)
    try:
        with zipfile.ZipFile(archive) as zf:
            bad_member = zf.testzip()
            if bad_member:
                raise ValueError(f"ZIP CRC failure in {bad_member}")
            file_infos = [info for info in zf.infolist() if not info.is_dir()]
            first_parts = {PurePosixPath(info.filename).parts[0] for info in file_infos}
            known_roots = {"LICENSE_AND_ATTRIBUTION.md", "README_solver.md", "data", "docs", "instruction.md", "schemas"}
            has_package_prefix = len(first_parts) == 1 and next(iter(first_parts)) not in known_roots
            planned: dict[str, zipfile.ZipInfo] = {}
            for info in file_infos:
                raw = PurePosixPath(info.filename)
                if raw.is_absolute() or ".." in raw.parts:
                    raise ValueError(f"unsafe ZIP path: {info.filename}")
                parts = raw.parts
                relative = "/".join(parts[1:]) if has_package_prefix else "/".join(parts)
                if relative not in ALLOWED:
                    raise ValueError(f"unexpected solver bundle member: {info.filename}")
                if relative in planned:
                    raise ValueError(f"duplicate normalized path: {relative}")
                planned[relative] = info
            missing = REQUIRED - set(planned)
            if missing:
                raise ValueError(f"solver bundle is missing required files: {sorted(missing)}")
            for relative, info in planned.items():
                target = (destination / relative).resolve()
                if destination != target and destination not in target.parents:
                    raise ValueError(f"path escapes destination: {relative}")
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(zf.read(info))
    except Exception as exc:
        print(f"SOLVER_BUNDLE_ERROR: {exc}", file=sys.stderr)
        return 2
    print(f"Unpacked {len(planned)} approved solver files into {destination}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
