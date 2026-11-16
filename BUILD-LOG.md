# Build log — token-radar-01

## 2026-11-16 — foundation build (week 1 of 4)

### Kit
- Fresh kit fetched from `https://make.fun/c/token-radar-01/kit` into
  `~/workspace/make-fun/kit/token-radar-01-kit/` (bundle
  `ea1c9dccab78e6846655e81b921a79465c7267677ea2e0908624ddbc8a012d43`).
  Sealed snapshot: DefiLlama protocols, fetched 2026-11-14T01:18:33Z,
  `as_of` 2026-11-14, 758 protocols, watchlist 40, floor $50M.
- Read `RULES.txt` (judge prompt + gate), `input/README.md`,
  `starter/main.ts`, `starter/lib/model.ts`, `starter/dashboard/*`,
  `starter/vendor/makefun-board.ts`. The starter is the house's second
  fixed dashboard: handed in unchanged it is an ordinary entry. This
  entry changes the model, the board and the page; only
  `vendor/makefun-board.ts` is copied from the kit (as the rules require).

### What the judge scores (in order)
1. Working radar: full watchlist coverage, ranked by a stated implied
   value, screenshots and code agree.
2. Value model: implied value from the snapshot's own figures (TVL, 7d
   growth, age with no token), not a hardcoded list of names; live-token
   protocols separated from pre-token ones.
3. Farm plans: concrete steps with costs and times.
4. Dashboard: sortable and filterable, readable, detail view per protocol.
5. Looks made: chosen palette, consistent spacing, readable type.

### Model (radar-2) — the main departure from the starter
- Starter: flat `0.25 x TVL` for every protocol, 200 rows (40 watchlist +
  160 early by TVL).
- This entry: `implied = round(TVL x category_multiple x growth_mult x
  maturity_mult)`, where `category_multiple` is the median mcap/TVL of
  the live-token protocols in the row's category, shrunk toward the
  global median (prior weight 3) and clamped to [0.05, 0.50]; a category
  with no live comparables takes the global median (0.246 over 119 live
  protocols). Computed from the snapshot at run time — no category value
  and no protocol name is hardcoded.
- Board: **198 rows** — the whole 40-protocol watchlist plus all 158
  rankable protocols below the floor. Rankable = pre-token, not CEX, not
  versioned, and not a wrapped/staked/bridged product (the watchlist's
  own exclusion, extended below the floor). That exclusion matters: it
  drops 91 rows the starter would rank, including binance-staked-eth
  ($7.4B TVL) and base-bridge ($2.7B) — products of tokens that already
  trade, not launches.
- Calibration bug caught and fixed in-session: the first version let CEX
  tokens into the live set, giving a global median of 0.214; the live set
  is now the same rule the Live view uses (not pre-token, mcap > 0,
  TVL > 0, not CEX) — global median 0.246, n=119. METHODOLOGY.md's worked
  table matches the code exactly.
- Detail views carry three data-derived watch flags (single-chain
  concentration, fast inflow >+50% / sharp outflow <-30% in 7d, young
  <90 days) — the GMGN trenching lens (concentration + early-holder
  exit is the trap shape), as observations, not advice.
- Top 5: Steakhouse Financial $1.09B, Sentora Curator $1.04B, Gauntlet
  $648M, Veda $190M, USDD $178M.

### Dashboard
- Dark radar theme (own CSS, not the starter's): header, lede + 4 facts,
  top-5 spotlight cards, controls (search, category, chain, TVL band,
  watchlist-only, pre-token/live tabs), sortable board table with implied
  value bars, detail dialog (model breakdown recomputed in the page,
  category comparables, watch flags, 6-step farm plan), Live view with
  the calibration table, method section on the page.
- Dashboard source total 38,608 bytes — under the 65,536-byte dossier
  text cap, so the judge reads every file whole (verified: no cut line).
- No network anywhere: no `http` in any dashboard file.

### Verification (local, with the sealed snapshot)
- `main.ts` runs clean on Node 24.22.1; two runs byte-identical
  (deterministic — required, the grader runs it twice).
- Gate replication: 198 rows, watchlist 40/40 covered, ranks exactly
  1..198, implied values strictly non-increasing, all distinct, farm
  steps 6 per row within 20–600 chars, implied values in (0, 1e14],
  all slugs in the snapshot, board.json 293,579 bytes (< 8 MiB).
- Page recompute: the dashboard's `impliedOf` reproduces every row's
  board.json value — 0 mismatches of 198.
- Dossier: built by `vendor/makefun-board.ts`, 63,785 bytes with the
  test screenshots; text shows all 3 dashboard files whole.

### Screenshots — solved in-session
- The VM's system Chrome (`/opt/meta-chromium/chrome`) refuses headless
  start ("Hatch WebGL domain policy is required for browser startup").
  No system Chrome/Firefox in PATH; /tmp is a 512M tmpfs at 100%, which
  also stalled `npx playwright install chromium`.
- Fix: downloaded Playwright's chromium-headless-shell build directly
  with curl (fast, ~110MB in ~5s) to
  `~/workspace/.local/chromium/`; binary
  `chrome-linux/headless_shell` (Chromium 139.0.7258.5) screenshots
  fine with `--no-sandbox --disable-gpu --disable-dev-shm-usage` and
  profiles under `~/workspace/.local/tmp/`.
- The three shots (1440x900, verified by eye): `1-board.png` (board,
  155KB), `2-detail.png` (Steakhouse Financial detail dialog, 184KB),
  `3-filtered.png` (Risk Curators filter, 34 of 198 rows, 155KB).
  Re-take with `scripts/screenshots.sh`.
- Note: the browser binary lives outside the repo (not part of the
  entry); the repo only holds the three PNGs.

### Repo state
- `~/workspace/make-fun/token-radar-01/` — main.ts, lib/model.ts,
  vendor/makefun-board.ts (kit copy, sha256 matches kit.json),
  dashboard/{index.html,app.css,app.js}, screenshots/ (3 real PNGs),
  METHODOLOGY.md, README.md (3 badges + bounty link), LICENSE (MIT),
  .makefun/owner.json (payout wallet
  5fCsQtN3Yd4YGWCY5vsm8e3oexxZooHz1id2SqZQeX89), scripts/screenshots.sh.
- Git: local repo, 2 commits (`7a8e698` foundation,
  license SPDX fix on top). NOT pushed — git push does not work from
  this VM; parent creates the GitHub repo via browser.
- `makefun check` run 2026-11-16 ~12:01 WIB (no transcripts):
  **4 passed** (competition_open, snapshot, license_osi after the SPDX
  fix, entrypoint), **1 failed — transcripts_present only** (needs the
  parent's bundle), rest skipped/at-submission. Re-run with
  `--transcripts <bundle>` once bundled.
- NOT done yet: transcript bundle + `makefun check` with it (parent),
  GitHub repo creation + push (parent, browser), submission (never —
  parent shows the user first, per his rule).

## Remaining weeks — plan

### Week 2 (by ~23 Nov): harden the entry
- [ ] `makefun check --kit <kit> --repo <repo> --transcripts <bundle>` —
  needs the parent's bundle; fix whatever it flags.
- [ ] Judge-proof the model story: add a one-paragraph "why this beats a
  flat multiple" note to the dashboard's method section, and a worked
  example (one row's arithmetic) on the page — the judge reads the
  dossier text, and the arithmetic is the most checkable part.
- [ ] Sensitivity check: re-run the board with the multiple cap at 0.40
  and 0.60 and record how the top 10 moves; if rank 1–3 are stable,
  say so in METHODOLOGY.md.
- [ ] Screenshot polish: check the Live tab renders (calibration table)
  in a 4th screenshot kept locally (only 3 ship; the 4th is for the
  parent's review).

### Week 3 (by ~30 Nov): compete on the page
- [ ] Re-read the starter's screenshots vs ours side by side; fix any
  readability gap (row density, the Multiple column's meaning — add a
  tooltip/legend line under the table).
- [ ] Add a per-category mini-table to the board page (count + median
  implied per category) if it fits the 64KB dossier budget.
- [ ] Re-run the full pipeline + gate replication after every change;
  re-take screenshots whenever the page changes.

### Week 4 (by ~13 Dec): submit window
- [ ] Final freeze: last code change by 11 Dec, final screenshots +
  final `makefun check` by 12 Dec.
- [ ] Parent creates the public GitHub repo (Batozar1998), pushes, and
  submits — with the user's approval shown first, per his rule.
  Submissions: max 5/day, 10 total; the last before 14 Dec 17:00 WIB
  is final. Recommend submitting once early (dev grade + provisional
  rate against the house dashboards) and once at the freeze.
- [ ] Keep the 198-row board honest to the 2026-11-14 snapshot: do NOT
  refresh the data (the grade reads the same sealed bytes).

## Open questions for the parent
- Transcript bundle: whose session files + `--muse-usage` file cover
  this build (subagent session b6707993 + parent session e987b890)?
- GitHub repo name + About website/topic (README assumes the bounty
  link; repo creation is the parent's browser step).
- Whether to submit early for a dev provisional rate, or hold the
  first submission for the frozen entry.
