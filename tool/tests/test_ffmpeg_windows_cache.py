"""Offline cache extraction contract for the pinned FFmpeg Kit Windows hook."""

from __future__ import annotations

import hashlib
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile


SCRIPT = Path(__file__).resolve().parents[1] / "ensure_ffmpeg_windows_cache.ps1"
BUNDLE = "bundle-base-windows-x86_64-shared-lgpl"
DLL_ENTRY = f"{BUNDLE}/bin/libffmpegkit.dll"
DLL_BYTES = b"synthetic FFmpeg DLL for an offline extraction test\n"
PWSH = shutil.which("pwsh") or shutil.which("powershell")


class FfmpegWindowsCacheTest(unittest.TestCase):
    def setUp(self):
        if not PWSH:
            self.skipTest("PowerShell is unavailable")
        self.directory = tempfile.TemporaryDirectory(prefix="ffmpeg-cache-test-")
        self.addCleanup(self.directory.cleanup)
        self.repo = Path(self.directory.name)
        self.cache = self.repo / ".dart_tool/hooks_runner/shared/ffmpeg_kit_extended_flutter/build/ffmpeg_kit_cache/windows"
        self.cache.mkdir(parents=True)
        self.archive = self.cache / f"{BUNDLE}.zip"
        self.extracted = self.cache / BUNDLE
        self.dll = self.extracted / DLL_ENTRY
        self.marker = self.extracted / ".extract_complete"

    def write_zip(self, entries=None):
        if entries is None:
            entries = {DLL_ENTRY: DLL_BYTES, f"{BUNDLE}/include/ffmpeg.h": b"header\n"}
        with zipfile.ZipFile(self.archive, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for path, data in entries.items():
                archive.writestr(path, data)
        return hashlib.sha256(self.archive.read_bytes()).hexdigest()

    def run_helper(self, archive_sha, dll_sha=None):
        command = [PWSH, "-NoProfile", "-NonInteractive"]
        if Path(PWSH).stem.lower() == "powershell":
            command += ["-ExecutionPolicy", "Bypass"]
        command += [
            "-File", str(SCRIPT), "-RepoRoot", str(self.repo),
            "-ArchiveSha256", archive_sha,
            "-DllSha256", dll_sha or hashlib.sha256(DLL_BYTES).hexdigest(),
        ]
        return subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")

    def assert_success(self, archive_sha):
        result = self.run_helper(archive_sha)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.dll.read_bytes(), DLL_BYTES)
        self.assertTrue(self.marker.is_file())

    def test_clean_cache_and_second_run_are_idempotent(self):
        archive_sha = self.write_zip()
        self.assert_success(archive_sha)
        marker_mtime = self.marker.stat().st_mtime_ns
        dll_mtime = self.dll.stat().st_mtime_ns
        self.assert_success(archive_sha)
        self.assertEqual(self.marker.stat().st_mtime_ns, marker_mtime)
        self.assertEqual(self.dll.stat().st_mtime_ns, dll_mtime)

    def test_archive_hash_mismatch_does_not_create_marker(self):
        self.write_zip()
        result = self.run_helper("0" * 64)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.extracted.exists())

    def test_corrupt_archive_does_not_create_marker(self):
        self.archive.write_bytes(b"not a zip")
        result = self.run_helper(hashlib.sha256(self.archive.read_bytes()).hexdigest())
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())

    def test_traversal_entry_is_rejected_before_extraction(self):
        archive_sha = self.write_zip({DLL_ENTRY: DLL_BYTES, f"{BUNDLE}/../../escaped.txt": b"escape"})
        result = self.run_helper(archive_sha)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())
        self.assertFalse((self.cache / "escaped.txt").exists())
        self.assertFalse(self.extracted.exists())

    def test_archive_without_expected_dll_is_rejected(self):
        archive_sha = self.write_zip({f"{BUNDLE}/include/ffmpeg.h": b"header"})
        result = self.run_helper(archive_sha)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())

    def test_wrong_dll_hash_leaves_no_success_marker(self):
        archive_sha = self.write_zip()
        result = self.run_helper(archive_sha, "1" * 64)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())

    def test_incomplete_or_corrupt_marked_cache_is_repaired(self):
        archive_sha = self.write_zip()
        self.extracted.mkdir()
        self.marker.write_text("stale")
        self.assert_success(archive_sha)
        self.dll.write_bytes(b"corrupt")
        self.assert_success(archive_sha)
        self.assertEqual(self.dll.read_bytes(), DLL_BYTES)


if __name__ == "__main__":
    unittest.main()
