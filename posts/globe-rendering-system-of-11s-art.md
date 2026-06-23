---
title: Globe rendering system of Elevens
date: 2026-06-24
description: A deep technical dive into 11s.art — cosine-weighted spherical tiling, a GPU-compressed atlas pyramid with deterministic packing, the incremental bake engine and baker/serve split, and the deterministic orbital field for positionless slots.
---

11s.art renders 11,000 user images as tiles on a single rotating sphere, plus a field of positionless tiles orbiting it. Two hard constraints shape every decision in the system. The first is geometric: rectangular tiles laid on a sphere must stay visually uniform from equator to pole, where meridians converge and naive grids tear apart. The second is a rendering budget: 11,000 textured tiles must paint smoothly on a phone, where one-mesh-per-tile (11k objects, 11k draw calls, 11k textures, 11k downloads) is simply impossible. This post is about how both constraints are met — the math of the tiling, the GPU-compressed atlas pyramid the tiles are sampled from, the bake engine that produces it, the multi-machine architecture that serves it, and the deterministic orbital system for positionless slots.

## Cosine-weighted spherical tiling

The grid is fixed: $N = 11{,}000$ slots across $R = 64$ latitude rows. Each pole reserves a $\theta_{cap} = 10°$ cap, leaving $\theta_{usable} = 180° - 2\theta_{cap} = 160°$ of usable latitude on a sphere of radius $r = 5$. Rows are spaced uniformly in latitude, $\Delta\varphi = \theta_{usable}/R = 2.5°$, with row $i$ centered at

$$\varphi_i = 90° - \theta_{cap} - (i + 0.5)\,\Delta\varphi.$$

Equal columns per row would be wrong: circumference shrinks toward the poles as $C(\varphi) = 2\pi r \cos\varphi$, so a fixed column count would crush polar tiles into slivers. Instead each row's column count is made proportional to its circumference. With $S = \sum_{i} \cos\varphi_i$, the raw allocation is

$$c_i^{\text{raw}} = \frac{\cos\varphi_i}{S}\cdot N, \qquad c_i = \operatorname{round}\!\big(c_i^{\text{raw}}\big).$$

Rounding leaves a residual $\varepsilon = N - \sum_i c_i$ that must be reconciled exactly — the globe is *defined* to hold 11,000 slots. The correction sorts rows by $\cos\varphi_i$ descending (equator outward) and adjusts counts by $\pm 1$ along that order until $\varepsilon = 0$, so the absorbed error lands on the rows that can hide it best. The distribution is precomputed once into a table carrying, per row, its center latitude, column count, and cumulative position range $p_i^{\text{start}}, p_i^{\text{end}}$.

The result: the equatorial rows (30–31, at $\varphi \approx \pm 1.25°$) hold $\approx 243$ columns each — row 31 spans positions 5258–5500 — while the polar rows hold $\approx 48$, against a mean of $N/R \approx 172$. The uniformity is worth making exact rather than asserting. Tile height is constant,

$$h = \Delta\varphi\cdot\frac{\pi}{180}\cdot r\cdot s \approx 0.183,$$

with scale factor $s = 0.84$, and tile width is

$$w = \frac{2\pi r \cos\varphi_i}{c_i}\cdot s.$$

Because the allocation made $c_i \propto \cos\varphi_i$, the $\cos\varphi_i$ cancels and $w$ is nearly invariant — $\approx 0.109$ at the equator versus $\approx 0.107$ at the poles. Every tile carries the same $\approx 1.69{:}1$ aspect: the polar convergence isn't hidden, it's algebraically cancelled.

### Slot ↔ surface, both directions

A slot is a one-based integer $p \in [1, 11000]$. The forward map is two steps. First, a binary search over the row table finds the row whose range contains $p$ in $O(\log 64)$ — six comparisons. The intra-row column is $j = p - p_i^{\text{start}}$, and the longitude centers the slot in its cell:

$$\lambda = \frac{j + 0.5}{c_i}\cdot 360° - 180°.$$

Then the geographic-to-Cartesian transform, in Three.js's Y-up convention, with $\theta = 90° - \varphi_i$ and $\psi = \lambda + 180°$:

$$x = -r\sin\theta\cos\psi, \quad y = r\cos\theta, \quad z = r\sin\theta\sin\psi.$$

The reverse map is the one that matters for performance. Hit-testing a tap means converting a raycast point $P=(x,y,z)$ back to a slot, and the earlier renderer did it by brute force — an $O(N)$ scan allocating a vector per tile. The geometry inverts in closed form instead. With $d = |P|$, latitude is $\varphi = \arcsin(y/d)$; if $|\varphi| > 80°$ the tap is a pole interaction, not a slot. Longitude comes from inverting the forward transform: since $z/(-x) = \tan\psi$, we recover $\psi = \operatorname{atan2}(z, -x)$, normalize to $[0, 2\pi)$, and convert back to $\lambda$. The nearest row minimizes $|\varphi_i - \varphi|$ over 64 candidates, and the column is

$$j = \left\lfloor \frac{\lambda + 180°}{360°}\cdot c_i \right\rfloor,$$

clamped, giving $p = p_i^{\text{start}} + j$. Hit detection is $O(1)$ arithmetic. Nothing about a tile's location is stored anywhere — it is always recomputed, forward or backward, from $p$ alone. That property is the seed of everything that follows.

## One instanced mesh over a baked atlas

All purchased tiles draw as a single `InstancedMesh` of one shared unit quad. Each instance carries only two attributes: `aIndex` (its 0-based slot index) and `aTint` (a fallback color). The instance matrix places it at its surface point and orients it outward; the whole mesh is rebuilt only when the *set* of purchased positions changes (a sale), gated by a `tilesKey` string so the routine 30 s data poll never triggers a rebuild. Empty slots aren't objects at all — their outlines merge into one `LineSegments`, with a single reusable overlay repositioned to whichever empty tile is hovered. An inner occlusion sphere at $r - 0.06$ hides back-facing tiles bleeding through gaps; an invisible interaction sphere at $r$ is the raycast target.

The texture each instance samples comes from a baked atlas, and the GPU does the addressing itself. A custom GLSL3 `ShaderMaterial` re-derives each instance's atlas cell from `aIndex` *in the vertex shader*, using the exact packing the backend baker used — so placing 11,000 tiles into their atlas cells costs nothing on the CPU. The fragment shader samples the crisp level if its page is resident, falls back to the low-res floor, and falls back again to `aTint`. A tile degrades L1 → L0 → color and is never blank.

## The atlas pyramid

The atlas is a three-level level-of-detail pyramid. Each level is a hard visual floor for the one above, so a tile always has *something* to show while a sharper level streams in.

- **L0** — 32 px cells, **ETC1S**. A single 4096² page holds $\lfloor 4096/32 \rfloor^2 = 128^2 = 16{,}384$ cells, enough to cover all 11k tiles in one page that compresses to a few hundred KB. One fetch and the entire globe shows a low-res floor.
- **L1** — 128 px cells, **UASTC + zstd**. A page holds $\lfloor 4096/128 \rfloor^2 = 32^2 = 1{,}024$ cells, so $\lceil 11000/1024 \rceil = 11$ pages span the grid. This is the workhorse level at normal zoom.
- **L2** — full resolution, **never baked**. The frontend lazily overlays the original image ($\approx 640$ px) for the handful of tiles being looked at — the hovered tile and the front-facing tiles nearest screen-center below `detailZoom = 13` — LRU-bounded to $\le 32$ resident planes. A freshly approved image is overlaid optimistically and silently handed to the baked tile once its page lands, so new images appear in seconds, not after a bake.

The two atlas formats are a deliberate asymmetry. ETC1S is tiny and lower quality — acceptable for a floor. UASTC is larger but crisp, and zstd-supercompresses the otherwise-flat 16.7 MB UASTC payload by $\approx 40$–$50\%$ losslessly (ETC1S is already entropy-coded, so zstd is invalid there). Because the two levels use different formats, they cannot share a unified `sampler2DArray` and are bound as separate samplers: one L0 plus up to eleven L1, for 12 — comfortably under the WebGL2 `MAX_TEXTURE_IMAGE_UNITS` floor of 16. That budget is load-bearing: `ATLAS_MAX_L1_PAGES = 11`, and a misconfigured `GLOBE_ATLAS_TOTAL_SLOTS` that would need a twelfth L1 page makes the service **refuse to boot**, because those tiles would bake but never sample. One more detail with downstream consequences: each source image is resized into its square cell rather than cropped, so the atlas framing matches the L2 full-res framing exactly and there is no jump when a tile upgrades from atlas to overlay.

### Deterministic packing

A slot's place in the atlas is computed, never stored. For a one-based `position` and a cell size:

```
cellsPerRow  = PAGE_SIZE / cellSize          # PAGE_SIZE = 4096
tilesPerPage = cellsPerRow²
idx   = position - 1
page  = idx / tilesPerPage
cell  = idx % tilesPerPage
cellX = (cell % cellsPerRow) * cellSize
cellY = (cell / cellsPerRow) * cellSize
```

Because this is deterministic, the manifest the browser downloads lists only *which pages exist* — never where each of 11,000 tiles sits. There is no per-tile manifest. The cost is that this identical arithmetic now lives in three places that must stay in exact lockstep: the backend baker (`cell_coords`), the frontend packing module (unit-tested against a backend-generated fixture), and the GPU vertex shader. Any drift would silently map every tile past the first page to the wrong cell.

## The bake engine

The encoder is the KTX-Software `toktx` CLI (the basis-universal Rust crate can't reliably emit `.ktx2`), shelled out to and never blocking an HTTP request. The service holds three pieces of state, all behind `Arc`:

- **`version: u64`** — a monotonic counter, **seeded from the wall clock** at boot. Seeding from the clock rather than 1 guarantees that any `?v=` a browser or CDN cached from a prior run is strictly less than this run's versions, so a restart can never serve a stale page under a reused version.
- **`pages`** — a hot cache of encoded KTX2 bytes for pages baked or fetched this process. The raw 4096²×4 RGBA canvases ($\approx 67$ MB each) are transient, built during a bake and dropped, never held resident.
- **`present`** — the source of truth for what exists in storage, mapping each `(level, page)` to *its own* version. This is what drives both the manifest and per-page cache invalidation.

A `bake_lock` serializes every bake so a minutes-long boot bake and a concurrent incremental drain can't interleave into a torn `present` or duplicate version bumps. A bake runs either **full** (at boot) or **incremental** (on approval). Holding the lock, it probes the encoder, fetches sold slots once (paginated by *actual rows returned*, so Supabase's default `db-max-rows = 1000` can't silently truncate the globe past 1k sold), bumps `version` **once** for the whole run, then for each target page downloads its in-range images under bounded concurrency, decodes and resizes each into its square cell, stamps them into a fresh RGBA canvas on a blocking thread (CPU work kept off the async executor), and encodes with `toktx`. Empty L1 pages are skipped entirely — the frontend 404s there and falls back to L0 — but L0 is *always* baked so every tile has a floor. Pages upload to a stable key with `Cache-Control: immutable`; the `?v=` query, not the path, busts the cache. So an approval that dirties two pages invalidates exactly those two on the CDN, not the whole pyramid.

The encode is the heaviest step in the system. `toktx` runs with `--t2 --encode etc1s|uastc` and `--assign_oetf srgb`; internal mipmaps are **off**, because a gutterless packed atlas bleeds across cells at coarse mips and the L0/L1 pyramid already *is* the LOD. The **L0 ETC1S encode of a 4096² page needs $\approx 850$ MB of RAM** — the single reason the baker machine is provisioned at 2 GB. The subprocess carries a 180 s timeout and `kill_on_drop`.

### Persistence and crash safety

The only persisted shared state is a small JSON pointer in storage, written `no-cache`:

```
{ version, complete: bool, total_slots, pages: [[level, page, page_version], …] }
```

On boot the service either **hydrates** — if `complete == true`, `total_slots` matches, and pages exist, it loads `version` (clamped to at least the wall clock) and `present` and skips baking, so a restart is instant — or does a **full rebake** otherwise. The `complete` flag is the crash-safety mechanism: a full bake writes `false` *before* uploading any page and `true` only *after* the final pointer write. A hard kill between uploading pages and writing the pointer leaves `false`, so the next boot cleanly rebakes instead of hydrating a half-written set whose uploaded-but-unreferenced pages would render as invisible tiles. Incremental drains never write `false` — they only extend an already-complete set. An older two-tuple pointer (predating per-page versions) fails to deserialize and triggers a one-time full rebake that re-stamps every page, self-healing.

### Incremental drains: the dirty inbox

Approvals don't bake inline. An approval appends the slot's `position` to an **append-only `atlas_dirty` Postgres table**, and a loop on the baker drains it every $\approx 10$ s: read a batch oldest-first, record the **highest id seen** as a watermark, compute the distinct `(level, page)` set those positions touch, bake just those pages, and on success delete rows with `id <= watermark` in one statement. Rows inserted *during* the bake get higher ids and survive to the next tick. The append-only design — no unique constraint on `position` — is deliberate: a re-approval landing while a position's bake is in flight becomes a fresh higher-id row and re-bakes next tick, whereas a unique index would make it a no-op and the drain would then delete the only row, silently dropping the new image. Deleting by `id <= watermark` rather than an `IN (…)` list also keeps the delete request small at the batch cap.

## The baker/serve split

All of that coordination state — `version`, `present`, the dirty signal — originally lived in process memory, which silently locked the app to one machine: two instances would clobber each other's pointer, flap the version, and quote divergent price tiers. The fix is a role split. Exactly **one `baker`** is the sole writer — it bakes pages, owns the monotonic version, writes the pointer, and drains the inbox. **N `serve`** instances are read-only and never bake. The role comes from `ATLAS_ROLE`, falling back to the platform's injected process group. Three things make this safe across machines:

- **A cross-machine dirty signal.** Because an approval can land on any serve instance, "needs bake" is the `atlas_dirty` table, not an in-memory set — any instance appends, the single baker drains.
- **Serve re-hydration.** Serve instances poll the pointer every 10 s and adopt a newer published version, swapping in its `present` map. They serve the *raw* published version rather than one floored to each box's wall clock, so the whole fleet agrees on the manifest version and ETag — no flap.
- **DB-authoritative state.** The sold-slot count that drives pricing is read fresh from the database at quote time, not from a per-process counter that would diverge per machine.

Failover is simply that the platform restarts the baker; it hydrates from the pointer instantly and drains whatever accumulated in `atlas_dirty` while it was down, during which serving is unaffected — only newly approved images wait.

### Serving and the manifest

A page request hits the hot cache, else lazily downloads from storage if the page is in `present` (without re-caching — the fallback exists only for CDN edge-misses), else 404s. In practice browsers fetch pages straight from the CDN; the API route is only a fallback. The manifest is the contract the frontend renders against:

```
{ version, totalSlots,
  levels: [{ level, cellSize, pageSize, pageCount, tilesPerPage, format }],
  baseUrl,
  pages: [[level, page, version]] }
```

It is tiny, served `max-age=10` with an ETag derived from `version`, so a poll is a cheap `304`. The per-page versioning is the efficiency: one approval bumps only the version of the page(s) it changed, and the frontend — polling every 10 s — reloads only those.

## Hard-won failure modes

Several of the sharpest bugs are worth stating outright, because they are non-obvious and recurred:

- **The CSP must allow the Basis WASM transcoder.** KTX2 is decoded by Basis as WebAssembly in a `blob:` worker. The production CSP needs `'unsafe-eval'` (the emscripten glue calls `new Function()` — `'wasm-unsafe-eval'` alone is *insufficient*), `worker-src blob:`, and the CDN/storage hosts in `connect-src` (the worker fetches pages via XHR). Miss any and the zoomed-out atlas greys out while the zoomed-in L2 overlay — a plain image, no WASM — still works. That asymmetry is the diagnostic tell.
- **Color space.** `KTX2Loader` tags pages sRGB; the verbatim-write shader then renders them dark. The fix is to force `NoColorSpace` on load.
- **GLSL ES 3.00 sampler arrays need constant indices.** Indexing `uL1[i]` with a loop variable fails to link on Metal/ANGLE, and the tiles fall back to their tint. The fix is to unroll to literal `uL1[0]`, `uL1[1]`, …
- **404 and 429 on page loads are expected and silent.** A 404 is a skipped empty page (the tile falls back to L0); a 429 is the rate limiter under React StrictMode's doubled parallel loads. Both retry or degrade rather than error.

## Rendering positionless slots: the orbital field

A subset of slots carry no grid position and so cannot be placed on the surface at all. They are rendered as a separate particle system orbiting the globe — its own small, fully deterministic engine. Particles are organized into $L = 5$ concentric layers, each a group with a fixed pair of axis tilts (so the orbital planes intersect at different inclinations instead of reading as flat concentric rings) and an angular velocity following $\omega_l \propto 1/r_l$ — a Keplerian rule where inner shells sweep faster. That single proportionality produces parallax: inner tiles streak across the viewport while outer ones drift, giving depth without stereoscopy. Each layer's `rotation.y` is incremented by $\omega_l\,\Delta t$ per frame, and because the layers are children of the globe group, rotating the globe carries the whole field while the per-layer spin keeps turning underneath.

Determinism is the requirement — the field must be identical across reloads with no stored layout. Particles are distributed across layers by round-robin, $l = i \bmod L$, evenly spaced at base angle $\theta_j = (j/m_l)\cdot 2\pi$, then perturbed by a hash-based PRNG:

$$\operatorname{seededRandom}(s) = \operatorname{frac}\!\big(\sin(s\cdot 127.1 + 311.7)\cdot 43758.5453\big).$$

A particle's global index $g$ seeds three uncorrelated streams (via distinct multipliers): a vertical offset, a radial jitter off its nominal shell radius, and a breathing phase. The breathing drives a scale oscillation $\sin(t\cdot 0.6 + \varphi_{\text{breath}})\cdot 0.04$ — a $\approx 10.5$ s cycle whose staggered phases keep the field from pulsing in unison. All particles share one geometry (sized to the equatorial tile, row $\lfloor R/2 \rfloor = 32$) and the globe's URL-keyed texture cache, and each `lookAt`s twice its own position vector to face radially outward. Unlike the 11k surface grid — collapsed into a single instanced mesh — these stay individual meshes: the count is small, and each needs its own orbital transform and breathing scale.

## In one line

The whole system is one idea in several registers: store almost nothing that can instead be computed. A slot's place on the sphere, its cell in the atlas, the slot under a tap, a positionless tile's seat in orbit — all derived on demand from an index, which is what lets an 11,000-tile world collapse into a single instanced draw over a baked, incrementally-versioned, crash-safe pyramid served read-only across a fleet, with a deterministic field of positionless tiles orbiting around it.

View in [https://11s.art](https://11s.art)
