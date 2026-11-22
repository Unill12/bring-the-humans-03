#!/usr/bin/env bash
# Render the bring-the-humans-03 TikTok ad v4: 1080x1920, 16 s, 30 fps, H.264.
#
# v4 vs v3: the words are back, but GOOD this time -- small, clean Noto Sans
# Bold, two short lines per scene in a small rounded pill in the lower
# third (work/make_text_v4.py). The logo badge (frame 0 onward) and the
# referral end card (last 2.5 s, code z8qf6ayd) are kept exactly as before.
# Same scenes, same music-only audio as v2/v3.
#
# Run from the repository root. Reuses v2's joined 13.5 s clip
# (../bring-the-humans-03-video/work/clip-v2.mp4). Output:
# ../bring-the-humans-03-video/ad-v4.mp4.
set -euo pipefail

REPO="$(pwd)"
ASSETS="$(realpath -m ../bring-the-humans-03-video/assets)"
WORK="$(realpath -m ../bring-the-humans-03-video/work)"
OUT="$(realpath -m ../bring-the-humans-03-video/ad-v4.mp4)"
CODE="z8qf6ayd"
FONT="$ASSETS/JetBrainsMono-Bold.ttf"
BADGE="$ASSETS/badge-9x16.png"
CARD="$ASSETS/endcard-9x16.webm"

mkdir -p "$WORK"
cd "$WORK"

# v4 text overlays (small pill, lower third).
python3 make_text_v4.py

T=13.5
ffmpeg -y -i "$WORK/clip-v2.mp4" -c:v libvpx-vp9 -i "$CARD" -i "$BADGE" \
  -loop 1 -t 16 -i "$WORK/t1.png" -loop 1 -t 16 -i "$WORK/t2.png" \
  -loop 1 -t 16 -i "$WORK/t3.png" -i "$WORK/music-v2.mp3" -filter_complex "
[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,fps=30,format=yuva420p[base];
[base][2:v]overlay=enable='lt(t,$T)',format=yuva420p[withbadge];
[3:v]format=yuva420p,fade=t=in:st=0.3:d=0.4:alpha=1,fade=t=out:st=4.5:d=0.5:alpha=1[t1];
[4:v]format=yuva420p,fade=t=in:st=5.3:d=0.4:alpha=1,fade=t=out:st=10.5:d=0.5:alpha=1[t2];
[5:v]format=yuva420p,fade=t=in:st=11.3:d=0.4:alpha=1,fade=t=out:st=13.1:d=0.4:alpha=1[t3];
[withbadge][t1]overlay[step1];
[step1][t2]overlay[step2];
[step2][t3]overlay,format=yuva420p,split[clip][soft];
[soft]gblur=sigma=28,eq=saturation=0.35,fade=t=in:st=$T:d=0.8:alpha=1[soft];
[clip][soft]overlay[bg];
[1:v]format=yuva420p,setpts=PTS-STARTPTS+$T/TB[card];
[bg][card]overlay=eof_action=pass,
drawbox=x=208:y=1230:w=9:h=82:color=white:t=fill:enable='gte(t,14.933)',
drawtext=fontfile=$FONT:text=$CODE:fontsize=62:fontcolor=0x191419:x=210:y=1271-(ascent-descent)/2:enable='gte(t,14.933)'[v];
[6:a]atrim=0:16,afade=t=in:st=0:d=0.3,afade=t=out:st=15:d=1,apad=whole_dur=16[a]" \
  -map '[v]' -map '[a]' -c:v libx264 -pix_fmt yuv420p -crf 18 -c:a aac -movflags +faststart "$OUT"

echo "wrote $OUT"
