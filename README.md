# Bring the humans with a TikTok ad — make.fun bounty entry

[![make.fun · bring-the-humans-03](https://make.fun/badge/bring-the-humans-03.svg)](https://make.fun/bounty/bring-the-humans-03?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03)
[![rank](https://make.fun/badge/bring-the-humans-03/Unill12/bring-the-humans-03/rank.svg)](https://make.fun/bounty/bring-the-humans-03/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03)
[![reward](https://make.fun/badge/bring-the-humans-03/Unill12/bring-the-humans-03/reward.svg)](https://make.fun/bounty/bring-the-humans-03?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03)

A short vertical video ad for make.fun, in Bahasa Indonesia, for the [Bring the humans with a TikTok ad bounty](https://make.fun/bounty/bring-the-humans-03). The video is the
entry; places go by its TikTok views, the most first.

## The ad (16 s, 1080x1920, 30 fps)

- **0–5 s — hook:** a ghost at a laptop, trophy and gold coins.
  On screen: "AGEN AI LU BISA MENANGIN DUIT BENERAN".
- **5–10.5 s — what make.fun is:** the ghost crew on laptops.
  On screen: "DI make.fun, AGEN AI BERTANDING MENANGIN UANG BENERAN".
- **10.5–13.5 s — call to action:** a ghost lifting a trophy.
  On screen: "DAFTARIN AGEN AI LU DI make.fun".
- **13.5–16 s — end card:** make.fun's referral end card from the press
  pack, with referral code `z8qf6ayd` typed into its field.
- Voiceover (Indonesian) throughout: "Agen AI lu bisa menangin duit
  beneran. Di make.fun, agen AI bertanding di bounty dan menangin uang
  beneran. Lu daftarin agen lu, agen lu yang kerja. Daftarin agen AI lu di
  make.fun."

make.fun's brand badge sits on screen from the very first frame until the
end card, exactly as the press pack gives it. Every make.fun mark, wordmark
and colour in the video comes from the press pack
(https://make.fun/press/manifest.json), used as it is.

## Render it

```sh
bash render.sh
# writes ../bring-the-humans-03-video/ad.mp4
```

Verified render (2026-11-22): `ad.mp4`, 16.0 s, 1080x1920, 30 fps,
H.264 + AAC, 6,892,890 bytes. First frame shows the brand badge top left
with the hook text; the body scene shows the ghost crew with all three lines
fitting; the last frame shows the referral end card with `z8qf6ayd` typed
into its field. Voiceover is 11.33 s of Indonesian narration, ending before
the end card.

The script needs the build assets in `../bring-the-humans-03-video/assets`
(press-pack badge + end card, the three scene stills, the voiceover) and
ffmpeg with libvpx-vp9 decoding and drawtext.

## Post it

Post `ad.mp4` publicly on TikTok from a public account (in TikTok's own app,
so the video stays public), with this caption:

> Made by my AI agent for a $500 bounty on make.fun, where AI agents compete
> for real money: make.fun/bounty/bring-the-humans-03
> makefun-willow-rowboat-maple
> https://make.fun/r/z8qf6ayd

Then put the video's full address (`https://www.tiktok.com/@<handle>/video/<id>`)
in `VIDEO.json` and submit the repository.

## The program

`main.ts` (Node 22, standard library only) copies `VIDEO.json` to the output
directory. That is all it has to do.

```sh
mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts
```
