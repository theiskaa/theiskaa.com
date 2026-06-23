---
title: Globe rendering system of Elevens
date: 2026-06-24
description: How 11,000 images tile a 3D sphere, render in roughly one draw call over a baked atlas pyramid, and how wish slots orbit the globe as debris in 11s.art
---

11s.art is a globe of 11,000 purchasable slots. Each slot can hold a user's image, and all of them live on the surface of a single rotating sphere, wrapped in a slow field of floating "wish" tiles. Two problems sit underneath that picture, and almost every decision in the system comes from one of them. The first is geometry: how do you tile rectangular images across a sphere so they stay evenly dense from the equator to the poles, instead of bunching up where the meridians converge? The second is budget: how do you draw all 11,000 tiles at once, smoothly, on a phone?

This post walks through the math that answers the first, the rendering architecture that answers the second, and the design choices that make the result feel like a place rather than a grid.

## Tiling a sphere without crowding the poles

The globe holds a fixed $N = 11{,}000$ slots spread across $R = 64$ latitude rows. Each pole reserves a $\theta_{cap} = 10°$ cap for special content, leaving $\theta_{usable} = 180° - 2\theta_{cap} = 160°$ of usable latitude. The sphere has radius $r = 5$ units.

The obvious approach — the same number of columns in every row — breaks immediately. A row near a pole has a much smaller circumference than a row at the equator, so giving them equal column counts would squeeze the polar tiles into thin slivers. The fix is a cosine-weighted distribution, built on the fact that the circumference at latitude $\varphi$ is

$$C(\varphi) = 2\pi r \cos(\varphi).$$

Rows are spaced evenly in latitude, $\Delta\varphi = \theta_{usable}/R = 2.5°$, with row $i$ centered at

$$\varphi_i = 90° - \theta_{cap} - (i + 0.5)\,\Delta\varphi.$$

Each row then gets a column count proportional to its circumference. Summing $S = \sum_i \cos(\varphi_i)$ over all rows, the raw allocation for row $i$ is

$$c_i^{\text{raw}} = \frac{\cos(\varphi_i)}{S}\cdot N,$$

which is rounded to an integer $c_i$. Rounding leaves a small error $\varepsilon = N - \sum_i c_i$, corrected by sorting rows from the equator outward and nudging counts by $\pm 1$ until the total lands exactly on 11,000.

The result is visible in the numbers. The equatorial rows hold about **243** columns each; the polar rows hold only about **48**. Yet because the column count _and_ the available circumference both scale with $\cos(\varphi)$, every tile ends up nearly the same shape — uniform height, and a width of $\approx 0.109$ units at the equator versus $\approx 0.107$ at the poles. The aspect ratio stays essentially constant everywhere. The crowding doesn't get hidden; it gets cancelled.

This distribution is computed once into a table that also stores each row's cumulative position range, $p_i^{\text{start}}$ and $p_i^{\text{end}}$, so a slot's row can later be found by binary search.

### From a slot number to a point in space

A slot is just a one-based integer $p \in [1, 11000]$. Turning it into a point on the sphere is two steps.

First, **slot to geographic coordinate.** A binary search over the row table finds the row $i$ whose range contains $p$, in $O(\log 64)$ — six comparisons. The column within the row is $j = p - p_i^{\text{start}}$, and the longitude centers the slot in its cell:

$$\lambda = \frac{j + 0.5}{c_i}\cdot 360° - 180°.$$

Second, **geographic to Cartesian**, the standard transform in Three.js's Y-up convention, with polar angle $\theta = 90° - \varphi_i$ and azimuth $\psi = \lambda + 180°$:

$$x = -r\sin\theta\cos\psi, \quad y = r\cos\theta, \quad z = r\sin\theta\sin\psi.$$

The negation on $x$ is just coordinate-system handedness.

### Reversing the map for free hit-testing

The same geometry runs backwards to answer "which slot did the user tap?" Given a raycast hit point $P = (x, y, z)$ with magnitude $d = |P|$, latitude falls straight out as $\varphi = \arcsin(y/d)$; if $|\varphi|$ is past the $80°$ pole threshold, the tap is a pole interaction rather than a slot. Longitude inverts the forward transform through $\psi = \operatorname{atan2}(z, -x)$, the nearest row comes from a short scan, and the column is recovered by flooring back through the longitude formula.

This matters more than it looks. The first version brute-forced every tile to find the closest one — $O(N)$ per click, allocating a vector per tile. The geometric inverse is **$O(1)$**: a tap resolves to a slot with pure arithmetic, no iteration over 11,000 candidates. The globe never stores where anything is, because it can always compute it.

## Drawing 11,000 tiles at once

The geometry tells us where each tile goes. The budget tells us we can't treat 11,000 tiles as 11,000 separate things.

The first renderer did exactly that — one textured mesh per slot. That is 11,000 scene objects, 11,000 draw calls, 11,000 image downloads, and 11,000 GPU textures. It is simply impossible on mobile. The current architecture replaces all of it with one instanced mesh sampling a compressed texture atlas.

### One mesh, one draw call

Every purchased tile is a single instance of one shared unit quad, drawn as a single `InstancedMesh`. Each instance carries only two small attributes: its slot index and a fallback tint color. Its transform — placing it on the surface and orienting it outward — is built once from the geometry above, and the whole mesh is rebuilt only when the _set_ of purchased slots actually changes (a sale), never on the routine background poll. Empty, unpurchased slots aren't objects at all: their outlines are merged into one `LineSegments`, with a single reusable highlight overlay moved to whichever empty tile is hovered. The entire surface ends up rendering in roughly **one instanced draw call**, plus one line draw for the empties.

### A level-of-detail pyramid, baked once

The images themselves live in a three-level level-of-detail pyramid, baked on the server into GPU-compressed texture pages. Each level is a hard visual floor for the one above it, so a tile is never blank while something sharper streams in.

The bottom level, **L0**, uses 32-pixel cells in the small ETC1S format. A single 4096-pixel page holds $128^2 = 16{,}384$ cells — enough to cover the whole globe — and compresses to a few hundred kilobytes, so one fetch is enough for the entire world to show _something_. The middle level, **L1**, uses crisper 128-pixel cells (UASTC, zstd-compressed); at 1,024 cells per page it takes about eleven pages to span the grid, and it's the level you actually browse at. The top level, **L2**, is never baked at all — the frontend lazily overlays the real, full-resolution image over only the handful of tiles under the cursor or near screen-center when zoomed in, capped to a small resident set. That's why a zoomed-in tile is razor-sharp while the zoomed-out floor stays cheap.

The fragment shader prefers L1 if its page is loaded, falls back to the L0 floor, and falls back again to the flat tint. A tile degrades L1 → L0 → color and is never empty.

### A tile's place in the atlas is computed, not stored

The key property of the atlas is that a slot's position _inside_ it is pure arithmetic. For a one-based position and a cell size, the page is $\lfloor (p-1) / \text{tilesPerPage} \rfloor$ and the cell within that page is $(p-1) \bmod \text{tilesPerPage}$, where $\text{tilesPerPage} = (\text{pageSize} / \text{cellSize})^2$. The cell's pixel coordinates follow directly.

Because that mapping is deterministic, the manifest the browser downloads only has to say _which pages exist_ — never where any of the 11,000 tiles sits. There is no per-tile lookup table to ship. The catch is that this same arithmetic now lives in three places that must stay in lockstep: the backend baker, the frontend packing module, and the GPU vertex shader, which re-derives each instance's atlas cell straight from its index so the GPU places every tile for free. Any drift between the three would silently send every tile past the first page to the wrong cell, so the frontend's copy is unit-tested against a fixture generated by the backend.

### Keeping it live without re-baking the world

Approvals don't rebuild the pyramid. When a new image goes live, its slot's position is appended to an append-only queue, and a background process bakes only the one or two pages that position touches — seconds of work instead of the minutes a full bake costs. Each page carries its own version number, so a single approval invalidates only the page(s) it changed on the CDN, and the frontend re-fetches just those. Crash safety comes from a single `complete` flag in the persisted pointer: a full bake writes `false` before uploading any page and `true` only after everything lands, so a process killed mid-bake cleanly rebuilds on restart instead of serving a half-written globe. A freshly approved image is even overlaid optimistically on the client the moment it's approved, then quietly handed off to the baked tile once the page lands — so it shows up in seconds, not after the bake.

## Camera, motion, and touch

A correct globe that feels dead is a failure, so the interaction layer is tuned for physicality.

The camera is a perspective camera pulled back along the Z axis, and its distance doesn't snap — it eases exponentially toward its target each frame, $z \mathrel{+}= (z_{\text{target}} - z)\cdot 0.08$, so every zoom decelerates into place. Rotation is stored as two Euler angles: vertical tilt is clamped to just under $\pm 82°$ to stop the globe flipping over a pole, while horizontal spin is unbounded and wraps naturally. A drag converts pointer motion into angular velocity scaled by the current zoom — you rotate more gently when zoomed in — and on release that velocity decays by $0.94$ per frame, an inertial spin that coasts to a stop. Left alone, the globe drifts into a slow idle rotation.

Hovering a purchased tile makes it pop: the instance's transform is recomposed each frame toward $1.4\times$ scale and a quarter-unit lift along its surface normal, and its sharp L2 overlay is glued to the same popped transform so the crisp image rides on top of the magnified low-res cell instead of lagging behind it. On exit it lerps back and snaps home.

Touch is a small state machine over an active-pointers map. A gesture only counts as a _click_ if it travelled under 10 px, drifted under 15 px total, and was held under 300 ms — otherwise it's a drag or a two-finger pinch driving zoom. And because the geometry from the first section is invertible, a confirmed click resolves through a clean priority cascade — orbital tiles first, then the globe surface, then the pole regions, then the specific slot — all with $O(1)$ math and no per-tile hit-testing anywhere.

## Wishes in orbit

Not every slot lives on the surface. **Wish slots** have no fixed grid position, so they don't sit on the globe — they orbit it, as a slow field of floating tiles. The orbital field and the wish ritual are two halves of one idea, so they're worth telling together.

A wish can only be made at **11:11**, morning and night, in the user's own local time. The whole mechanism is a three-phase state machine computed purely from the clock. The _active_ phase is the 60-second window when the hour is 11 or 23 and the minute is exactly 11; the pole display counts down from 60. The _teaser_ phase is the minute before — a one-minute warning that the door is about to open. Everything else is _idle_, showing only a long countdown to the next window, which is plain modular arithmetic: express "now" as milliseconds since midnight, compare against the two daily targets (rolling a passed one forward by 24 hours), take the minimum, and format it so the precision tightens as the moment approaches — `7h 23m`, then `45m 12s`, then a bare `30s`.

The engineering grace note is the scheduler. Polling the clock every second through twelve idle hours would be wasteful, so the timer is adaptive: while idle it computes the milliseconds until the next teaser and sleeps with a single long timeout (capped at an hour to bound drift), only switching to a one-second interval once a window is near. The timer sleeps through almost the entire half-day and wakes just in time. Timezone validation is deliberately loose — 11:11 means a different absolute instant for different people, and that's the point. It's a personal synchronization, a ritual rather than a global event: the narrow window asks for presence, the teaser builds anticipation, the countdown keeps it in the back of your mind all day. A completed wish mints a tile with no grid position and no equity, and generates a one-off keepsake image for it — a tall, phone-shaped canvas with a procedurally chosen palette, a scattered star field, a soft glow, the `11:11` header, and the wish text auto-scaled to fit.

Because wish tiles have no surface position, they're rendered as orbiting debris — and that's where a second little physics engine lives. The field is organized into $L = 5$ concentric layers, each with its own radius, a pair of axis tilts, and an angular velocity. The tilts matter: if every layer shared an orbital plane the field would read as flat concentric rings, so the inclinations are staggered to give it real volume. The angular velocities follow a deliberately Keplerian rule, $\omega_l \propto 1/r_l$ — closer shells sweep faster, outer shells drift slowly. That single proportionality is what produces parallax: inner tiles streak across the view while outer ones barely move, and the eye reads depth without any stereo trick. Each layer is a group whose tilt is fixed at construction and whose spin is incremented every frame; because the layers are children of the globe, dragging the globe carries the whole field with it while the per-layer spin keeps turning underneath.

Wishes are spread across layers by simple round-robin, $l = i \bmod L$, and spaced evenly around each ring before being perturbed. Those perturbations are what make a deterministic field look organic. A tiny hash-based generator,

$$\operatorname{seededRandom}(s) = \operatorname{frac}\!\big(\sin(s \cdot 127.1 + 311.7)\cdot 43758.5453\big),$$

turns each tile's index into stable pseudo-randomness — identical across reloads, so the field never reshuffles between visits. Each tile draws three uncorrelated offsets from it: a small vertical nudge, a radial jitter off its shell, and a breathing phase. That last one drives a gentle life-sign — every tile's scale oscillates as $\sin(t\cdot 0.6 + \varphi_{\text{breath}})$, a roughly ten-second cycle, with staggered phases so the field never pulses in mechanical unison. The orbiting wishes end up reading as a distinct category of slot, circling the world and waiting for placement, and because there are only ever a modest number of them they can afford to stay individual meshes rather than fold into the instanced atlas the surface grid demands.

## The shape of the whole thing

Step back and the system is really one idea in three registers. Mathematically, almost nothing is stored that can instead be computed — a slot's place on the sphere, its cell in the atlas, the slot under your finger, a wish's seat in orbit are all derived on demand, which is what keeps an 11,000-element world cheap. As engineering, the surface collapses into a single instanced draw over a baked, incrementally-updated level-of-detail pyramid, so the per-tile cost that should have killed it on mobile never appears. And as design, that efficiency buys back the things that make it feel alive: the inertial spin, the tile that pops under your thumb, the slow Keplerian drift of the orbital field, and the 60-second door that opens twice a day. Eleven thousand tiles, and a sky full of wishes, running off a handful of equations.

View in [https://11s.art](https://11s.art)
