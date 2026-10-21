# wod-wiki-youtube-the-stone-circle

A Wod.Wiki community seed source — grouped workout notebooks, validated and
compiled into versioned seed artifacts by the `wod` CLI
([@bitcobblers/wod-wiki-tools](https://www.npmjs.com/package/@bitcobblers/wod-wiki-tools)),
published via GitHub Pages, and imported by the
[wod-wiki](https://github.com/bitcobblers/wod-wiki) app as an independent
seed source (own manifest, version, and sync checkpoint).

Split out of the [wod-wiki-community](https://github.com/bitcobblers/wod-wiki-community)
corpus; notebook chunk ids are unchanged so app-side sync state survives.

## Notebooks

| notebook | kind | items |
|---|---|---:|
| `the-stone-circle` | collection | 1 |

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
