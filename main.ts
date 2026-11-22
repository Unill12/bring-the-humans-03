// bring-the-humans-03 entry (Node 22, standard library only).
//
// The program's only job is to hand VIDEO.json to the grader: it copies the
// file from this repository's root into the output directory. The video
// itself is the entry, and nothing this program writes about it is scored.
//
// VIDEO.json is resolved from this file's own directory (import.meta.url),
// never from the working directory, so the copy works wherever the grader
// runs it from. The output directory comes from MAKEFUN_OUTPUT_DIR and
// defaults to /output.
//
// Local check:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(fileURLToPath(import.meta.url));
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";

mkdirSync(outputDir, { recursive: true });
copyFileSync(join(repoRoot, "VIDEO.json"), join(outputDir, "VIDEO.json"));
console.log("VIDEO.json copied to", join(outputDir, "VIDEO.json"));
