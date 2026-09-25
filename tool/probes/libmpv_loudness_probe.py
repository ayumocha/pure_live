"""Verify MPV gain against offline PCM; never opens an audio device or live URL.

Run under tool/build_resource_guard.ps1 with --library <libmpv-2.dll> and
--output-dir <ignored evidence directory>. No third-party Python modules needed.
"""

import argparse
import array
import ctypes as c
import hashlib
import json
import math
import os
from pathlib import Path
import time
import wave


class Event(c.Structure):
    _fields_ = [("event_id", c.c_int), ("error", c.c_int),
                ("reply", c.c_uint64), ("data", c.c_void_p)]


class EndFile(c.Structure):
    _fields_ = [("reason", c.c_int), ("error", c.c_int)]


def verify(library, output_dir):
    output_dir.mkdir(parents=True, exist_ok=True)
    dll_directory = os.add_dll_directory(str(library.parent)) if os.name == "nt" else None
    try:
        mpv = c.CDLL(str(library))
        signatures = {
            "mpv_create": (c.c_void_p, []),
            "mpv_initialize": (c.c_int, [c.c_void_p]),
            "mpv_set_option_string": (c.c_int, [c.c_void_p, c.c_char_p, c.c_char_p]),
            "mpv_set_property_string": (c.c_int, [c.c_void_p, c.c_char_p, c.c_char_p]),
            "mpv_get_property_string": (c.c_void_p, [c.c_void_p, c.c_char_p]),
            "mpv_command": (c.c_int, [c.c_void_p, c.POINTER(c.c_char_p)]),
            "mpv_wait_event": (c.POINTER(Event), [c.c_void_p, c.c_double]),
            "mpv_error_string": (c.c_char_p, [c.c_int]),
            "mpv_free": (None, [c.c_void_p]),
            "mpv_terminate_destroy": (None, [c.c_void_p]),
        }
        for name, (result, arguments) in signatures.items():
            function = getattr(mpv, name)
            function.restype, function.argtypes = result, arguments

        def check(code):
            if code < 0:
                raise RuntimeError(mpv.mpv_error_string(code).decode())

        source = output_dir / "signal.wav"
        signal = array.array("h")
        # Silence, quiet audio, ordinary audio, and intentionally near-full-scale
        # audio make gain, mute, channel balance, and clipping observable.
        for amplitude in (0, .01, .05, .95):
            for index in range(3 * 48000):
                value = int(amplitude * 32767 * math.sin(2 * math.pi * 440 * index / 48000))
                signal.extend((value, int(value * .5)))
        with wave.open(str(source), "wb") as wav:
            wav.setparams((2, 2, 48000, 0, "NONE", "not compressed"))
            wav.writeframes(signal.tobytes())

        def render(name, gains, volume=100, mute=False):
            destination = output_dir / f"{name}.wav"
            handle = mpv.mpv_create()
            if not handle:
                raise RuntimeError("mpv_create failed")

            def get(property_name):
                pointer = mpv.mpv_get_property_string(handle, property_name.encode())
                if not pointer:
                    raise RuntimeError(f"Missing MPV property: {property_name}")
                try:
                    return c.string_at(pointer).decode()
                finally:
                    mpv.mpv_free(pointer)

            def command(*values):
                argv = (c.c_char_p * (len(values) + 1))(
                    *(value.encode() for value in values), None)
                check(mpv.mpv_command(handle, argv))

            try:
                options = {
                    "config": "no", "load-scripts": "no", "terminal": "no",
                    "vid": "no", "vo": "null", "ao": "pcm",
                    "ao-pcm-file": str(destination), "audio-format": "s16",
                    "audio-samplerate": "48000", "audio-channels": "stereo",
                    "volume": str(volume), "mute": "yes" if mute else "no",
                    "idle": "yes", "keep-open": "no",
                }
                for key, value in options.items():
                    check(mpv.mpv_set_option_string(handle, key.encode(), value.encode()))
                check(mpv.mpv_initialize(handle))
                command("af", "add", "@unrelated:scaletempo2")
                original_state = {key: get(key) for key in ("volume", "mute", "af")}
                for gain in gains:
                    check(mpv.mpv_set_property_string(handle, b"volume-gain", str(gain).encode()))
                    assert abs(float(get("volume-gain")) - gain) < .001
                assert original_state == {key: get(key) for key in original_state}
                command("loadfile", str(source))
                deadline = time.monotonic() + 30
                while time.monotonic() < deadline:
                    event = mpv.mpv_wait_event(handle, .1).contents
                    if event.event_id == 7:
                        check(event.error)
                        end = c.cast(event.data, c.POINTER(EndFile)).contents
                        check(end.error)
                        assert end.reason == 0, f"Unexpected end reason {end.reason}"
                        break
                else:
                    raise TimeoutError("Offline PCM rendering timed out")
            finally:
                mpv.mpv_terminate_destroy(handle)
            with wave.open(str(destination), "rb") as wav:
                assert (wav.getnchannels(), wav.getsampwidth(), wav.getframerate()) == (2, 2, 48000)
                samples = array.array("h", wav.readframes(wav.getnframes()))
            assert len(samples) == len(signal), "Unexpected duration change"
            return samples

        def rms(samples):
            # Quiet stereo interval, away from transitions.
            selected = samples[4 * 96000:5 * 96000]
            return math.sqrt(sum(value * value for value in selected) / len(selected))

        baseline = render("off", [0])
        with library.open("rb") as binary:
            digest = hashlib.file_digest(binary, "sha256").hexdigest()
        report = {"library_sha256": digest, "sink": "offline PCM WAV", "presets": {}}
        for name, gain in (("gentle", 3), ("standard", 6), ("strong", 9)):
            output = render(name, [gain])
            measured = 20 * math.log10(rms(output) / rms(baseline))
            assert abs(measured - gain) < .03, (gain, measured)
            assert not any(output[:2 * 96000]), "Silence was amplified"
            quiet = output[4 * 96000:5 * 96000]
            assert max(abs(quiet[i] * .5 - quiet[i + 1]) for i in range(0, len(quiet), 2)) < 4
            report["presets"][name] = {
                "requested_db": gain, "measured_db": measured,
                "near_fullscale_source_clipped": any(abs(value) >= 32767 for value in output),
            }
        assert render("restored", [9, 3, 6, 0]) == baseline, "Off did not restore unity gain"
        assert render("reselected", [3, 9, 6]) == render("standard-reference", [6])
        assert not any(render("zero-volume", [9], volume=0))
        assert not any(render("muted", [9], mute=True))
        report.update(silence_preserved=True, volume_and_mute_preserved=True,
                      unrelated_filter_preserved=True, off_restores_baseline=True,
                      gain_does_not_accumulate=True, duration_preserved=True)
        (output_dir / "result.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(report, indent=2))
    finally:
        if dll_directory:
            dll_directory.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--library", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    verify(args.library.resolve(strict=True), args.output_dir.resolve())
