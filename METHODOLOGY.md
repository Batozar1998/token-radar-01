# Token Radar — methodology (model radar-2)

Snapshot: DefiLlama `https://api.llama.fi/protocols`, fetched 2026-11-14
(`as_of` 2026-11-14, 758 protocols at or above $5M TVL). Nothing in this
document is fetched live: every number below is computed from that one
sealed file by `lib/model.ts`. The entry re-derives everything from the
snapshot at run time, so the grade's run and any re-run agree byte for byte.

## 1. Who is on the board

A protocol is **pre-token** when its DefiLlama record carries no token at
all: `mcap_usd`, `gecko_id` and `symbol` are all null. A protocol is
**rankable** when it is pre-token, its category is not `CEX`, and its name
does not end in a version marker (` V2`, ` v2`, ` 2.0` and the like) — a
versioned name is a pool of another protocol, not a protocol of its own.

The board ranks **every rankable protocol: 198 rows**. That is the whole
40-protocol watchlist (every protocol at or above the $50M floor that is
pre-token and is not a wrapped, staked or bridged product of a token that
already trades) plus the 158 rankable protocols below the floor. The
watchlist is the floor, never the ceiling: the early radar exists to find
the protocols below it.

Wrapped, staked and bridged products are excluded the same way the
watchlist is built: the house's list already leaves them out, and the
model additionally refuses any rankable row whose category is `Bridge`,
`Canonical Bridge`, `Liquid Staking`, `Liquid Restaking`, `Restaked BTC`
or `CEX`, or whose name carries a whole word `wrapped`, `staked` or
`staking`. (In this snapshot the extra filter removes nothing beyond the
versioned/CEX rule — it is stated so the rule survives a new snapshot.)

Protocols whose token already trades are **not ranked**. They are set
aside in the Live view with their market caps as DefiLlama reports them,
and — this is the point of the model — they are the comparables the
implied value is calibrated against.

Say it as the snapshot says it: a protocol **records no token**. DefiLlama's
record is not proof a token does not exist; it is proof none is recorded.

## 2. Implied value

```
implied = round( tvl_usd x category_multiple x growth_mult x maturity_mult )
```

### category_multiple — what the market pays for this kind of protocol

For each category, take every live-token protocol in that category with a
market cap and a TVL above zero, and take the **median of
mcap_usd / tvl_usd**. Medians, not means: one outlier (a prediction market
at 400x in this snapshot) must not set the price of its whole category.
Small categories are shrunk toward the global median so a category with
one or two live tokens does not inherit their noise:

```
multiple_raw = (n x median + 3 x global_median) / (n + 3)
multiple     = clamp(multiple_raw, 0.05, 0.50)
```

`global_median` is the median mcap/TVL over all live-token protocols
(0.246 in this snapshot, over 119 live protocols). A category with no live comparables at all
(CeDeFi, Insurance, Stablecoin Wrapper, Collateral Markets here) gets the
global median. The multiple is computed from the snapshot at run time;
no category value and no protocol name is hardcoded. The dashboard's Live
view prints the table — category, n, median, multiple used — so any reader
can check the calibration.

Worked calibration in this snapshot (medians before shrinkage/clamp):

| Category | n | median mcap/TVL | multiple used |
| --- | --- | --- | --- |
| Dexs | 11 | 0.342 | 0.32 |
| RWA | 9 | 0.275 | 0.27 |
| Lending | 15 | 0.132 | 0.15 |
| Yield | 9 | 0.191 | 0.21 |
| Basis Trading | 7 | 0.654 | 0.50 (capped) |
| Risk Curators | 1 | 2.975 | 0.50 (capped) |
| Onchain Capital Allocator | 2 | 0.012 | 0.15 |
| (no live comps) | 0 | — | 0.25 (global) |

### growth_mult — is capital arriving or leaving

```
growth_pct  = clamp(change_7d, -60, +120)   (0 when unreported)
growth_mult = 1 + growth_pct / 100 x 0.5
```

A protocol up 40% in a week scores 1.20x; one down 40% scores 0.80x.
The clamp keeps one wild week from deciding the board.

### maturity_mult — how long it has run with no token

```
maturity_mult = 0.6 + min(age_days, 1095) / 1095 x 0.4
```

`age_days` is the days from `listed_at` to the snapshot date; 365 when
unlisted. A protocol listed three years ago scores 1.00x; a three-month-old
one scores about 0.63x. Age is the only record of how long a protocol has
run with no token, and a launch after years of operation is worth more
than a launch after a season — but the floor of 0.6 keeps young
protocols on the board instead of zeroing them.

### What the model does not do

It does not predict whether or when a token is issued — a launch is a
decision by a team, not a function of TVL. It does not use any price,
volume, social signal or off-snapshot data. It does not special-case any
protocol by name: the same function scores all 198 rows, and the
dashboard recomputes each row's implied value in the page and says
whether it matches the number `board.json` carries.

## 3. Reading the board like a trencher

Gor's GMGN trenching lens, applied to launches instead of meme coins
(`~/workspace/gmgn-trenching-checklist.md`): a clean contract is not
enough — what matters is who holds the supply and whether the big holders
are selling. A token launch has the same shape of risk, so each detail
view carries three data-derived flags, computed from the snapshot alone:

- **Single-chain concentration** — the protocol's TVL sits on one chain
  only. One chain means one point of failure and one team-controlled
  venue, the same concentration risk as a top-10 holder share over 30–40%.
- **Fast inflow** — 7-day TVL growth above +50%. Capital arriving that
  fast can leave that fast; the GTAVI lesson is that holders piling in
  while the early wallets exit is the trap shape.
- **Young protocol** — listed under 90 days ago. Too little history to
  judge; a launch this early is the highest-variance bet on the board.

Flags are observations about the snapshot, not advice. Nothing here is a
recommendation to buy, farm or hold anything, and no money moves.

## 4. Farm plans

Every row carries six steps, derived from the protocol's own record
(category, chains, TVL, age) — never from a hand-written list of names:

1. Wallet hygiene (fresh wallet, seed offline).
2. The category's one qualifying action, with a capital tier from TVL
   ($250 at $5B+, $150 at $1B+, $100 at $100M+, $50 below) on the
   protocol's first listed chain.
3. One qualifying action a week.
4. Hold at least 30–60 days (longer for younger protocols) so the
   activity spans more than one snapshot.
5. Claim only from the link the protocol itself publishes; never pay to claim.
6. Keep a farm log (wallet, dates, transactions).

Each step states what it costs and how long it takes. A farm plan is a
checklist for a reader who decides to farm; it is not a promise of an
airdrop, and a protocol may never issue a token.

## 5. What the dashboard shows

- **Board** — all 198 pre-token rows, sortable by implied value, TVL,
  7-day growth and age; searchable; filterable by category, chain, TVL
  band and watchlist-only.
- **Detail view** — every protocol: TVL, growth, age, the model's four
  inputs and the implied value recomputed in the page, the category
  comparable behind its multiple, the three flags, and its farm plan.
- **Live view** — the 24 largest live-token protocols by market cap, plus
  the category calibration table the multiples come from.
- **Method** — the formula, the calibration table and the flags, on the page.

## 6. Limits

- The snapshot is one day (2026-11-14). TVL, growth and age are that
  day's figures; a protocol may have launched, rugged or shut down since.
- `listed_at` is when DefiLlama began tracking a protocol, not when it
  launched; age is an approximation.
- A category multiple is a median of other protocols' market caps. It
  says what the market pays for that kind of protocol today, not what any
  single launch will be worth.
- Farm plans assume the protocol's own app is usable and honest. A
  protocol can change its terms, add a points program, or never issue a
  token. Verify on the protocol's own page before depositing anything.
