#!/usr/bin/env bash
# Splits wod-wiki-community into per-theme seed repos per SPLIT-PLAN.md.
# Usage: split-repos.sh <repo-name>   (creates/scaffolds one repo; no network)
set -euo pipefail
SRC=/home/serge/Projects/wod-wiki-seed
OUT=/home/serge/Projects
name=$1

case "$name" in
  wod-wiki-seed-core)          cols=""; feeds=""; extra="efforts equipment dashboards" ;;
  wod-wiki-seed-crossfit)      cols="crossfit-games crossfit-girls crossfit-heroes"; feeds="crossfit-programming"; extra="" ;;
  wod-wiki-seed-hyrox)         cols="hyrox"; feeds=""; extra="" ;;
  wod-wiki-seed-kettlebell)    cols="geoff-neupert girevoy-sport joe-daniels keith-weber steve-cotter"; feeds="dan-john-40-day"; extra="" ;;
  wod-wiki-youtube-dan-john)   cols="dan-john"; feeds=""; extra="" ;;
  wod-wiki-youtube-mark-wildman) cols="mark-wildman"; feeds=""; extra="" ;;
  wod-wiki-youtube-strongfirst) cols="strongfirst"; feeds=""; extra="" ;;
  wod-wiki-seed-swimming)      cols="swimming-college swimming-highschool swimming-masters swimming-olympic swimming-post-college swimming-pre-highschool swimming-triathlete"; feeds=""; extra="" ;;
  wod-wiki-seed-track)         cols="hs-track-400m hs-track-sprints"; feeds=""; extra="" ;;
  wod-wiki-seed-zombie-fit)    cols="zombiefit"; feeds=""; extra="" ;;
  wod-wiki-example-movement)   cols="unconventional"; feeds=""; extra="" ;;
  wod-wiki-example-yoga)       cols="yoga"; feeds=""; extra="" ;;
  wod-wiki-youtube-the-stone-circle) cols="the-stone-circle"; feeds=""; extra="" ;;
  wod-wiki-seed-golos-method)  cols="the-golos-method"; feeds=""; extra="" ;;
  wod-wiki-r-workoutroutines)  cols=""; feeds="workoutroutines-reddit"; extra="" ;;
  *) echo "unknown repo $name" >&2; exit 1 ;;
esac

dst=$OUT/$name
if [ -d "$dst" ]; then echo "SKIP $dst exists"; exit 0; fi
mkdir -p "$dst/markdown/collections" "$dst/markdown/feeds"
cd "$SRC"
cp -r .github "$dst/"
cp .gitignore CONTRIBUTING.md LICENSE package.json "$dst/"
cp -r scripts "$dst/"

for c in $cols;  do cp -r "markdown/collections/$c" "$dst/markdown/collections/"; done
for f in $feeds; do cp -r "markdown/feeds/$f"      "$dst/markdown/feeds/"; done
for e in $extra; do
  if [ -d "markdown/$e" ]; then cp -r "markdown/$e" "$dst/markdown/"; else cp "markdown/$e.md" "$dst/markdown/"; fi
done

python3 - "$dst/package.json" "$name" <<'EOF'
import json, sys
p, name = sys.argv[1], sys.argv[2]
pkg = json.load(open(p))
pkg['name'] = name
pkg['description'] = f"{name} — a Wod.Wiki community seed source: grouped notebooks validated and compiled into versioned seed artifacts by the wod CLI from @bitcobblers/wod-wiki-tools."
json.dump(pkg, open(p, 'w'), indent=2)
open(p, 'a').write('\n')
EOF

python3 - "$dst/README.md" "$name" "$cols" "$feeds" "$extra" <<'EOF'
import sys
dst, name, cols, feeds, extra = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
import os
rows = []
for c in cols.split():
    n = len([f for f in os.listdir(os.path.join(os.path.dirname(dst), 'markdown/collections', c)) if f.endswith('.md') and f != 'README.md'])
    rows.append(f"| `{c}` | collection | {n} |")
for f in feeds.split():
    base = os.path.join(os.path.dirname(dst), 'markdown/feeds', f)
    n = sum(len([x for x in files if x.endswith('.md')]) for _, _, files in os.walk(base))
    rows.append(f"| `{f}` | feed | {n} |")
for e in extra.split():
    p = os.path.join(os.path.dirname(dst), 'markdown', e)
    n = sum(len([x for x in files if x.endswith('.md')]) for _, _, files in os.walk(p)) if os.path.isdir(p) else 1
    rows.append(f"| `{e}` | reference | {n} |")
table = "| notebook | kind | items |\n|---|---|---:|\n" + "\n".join(rows)
open(dst, 'w').write(f"""# {name}

A Wod.Wiki community seed source — grouped workout notebooks, validated and
compiled into versioned seed artifacts by the `wod` CLI
([@bitcobblers/wod-wiki-tools](https://www.npmjs.com/package/@bitcobblers/wod-wiki-tools)),
published via GitHub Pages, and imported by the
[wod-wiki](https://github.com/bitcobblers/wod-wiki) app as an independent
seed source (own manifest, version, and sync checkpoint).

Split out of the [wod-wiki-community](https://github.com/bitcobblers/wod-wiki-community)
corpus; notebook chunk ids are unchanged so app-side sync state survives.

## Notebooks

{table}

## Layout

```
markdown/            the corpus (the only thing most PRs touch)
  collections/       named workout libraries — one dir per catalog, README + items
  feeds/             dated programming — feeds/<slug>/<yyyy-mm-dd>/<item>.md
dist/                build output (gitignored)
```

## Build & publish

```
npm install
npx wod build --out dist   # validate + compile (same gate the CI runs)
```

Pushes to `main` publish `dist/` to GitHub Pages
(.github/workflows/main.yml); PRs get a validation build + sticky report
(.github/workflows/pull-request.yml). The seed dir URL is
`https://<owner>.github.io/<repo>/` — `manifest.json` plus content-hashed
chunk files.
""")
EOF

cd "$dst"
git init -q -b main
git add -A
git commit -qm "Initial split from wod-wiki-community (SPLIT-PLAN.md)"
echo "OK $name"
