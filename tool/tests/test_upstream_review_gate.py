"""Hermetic Git history tests for the incoming-upstream review gate."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tool/review_upstream_update.ps1"
FIXTURE_PATH = Path("test/fixtures/tls/localhost-key.pem")
FIXTURE_SHA256 = "b55b3743dda7dd512713f6efa4850d3a729486e9e2bff8cb4302738c192a5af8"
PWSH = shutil.which("pwsh") or shutil.which("powershell")


class UpstreamReviewGateTest(unittest.TestCase):
    def setUp(self):
        if not PWSH:
            self.skipTest("PowerShell is unavailable")
        self.directory = tempfile.TemporaryDirectory(prefix="upstream-gate-")
        self.addCleanup(self.directory.cleanup)
        self.repo = Path(self.directory.name)
        self.write("tool/review_upstream_update.ps1", SCRIPT.read_bytes())
        self.write("README.md", b"base\n")
        self.git("init", "-q")
        self.git("config", "user.name", "Gate Test")
        self.git("config", "user.email", "gate@example.invalid")
        self.git("config", "core.autocrlf", "false")
        self.commit("base")
        self.base = self.git("rev-parse", "HEAD").stdout.strip()

    def git(self, *args):
        result = subprocess.run(
            ["git", "-C", str(self.repo), *args], capture_output=True, text=True,
            encoding="utf-8", check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def write(self, path, data):
        target = self.repo / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data if isinstance(data, bytes) else data.encode("utf-8"))

    def commit(self, message="upstream"):
        self.git("add", "-A")
        self.git("commit", "-qm", message)
        return self.git("rev-parse", "HEAD").stdout.strip()

    def review(self, *flags):
        command = [PWSH, "-NoProfile", "-NonInteractive"]
        if Path(PWSH).stem.lower() == "powershell":
            command += ["-ExecutionPolicy", "Bypass"]
        command += [
            "-File", str(self.repo / "tool/review_upstream_update.ps1"),
            "-BaseRef", self.base, "-UpstreamRef", "HEAD",
            "-OutputPath", str(self.repo / "review.json"), *flags,
        ]
        completed = subprocess.run(
            command, cwd=self.repo, capture_output=True, text=True,
            encoding="utf-8", errors="replace", check=False,
        )
        report = json.loads((self.repo / "review.json").read_text(encoding="utf-8-sig"))
        return completed, report

    def fixture(self):
        source = ROOT / FIXTURE_PATH
        if not source.is_file():
            source = ROOT / ".local-build/upstream-sync-candidate" / FIXTURE_PATH
        data = source.read_bytes()
        self.assertEqual(hashlib.sha256(data).hexdigest(), FIXTURE_SHA256)
        return data

    def assert_passes(self, *flags):
        completed, report = self.review("-ReportOnly", *flags)
        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertEqual(report["violations"], [])
        self.assertTrue(report["diff_check_passed"])
        return report

    def test_crlf_is_allowed_but_real_trailing_space_is_blocked(self):
        self.write("README.md", b"base\r\nnext\r\n")
        self.commit()
        self.assert_passes()
        self.write("README.md", b"base\r\nnext  \r\n")
        self.commit("real trailing space")
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertFalse(report["diff_check_passed"])
        self.assertLess(len(completed.stderr), 1500)
        self.assertNotIn("next  ", completed.stderr)

    def test_checkout_ref_is_not_a_dependency_and_action_stays_pinned(self):
        self.write(".github/workflows/check.yml", (
            "jobs:\n  test:\n    steps:\n"
            "      - uses: actions/checkout@" + "a" * 40 + "\n"
            "        with:\n          ref: master\n"
        ))
        self.commit()
        self.assert_passes()

    def test_mutable_action_and_workflow_permissions_are_blocked(self):
        self.write(".github/workflows/check.yml", (
            "permissions: write-all\n"
            "on:\n  pull_request_target:\n"
            "jobs:\n  test:\n    steps:\n      - uses: actions/checkout@v4\n"
        ))
        self.commit()
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertGreaterEqual(
            set(report["violations"]),
            {"workflow_write_all", "pull_request_target", "mutable_action_reference"},
        )

    def test_mutable_git_dependency_in_root_or_nested_manifest_is_blocked(self):
        for path in ("pubspec.yaml", "packages/demo/pubspec.yaml", "packages/demo/pubspec.lock"):
            with self.subTest(path=path):
                self.write(path, "dependencies:\n  package:\n    git:\n      ref: master\n")
                self.commit(path)
                completed, report = self.review("-ReportOnly")
                self.assertNotEqual(completed.returncode, 0)
                self.assertIn("mutable_git_dependency", report["violations"])

    def test_non_manifest_ref_is_not_a_dependency(self):
        self.write("docs/example.yaml", "checkout:\n  ref: master\n")
        self.commit()
        self.assert_passes()

    def test_diff_content_cannot_spoof_a_new_file_header(self):
        self.write("pubspec.yaml", "++ b/docs/fake.txt\n  ref: master\n")
        self.commit()
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertIn("mutable_git_dependency", report["violations"])

    def test_exact_public_fixture_is_recorded_without_key_content(self):
        self.write(FIXTURE_PATH, self.fixture())
        self.commit()
        report = self.assert_passes()
        self.assertEqual(report["public_fixture_exceptions"], [{
            "rule": "reviewed_public_tls_test_key",
            "path": FIXTURE_PATH.as_posix(),
            "sha256": FIXTURE_SHA256,
        }])
        self.assertNotIn("BEGIN PRIVATE KEY", json.dumps(report))

    def test_copied_or_modified_public_fixture_is_blocked(self):
        data = self.fixture()
        self.write(FIXTURE_PATH, data)
        self.write("test/fixtures/tls/other-key.pem", data)
        self.commit()
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertIn("credential_material_in_added_lines", report["violations"])
        self.assertEqual(len(report["public_fixture_exceptions"]), 1)
        (self.repo / "test/fixtures/tls/other-key.pem").unlink()
        self.write(FIXTURE_PATH, data + b"# changed\n")
        self.commit("modified fixture")
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertIn("credential_material_in_added_lines", report["violations"])
        self.assertEqual(report["public_fixture_exceptions"], [])
        self.assertNotIn("BEGIN PRIVATE KEY", completed.stderr)

    def test_added_token_on_fixture_is_blocked(self):
        token = "ghp_" + "A" * 30
        self.write(FIXTURE_PATH, self.fixture() + f"# {token}\n".encode())
        self.commit()
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertIn("credential_material_in_added_lines", report["violations"])
        self.assertEqual(report["public_fixture_exceptions"], [])
        self.assertNotIn(token, completed.stderr)
        self.assertNotIn(token, json.dumps(report))

    def test_other_private_key_is_blocked(self):
        self.write("test/other.pem", "-----BEGIN PRIVATE KEY-----\nsynthetic\n")
        self.commit()
        completed, report = self.review("-ReportOnly")
        self.assertNotEqual(completed.returncode, 0)
        self.assertIn("credential_material_in_added_lines", report["violations"])
        self.assertEqual(report["public_fixture_exceptions"], [])

    def test_full_audit_and_approval_gate_remains_required(self):
        self.write("one.txt", "one\n")
        first = self.commit("first")
        self.write("two.txt", "two\n")
        second = self.commit("second")
        completed, report = self.review()
        self.assertNotEqual(completed.returncode, 0)
        self.assertEqual(report["commit_count"], 2)
        self.assertEqual([item["sha"] for item in report["commits"]], [first, second])
        self.assertEqual({item["path"] for item in report["changes"]}, {"one.txt", "two.txt"})
        self.assertEqual(set(report["audit_document_missing_files"]), {"one.txt", "two.txt"})
        markers = report["audit_document_required_markers"]
        self.write("audit.md", "\n".join([*markers, first, second, "one.txt", "two.txt"]))
        completed, report = self.review("-AuditDocument", "audit.md")
        self.assertNotEqual(completed.returncode, 0)
        self.assertTrue(report["audit_document_valid"])
        completed, report = self.review("-AuditDocument", "audit.md", "-ApproveHighRisk")
        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertTrue(report["high_risk_approved"])


if __name__ == "__main__":
    unittest.main()
