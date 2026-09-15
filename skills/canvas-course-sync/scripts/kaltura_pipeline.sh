#!/usr/bin/env bash
# Kaltura video pipeline: download (yt-dlp) + transcribe (faster-whisper small.en) + save transcript .txt/.md
# Usage: kaltura_pipeline.sh "<fresh playManifest a.m3u8 URL>" "<output base name>"
# Run from the folder where the video + transcripts should land (e.g. <Course>/Materials/Lectures).
set -euo pipefail
URL="${1:?usage: kaltura_pipeline.sh <url> <name>}"
NAME="${2:?usage: kaltura_pipeline.sh <url> <name>}"
# Machine-portable config: override via env vars on a fresh machine, or edit below.
YDL="${KALTURA_YDL:-/c/Program Files/yt-dlp/yt-dlp}"
PY="${KALTURA_PY:-C:/Users/<USER_NAME>/AppData/Local/hermes/hermes-agent/venv/Scripts/python.exe}"
REF="${KALTURA_REFERRER:-https://3438553-3.kaf.kaltura.com/}"
# Fallbacks for fresh installs (see suite README "Dependencies")
[ -x "$YDL" ] || YDL="$(command -v yt-dlp || true)"
[ -f "$PY" ] || PY="$(command -v python || command -v python3 || true)"
[ -n "$YDL" ] || { echo "yt-dlp not found. Run: pip install yt-dlp   (or set KALTURA_YDL)"; exit 1; }
[ -n "$PY" ] || { echo "python not found. Run: pip install faster-whisper pymupdf pillow   (or set KALTURA_PY)"; exit 1; }
echo "Using yt-dlp: $YDL | python: $PY | referrer: $REF"

echo "== Downloading: $NAME =="
"$YDL" --referer "$REF" -c -N 8 -o "$NAME.%(ext)s" "$URL"

echo "== Transcribing ($NAME) =="
"$PY" - "$NAME" <<'PYEOF'
import faster_whisper, sys
name = sys.argv[1]
mp4 = name + ".mp4"
m = faster_whisper.WhisperModel("small.en", device="cpu", compute_type="int8")
segs, info = m.transcribe(mp4, vad_filter=True, beam_size=5)
lines = []
for s in segs:
    t = f"{int(s.start//60):02d}:{int(s.start%60):02d}"
    lines.append(f"[{t}] {s.text.strip()}")
txt = "\n".join(lines)
open(name + " - transcript.txt", "w", encoding="utf-8").write(txt + "\n")
open(name + " - transcript.md", "w", encoding="utf-8").write(f"# {name}\n\n*Transcript: faster-whisper small.en ({info.duration/60:.1f} min)*\n\n" + txt + "\n")
print(f"DONE {len(lines)} segments, {info.duration/60:.1f} min")
PYEOF
echo "== Finished: $NAME =="
