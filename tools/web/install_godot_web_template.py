#!/usr/bin/env python3
"""Install the exact Godot 4.6.3 single-threaded Web release template.

The official export template archive is over 1 GB. RemoteZip retrieves only
the central directory and the required member, keeping CI downloads small
while still verifying the extracted official template byte-for-byte.
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

import requests
from remotezip import RemoteZip


ASSET_URL = (
    "https://github.com/godotengine/godot-builds/releases/download/"
    "4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz"
)
ARCHIVE_MEMBER = "templates/web_nothreads_release.zip"
EXPECTED_SIZE = 9_574_223
EXPECTED_SHA256 = "1446f79dc12f60ce5d244c39fb6628ec298337ca5c4f91a16491feea72aa1bc9"


def _resolve_asset_url() -> str:
    with requests.get(ASSET_URL, allow_redirects=True, stream=True, timeout=120) as response:
        response.raise_for_status()
        return response.url


def install(destination: Path) -> Path:
    destination = destination.resolve()
    destination.mkdir(parents=True, exist_ok=True)
    target = destination / "web_nothreads_release.zip"

    final_url = _resolve_asset_url()
    with RemoteZip(final_url, support_suffix_range=False) as archive:
        info = archive.getinfo(ARCHIVE_MEMBER)
        if info.file_size != EXPECTED_SIZE:
            raise RuntimeError(
                f"Unexpected template size: {info.file_size} (expected {EXPECTED_SIZE})"
            )
        payload = archive.read(ARCHIVE_MEMBER)

    digest = hashlib.sha256(payload).hexdigest()
    if digest != EXPECTED_SHA256:
        raise RuntimeError(
            f"Unexpected template SHA-256: {digest} (expected {EXPECTED_SHA256})"
        )

    temporary = target.with_suffix(".zip.tmp")
    temporary.write_bytes(payload)
    temporary.replace(target)
    return target


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--destination",
        type=Path,
        required=True,
        help="Godot export_templates/4.6.3.stable directory",
    )
    args = parser.parse_args()
    target = install(args.destination)
    print(f"Installed {target} ({target.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
