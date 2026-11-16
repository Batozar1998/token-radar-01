# Token Radar — build the best token launch radar

[![make.fun bounty](https://img.shields.io/badge/make.fun-bounty-2dd4bf)](https://make.fun/bounty/token-radar-01)
[![competition token-radar-01](https://img.shields.io/badge/competition-token--radar--01-0a1120)](https://make.fun/bounty/token-radar-01)
[![reward $1,325](https://img.shields.io/badge/reward-%241%2C325-gold)](https://make.fun/bounty/token-radar-01)

Entry for [token-radar-01](https://make.fun/bounty/token-radar-01) — build the
best token launch radar. It reads a sealed snapshot of every protocol
DefiLlama tracks, works out which ones still record no token and are not a
wrapped or staked product of one that trades, ranks them by what their
launch would be worth, and hands in a web dashboard showing the board, a
detail view for each protocol, and the steps to farm it.

## The model (radar-2)

```
implied = round( tvl_usd x category_multiple x growth_mult x maturity_mult )
```

- **category_multiple** — the median market-cap-to-TVL of the live-token
  protocols in the row's category, shrunk toward the global median (prior
  weight 3) and clamped to 0.05–0.50. A category with no live comparables
  takes the global median. Computed from the snapshot at run time; no
  category value and no protocol name is hardcoded.
- **growth_mult** — `1 + clamp(change_7d, -60, 120) / 100 x 0.5`.
- **maturity_mult** — `0.6 + min(age_days, 1095) / 1095 x 0.4`; age is the
  days from `listed_at` to the snapshot date (365 when unlisted).

The board ranks **198 pre-token protocols**: the whole 40-protocol
watchlist plus the 158 rankable protocols below the $50M floor. Wrapped,
staked and bridged products are excluded — a staked-ETH product never
ranks as a launch that has not happened yet. Protocols whose token already
trades are set aside in the Live view, with their market caps as reported,
and they are the comparables the multiples are calibrated on.

Full methodology, worked calibration and limits: [METHODOLOGY.md](METHODOLOGY.md).

## Run it

Node 22.18+ (standard library only — nothing to install):

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts --input <snapshot.json|directory>
```

It writes `out/board.json` (198 rows, each with an implied value and a
six-step farm plan), `out/data.js`, `out/dashboard/`, `out/screenshots/`
and `out/dossier.json`. The program is deterministic: two runs on the
same snapshot write the same bytes. It never touches the network.

## The dashboard

`dashboard/` is a static page that renders with no network. It shows:

- the board — all 198 rows, sortable, searchable, filterable by category,
  chain, TVL band and watchlist-only, with a top-5 spotlight;
- a detail view for every protocol — the model's four inputs, the implied
  value recomputed in the page, the category comparables behind its
  multiple, three data-derived watch flags, and its farm plan;
- the Live view — the 24 largest live-token protocols plus the category
  calibration table;
- the method, on the page.

## Layout

```
main.ts                  entrypoint (Node 22, stdlib only)
lib/model.ts             the radar-2 model, the board builder, the farm plans
vendor/makefun-board.ts  make.fun's dossier library, from the kit
dashboard/               index.html, app.css, app.js (static, no network)
screenshots/             1-board.png, 2-detail.png, 3-filtered.png
METHODOLOGY.md           the model, the calibration, the limits
BUILD-LOG.md             what was built, when, and what is left
```

## Status

Built 2026-11-16. Screenshots are taken from the dashboard in a browser;
see BUILD-LOG.md. Nothing here is a prediction that any token launches,
and nothing here is a recommendation to farm, buy or hold anything.

## License

MIT — see [LICENSE](LICENSE).
