#!/usr/bin/env bash
# Render the bring-the-humans-03 TikTok ad v3: 1080x1920, 16 s, 30 fps, H.264.
#
# v3 vs v2: NO on-screen text at all (user: the words looked ugly).
# Same 3 cinematic scenes with the Ken Burns move, same music-only audio,
# badge from frame 0, referral end card over the last 2.5 s with code
# z8qf6ayd typed in. The message now rides on the caption + end card.
#
# Run from the repository root. Reuses v2's joined 13.5 s clip
# (../bring-the-humans-03-video/work/clip-v2.mp4) so only the final pass
# runs again. Output: ../bring-the-humans-03-video/ad-v3.mp4.
set -euo pipefail

REPO="$(pwd)"
ASSETS="$(realpath -m ../bring-the-humans-03-video/assets)"
WORK="$(realpath -m ../bring-the-humans-03-video/work)"
OUT="$(realpath -m ../bring-the-humans-03-video/ad-v3.mp4)"
CODE="z8qf6ayd"
FONT="$ASSETS/JetBrainsMono-Bold.ttf"
BADGE="$ASSETS/badge-9x16.png"
CARD="$ASSETS/endcard-9x16.webm"

T=13.5
ffmpeg -y -i "$WORK/clip-v2.mp4" -c:v libvpx-vp9 -i "$CARD" -i "$BADGE" \
  -i "$WORK/music-v2.mp3" -filter_complex "
[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,fps=30,format=yuva420p[base];
[base][2:v]overlay=enable='lt(t,$T)',format=yuva420p,split[clip][soft];
[soft]gblur=sigma=28,eq=saturation=0.35,fade=t=in:st=$T:d=0.8:alpha=1[soft];
[clip][soft]overlay[bg];
[1:v]format=yuva420p,setpts=PTS-STARTPTS+$T/TB[card];
[bg][card]overlay=eof_action=pass,
drawbox=x=208:y=1230:w=9:h=82:color=white:t=fill:enable='gte(t,14.933)',
drawtext=fontfile=$FONT:text=$CODE:fontsize=62:fontcolor=0x191419:x=210:y=1271-(ascent-descent)/2:enable='gte(t,14.933)'[v];
[3:a]atrim=0:16,afade=t=in:st=0:d=0.3,afade=t=out:st=15:d=1,apad=whole_dur=16[a]" \
  -map '[v]' -map '[a]' -c:v libx264 -pix_fmt yuv420p -crf 18 -c:a aac -movflags +faststart "$OUT"

echo "wrote $OUT"
