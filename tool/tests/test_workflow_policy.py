"""Deterministic checks for manually dispatched, serial release workflows."""

from pathlib import Path
import re
import unittest

import yaml


ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"
CHAIN = ("quality", "android", "windows", "linux", "apple")
INPUT_FOR_JOB = {
    "quality": "run_quality",
    "android": "build_android",
    "windows": "build_windows",
    "linux": "build_linux",
}


def load(name):
    # BaseLoader preserves the GitHub Actions key "on" (YAML 1.1 treats it as bool).
    return yaml.load((WORKFLOWS / name).read_text(encoding="utf-8"), Loader=yaml.BaseLoader)


def permits(expression, inputs, results):
    expression = expression.strip().removeprefix("${{").removesuffix("}}").strip()
    expression = expression.replace("always()", "True")

    def substitute(match):
        token = match.group()
        if token == "github.event_name":
            return repr("workflow_dispatch")
        if token.startswith("inputs."):
            return repr(bool(inputs.get(token.split(".")[1], False)))
        return repr(results[token.split(".")[1]])

    expression = re.sub(
        r"\b(?:github\.event_name|inputs\.\w+|needs\.\w+\.result)\b",
        substitute,
        expression,
    )
    expression = expression.replace("&&", " and ").replace("||", " or ")
    expression = re.sub(r"!(?!=)", " not ", expression)
    expression = " ".join(expression.split())
    # Reject syntax outside the small, deliberately supported guard language.
    assert re.fullmatch(r"[\s()=A-Za-z0-9_'\-]+", expression), expression
    return bool(eval(expression, {"__builtins__": {}}, {}))


class WorkflowPolicyTest(unittest.TestCase):
    def test_every_workflow_requires_manual_dispatch(self):
        for path in WORKFLOWS.glob("*.yml"):
            with self.subTest(path=path.name):
                doc = load(path.name)
                self.assertEqual(set(doc["on"]), {"workflow_dispatch"})
                dispatch = doc["on"]["workflow_dispatch"]
                for name, spec in (dispatch.get("inputs", {}) if isinstance(dispatch, dict) else {}).items():
                    if name.startswith("build_") or name in {"create_release", "publish_release"}:
                        self.assertEqual(spec.get("default", "false"), "false", name)

    def test_release_tag_and_repository_identity(self):
        for name in ("feature-build.yml", "build_pure_live_release.yml",
                     "stage-hosted-artifacts.yml", "publish-staged-release.yml"):
            with self.subTest(name=name):
                self.assertEqual(
                    load(name)["on"]["workflow_dispatch"]["inputs"]["release_tag"]["default"],
                    "v3.0.8",
                )
        legacy = (WORKFLOWS / "build_pure_live_release.yml").read_text(encoding="utf-8")
        self.assertNotIn("liuchuancong/pure_live/releases/download", legacy)
        self.assertIn("ayumocha/pure_live/releases/download", legacy)

    def test_platform_jobs_are_serial_and_skips_do_not_mask_failures(self):
        for name in ("feature-build.yml", "build_pure_live_release.yml"):
            jobs = load(name)["jobs"]
            with self.subTest(workflow=name):
                for index, target in enumerate(CHAIN[1:], 1):
                    expected = list(CHAIN[:index])
                    needs = jobs[target]["needs"]
                    if isinstance(needs, str):
                        needs = [needs]
                    self.assertEqual(needs, expected)
                    selected = {v: False for v in INPUT_FOR_JOB.values()}
                    selected["build_macos"] = False
                    selected["build_ios"] = False
                    if target == "apple":
                        selected["build_ios"] = True
                    else:
                        selected[INPUT_FOR_JOB[target]] = True
                    states = {job: "skipped" for job in CHAIN}
                    guard = jobs[target]["if"]
                    self.assertTrue(permits(guard, selected, states), target)

                    for prior in expected:
                        for terminal in ("failure", "cancelled"):
                            with self.subTest(target=target, prior=prior, terminal=terminal):
                                failed = states | {prior: terminal}
                                self.assertFalse(permits(guard, selected, failed))

                    for prior in expected:
                        chosen = selected.copy()
                        chosen[INPUT_FOR_JOB[prior]] = True
                        self.assertFalse(permits(guard, chosen, states))
                        succeeded = states | {prior: "success"}
                        self.assertTrue(permits(guard, chosen, succeeded))

    def test_publication_requires_selected_success_and_blocks_failure(self):
        for name in ("feature-build.yml", "build_pure_live_release.yml"):
            guard = load(name)["jobs"]["publish-release"]["if"]
            selected = {v: False for v in INPUT_FOR_JOB.values()}
            selected.update(build_ios=True, build_macos=False, create_release=True)
            states = {job: "skipped" for job in CHAIN}
            states["apple"] = "success"
            self.assertTrue(permits(guard, selected, states))
            for job in CHAIN:
                for terminal in ("failure", "cancelled"):
                    with self.subTest(workflow=name, job=job, terminal=terminal):
                        self.assertFalse(permits(guard, selected, states | {job: terminal}))
            self.assertFalse(permits(guard, selected, states | {"apple": "skipped"}))
            self.assertFalse(permits(guard, selected | {"create_release": False}, states))

    def test_staged_publisher_only_allows_skipped_unselected_windows(self):
        jobs = load("publish-staged-release.yml")["jobs"]
        self.assertEqual(jobs["publish"]["needs"], "windows")
        guard = jobs["publish"]["if"]
        for result in ("success", "skipped"):
            self.assertTrue(permits(guard, {}, {"windows": result}))
        for result in ("failure", "cancelled"):
            self.assertFalse(permits(guard, {}, {"windows": result}))


if __name__ == "__main__":
    unittest.main()
