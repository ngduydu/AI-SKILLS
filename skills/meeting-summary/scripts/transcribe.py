from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime
from pathlib import Path

SUPPORTED_EXTENSIONS = {".mp4", ".mkv", ".mov", ".webm", ".mp3", ".wav", ".m4a"}


def format_timestamp(seconds: float) -> str:
    total = max(0, int(round(seconds)))
    hours, rem = divmod(total, 3600)
    minutes, secs = divmod(rem, 60)
    return f"{hours:02d}:{minutes:02d}:{secs:02d}"


def safe_output_dir(output_root: Path, stem: str) -> Path:
    candidate = output_root / stem
    if not candidate.exists():
        return candidate

    stamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    candidate = output_root / f"{stem} - {stamp}"
    counter = 2
    while candidate.exists():
        candidate = output_root / f"{stem} - {stamp} - {counter}"
        counter += 1
    return candidate


def find_reusable_transcript(output_root: Path, stem: str) -> Path | None:
    exact = output_root / stem / "transcript.txt"
    if exact.is_file() and exact.stat().st_size > 0:
        return exact

    prefix = f"{stem} - "
    candidates: list[Path] = []
    for child in output_root.iterdir():
        if not child.is_dir() or not child.name.startswith(prefix):
            continue
        transcript = child / "transcript.txt"
        if transcript.is_file() and transcript.stat().st_size > 0:
            candidates.append(transcript)

    if not candidates:
        return None

    candidates.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return candidates[0]


def load_model(model_name: str, device: str, compute_type: str):
    from faster_whisper import WhisperModel

    return WhisperModel(model_name, device=device, compute_type=compute_type)


def transcribe_with_device(input_path: Path, model_name: str, device: str, compute_type: str):
    model = load_model(model_name, device=device, compute_type=compute_type)
    segments, info = model.transcribe(
        str(input_path),
        language="vi",
        task="transcribe",
        beam_size=5,
        vad_filter=True,
        condition_on_previous_text=True,
    )
    # Phải iterate hết generator ở đây để bắt được cả lỗi CUDA phát sinh khi inference.
    materialized = list(segments)
    return materialized, info


def main() -> int:
    parser = argparse.ArgumentParser(description="Transcribe meeting audio/video in Vietnamese with faster-whisper.")
    parser.add_argument("--input", required=True, help="Absolute path to input audio/video file")
    parser.add_argument("--output-root", required=True, help="Root directory for generated output")
    parser.add_argument("--model", default="large-v3", help="Whisper model name")
    parser.add_argument(
        "--force-transcribe",
        action="store_true",
        help="Ignore an existing transcript and transcribe the source again",
    )
    args = parser.parse_args()

    input_path = Path(os.path.expandvars(os.path.expanduser(args.input))).resolve()
    output_root = Path(os.path.expandvars(os.path.expanduser(args.output_root))).resolve()

    if not input_path.exists() or not input_path.is_file():
        print(f"ERROR=Không tìm thấy file đầu vào: {input_path}", file=sys.stderr)
        return 2

    if input_path.suffix.lower() not in SUPPORTED_EXTENSIONS:
        supported = ", ".join(sorted(SUPPORTED_EXTENSIONS))
        print(f"ERROR=Định dạng không được hỗ trợ: {input_path.suffix}. Hỗ trợ: {supported}", file=sys.stderr)
        return 3

    output_root.mkdir(parents=True, exist_ok=True)

    if not args.force_transcribe:
        reusable_transcript = find_reusable_transcript(output_root, input_path.stem)
        if reusable_transcript is not None:
            print(f"OUTPUT_DIR={reusable_transcript.parent}")
            print(f"TRANSCRIPT_PATH={reusable_transcript}")
            print("DEVICE_USED=reused")
            print("REUSED_TRANSCRIPT=true")
            return 0

    output_dir = safe_output_dir(output_root, input_path.stem)
    output_dir.mkdir(parents=True, exist_ok=False)
    transcript_path = output_dir / "transcript.txt"

    device_used = "cpu"
    compute_type_used = "int8"

    try:
        try:
            segments, info = transcribe_with_device(input_path, args.model, "cuda", "float16")
            device_used = "cuda"
            compute_type_used = "float16"
        except Exception as gpu_error:
            print(f"INFO=CUDA không dùng được, chuyển sang CPU int8: {gpu_error}", file=sys.stderr)
            segments, info = transcribe_with_device(input_path, args.model, "cpu", "int8")

        duration = 0.0
        if segments:
            duration = max(float(s.end) for s in segments)

        with transcript_path.open("w", encoding="utf-8", newline="\n") as f:
            f.write("# TRANSCRIPT CUỘC HỌP\n\n")
            f.write(f"- File nguồn: {input_path.name}\n")
            f.write(f"- Ngôn ngữ nhận diện: Tiếng Việt (vi)\n")
            f.write(f"- Model: {args.model}\n")
            f.write(f"- Thiết bị xử lý: {device_used} ({compute_type_used})\n")
            if duration > 0:
                f.write(f"- Thời lượng nhận diện: {format_timestamp(duration)}\n")
            f.write("\n---\n\n")

            for segment in segments:
                text = (segment.text or "").strip()
                if not text:
                    continue
                start = format_timestamp(float(segment.start))
                end = format_timestamp(float(segment.end))
                f.write(f"[{start} - {end}]\n{text}\n\n")

        print(f"OUTPUT_DIR={output_dir}")
        print(f"TRANSCRIPT_PATH={transcript_path}")
        print(f"DURATION_SECONDS={duration:.2f}")
        print(f"DEVICE_USED={device_used}")
        print("REUSED_TRANSCRIPT=false")
        return 0

    except KeyboardInterrupt:
        print("ERROR=Đã hủy transcription.", file=sys.stderr)
        return 130
    except Exception as exc:
        print(f"ERROR=Transcription thất bại: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
