#!/usr/bin/env bash
# Render the bring-the-humans-03 TikTok ad v2: 1080x1920, 16 s, 30 fps, H.264.
#
# v2 vs v1: cinematic AI-generated scene stills (robot desk, bounty board,
# phone signup) with a slow Ken Burns move, on-screen text as separate
# overlays that fade in/out (so the text never zooms with the picture),
# and MUSIC ONLY -- no voiceover. The music is a royalty-free Pixabay
# track (Pixabay Content License), loudest 16 s slice (30-46 s).
#
# Run from the repository root. Assets live beside the repo in
# ../bring-the-humans-03-video/assets (press pack: brand badge overlay and
# referral end card, used as they are) and
# ../bring-the-humans-03-video/v2 (the three scene stills). The finished
# file goes to ../bring-the-humans-03-video/ad-v2.mp4 (v1's ad.mp4 is kept).
#
# Scenes: 0-5 s hook, 5-11 s what make.fun is, 11-13.5 s call to action,
# 13.5-16 s referral end card with code z8qf6ayd typed in.
set -euo pipefail

REPO="$(pwd)"
ASSETS="$(realpath -m ../bring-the-humans-03-video/assets)"
V2="$(realpath -m ../bring-the-humans-03-video/v2)"
WORK="$(realpath -m ../bring-the-humans-03-video/work)"
OUT="$(realpath -m ../bring-the-humans-03-video/ad-v2.mp4)"
CODE="z8qf6ayd"
FONT="$ASSETS/JetBrainsMono-Bold.ttf"
BADGE="$ASSETS/badge-9x16.png"
CARD="$ASSETS/endcard-9x16.webm"
MUSIC_SRC="/tmp/music-cand1.mp3"
S1="$V2/media-generation-humans03-v2-scene1-robot-desk-0-1254ddbd-d020-4c22-a70a-e444a1bea823.webp"
S2="$V2/media-generation-humans03-v2-scene2-bounty-boar-0-3011ebc1-4363-4906-91c2-d854958f3c49.webp"
S3="$V2/media-generation-humans03-v2-scene3-phone-signu-0-a24be876-7c06-4ed6-aac3-73f02fa294cf.webp"

mkdir -p "$WORK"
cd "$WORK"

# Text overlays (transparent PNGs with a soft dark band).
python3 make_text_v2.py

# Scene frames at 1080x1920.
ffmpeg -y -v error -i "$S1" -vf "scale=1080:1920" "$WORK/s1.png"
ffmpeg -y -v error -i "$S2" -vf "scale=1080:1920" "$WORK/s2.png"
ffmpeg -y -v error -i "$S3" -vf "scale=1080:1920" "$WORK/s3.png"

# Scene clips with a slow Ken Burns move (30 fps).
ffmpeg -y -v error -loop 1 -i "$WORK/s1.png" \
  -vf "zoompan=z='1+0.00053*on':d=150:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30" \
  -t 5 -c:v libx264 -pix_fmt yuv420p "$WORK/v1.mp4"
ffmpeg -y -v error -loop 1 -i "$WORK/s2.png" \
  -vf "zoompan=z='1.08-0.00044*on':d=180:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30" \
  -t 6 -c:v libx264 -pix_fmt yuv420p "$WORK/v2.mp4"
ffmpeg -y -v error -loop 1 -i "$WORK/s3.png" \
  -vf "zoompan=z='1+0.0007*on':d=75:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30" \
  -t 2.5 -c:v libx264 -pix_fmt yuv420p "$WORK/v3.mp4"

# Join the three scenes into one 13.5 s clip.
printf "file '%s'\nfile '%s'\nfile '%s'\n" "$WORK/v1.mp4" "$WORK/v2.mp4" "$WORK/v3.mp4" > "$WORK/list-v2.txt"
ffmpeg -y -v error -f concat -safe 0 -i "$WORK/list-v2.txt" -c copy "$WORK/clip-v2.mp4"

# Music: loudest 16 s slice of the Pixabay track (30-46 s).
ffmpeg -y -v error -ss 30 -t 16 -i "$MUSIC_SRC" -c copy "$WORK/music-v2.mp3"

# Final pass: badge from frame 0, text overlays fading per scene,
# end card over the last 2.5 s, code typed in, music only.
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
