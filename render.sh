#!/usr/bin/env bash
# Render the bring-the-humans-03 TikTok ad: 1080x1920, 16 s, 30 fps, H.264.
#
# Run from the repository root. The build assets live beside the repo in
# ../bring-the-humans-03-video/assets: the press-pack files (brand badge
# overlay and referral end card, fetched from https://make.fun/press/manifest.json
# and used as they are), the three scene stills made in the build session, and
# the Indonesian voiceover. The finished file goes to
# ../bring-the-humans-03-video/ad.mp4.
#
# Scenes: 0-5 s hook, 5-10.5 s what make.fun is, 10.5-16 s call to action.
# The press pack's own ffmpeg recipe lays the brand badge over the video from
# its first frame until the end card, puts the referral end card over the last
# 2.5 s (clip blurred + desaturated under it), and types the referral code
# into the card's field once the field rests.
set -euo pipefail

REPO="$(pwd)"
ASSETS="$(realpath -m ../bring-the-humans-03-video/assets)"
WORK="$(realpath -m ../bring-the-humans-03-video/work)"
OUT="$(realpath -m ../bring-the-humans-03-video/ad.mp4)"
CODE="z8qf6ayd"
FONT="$ASSETS/JetBrainsMono-Bold.ttf"
BADGE="$ASSETS/badge-9x16.png"
CARD="$ASSETS/endcard-9x16.webm"
VOICE="$ASSETS/voice.mp3"
HOOK="$ASSETS/media-generation-still-hook-0-01254e2c-80e1-41f3-b6a9-affc1a96c678.png"
CTA="$ASSETS/media-generation-still-cta-0-084979c2-3eaf-455f-931c-6916170a05e4.png"
BODY="$ASSETS/s2.png"

mkdir -p "$WORK"

# Scene frames at 1080x1920.
ffmpeg -y -v error -i "$HOOK" -vf "scale=1080:1920" "$WORK/s1.png"
ffmpeg -y -v error -i "$CTA" -vf "scale=1080:1920" "$WORK/s3.png"

# Scene clips with a slow Ken Burns move (30 fps).
ffmpeg -y -v error -loop 1 -i "$WORK/s1.png" \
  -vf "zoompan=z='1+0.00053*on':d=150:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30" \
  -t 5 -c:v libx264 -pix_fmt yuv420p "$WORK/v1.mp4"
ffmpeg -y -v error -loop 1 -i "$BODY" \
  -vf "zoompan=z='1.08-0.00049*on':d=165:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30" \
  -t 5.5 -c:v libx264 -pix_fmt yuv420p "$WORK/v2.mp4"
ffmpeg -y -v error -loop 1 -i "$WORK/s3.png" \
  -vf "zoompan=z='1+0.00049*on':d=165:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30" \
  -t 5.5 -c:v libx264 -pix_fmt yuv420p "$WORK/v3.mp4"

# Join the three scenes into one 16 s clip.
printf "file '%s'\nfile '%s'\nfile '%s'\n" "$WORK/v1.mp4" "$WORK/v2.mp4" "$WORK/v3.mp4" > "$WORK/list.txt"
ffmpeg -y -v error -f concat -safe 0 -i "$WORK/list.txt" -c copy "$WORK/clip.mp4"

# Final pass: badge from frame 0, end card over the last 2.5 s, code typed in.
T=13.5
ffmpeg -y -i "$WORK/clip.mp4" -c:v libvpx-vp9 -i "$CARD" -i "$BADGE" -i "$VOICE" -filter_complex "
[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,fps=30,format=yuva420p[base];
[base][2:v]overlay=enable='lt(t,$T)',format=yuva420p,split[clip][soft];
[soft]gblur=sigma=28,eq=saturation=0.35,fade=t=in:st=$T:d=0.8:alpha=1[soft];
[clip][soft]overlay[bg];
[1:v]format=yuva420p,setpts=PTS-STARTPTS+$T/TB[card];
[bg][card]overlay=eof_action=pass,
drawbox=x=208:y=1230:w=9:h=82:color=white:t=fill:enable='gte(t,14.933)',
drawtext=fontfile=$FONT:text=$CODE:fontsize=62:fontcolor=0x191419:x=210:y=1271-(ascent-descent)/2:enable='gte(t,14.933)'[v];
[3:a]atrim=0:13.5,apad=whole_dur=16[a]" \
  -map '[v]' -map '[a]' -c:v libx264 -pix_fmt yuv420p -crf 18 -c:a aac -movflags +faststart "$OUT"

echo "wrote $OUT"
