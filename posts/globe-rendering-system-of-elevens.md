---
title: Globe rendering system of Elevens
date: 2026-02-10
description: How 4000 slots are distributed across a 3D sphere using cosine-weighted tiling, O(1) hit detection in 11s.art
---

The globe rendering system transforms a flat collection of 4000 purchasable slots into a three-dimensional spherical visualization using Three.js WebGL rendering. The fundamental challenge lies in distributing discrete rectangular tiles across a sphere such that visual density remains consistent from equator to poles while maintaining performant hit detection and smooth interaction.

The system operates on a fixed configuration defined at module level. The total slot count $N = 4000$ is distributed across $R = 38$ latitude rows. Each pole reserves $\theta_{cap} = 10°$ for special content, leaving $\theta_{usable} = 180° - 2\theta_{cap} = 160°$ of usable latitude range. The globe itself has radius $r = 5$ units with 64 geometric segments for smooth curvature rendering. The latitude threshold for pole detection is set at $\theta_{pole} = 90° - \theta_{cap} = 80°$ from the equator. Any click or hover event registering above this threshold triggers pole-specific behavior rather than slot interaction.

The `computeRowDistribution` function solves the fundamental problem of spherical tiling: how to allocate columns per row such that tiles appear visually uniform despite the convergence of meridians toward the poles. The solution employs cosine-weighted distribution based on the geometric fact that circumference at latitude $\varphi$ equals:

$$C(\varphi) = 2\pi r \cdot \cos(\varphi)$$

The latitude step per row is:

$$\Delta\varphi = \frac{\theta_{usable}}{R} = \frac{160°}{38} \approx 4.21°$$

Row centers are computed starting from the northern boundary, where row 0 has center latitude:

$$\varphi_0 = 90° - \theta_{cap} - \frac{\Delta\varphi}{2} = 90° - 10° - 2.105° \approx 77.89°$$

For each row index $i \in [0, 37]$, the center latitude is:

$$\varphi_i = 90° - \theta_{cap} - (i + 0.5) \cdot \Delta\varphi$$

The cosine of each row's latitude determines relative circumference. Rows near the equator have $\cos(\varphi) \to 1.0$, while rows near the poles approach $\cos(80°) \approx 0.174$. The algorithm computes the sum across all rows:

$$S = \sum_{i=0}^{R-1} \cos(\varphi_i)$$

Then allocates columns proportionally. The raw allocation for row $i$ is:

$$c_i^{raw} = \frac{\cos(\varphi_i)}{S} \cdot N$$

Each value is rounded: $c_i = \text{round}(c_i^{raw})$. This rounding introduces error $\varepsilon = N - \sum_i c_i$ which must be corrected. The correction phase sorts row indices by $|\cos(\varphi_i)|$ descending (proximity to equator) and adjusts column counts by $\pm 1$ until $\varepsilon = 0$. The result is a precomputed array `ROW_DISTRIBUTION` containing for each row its index, center latitude $\varphi_i$, column count $c_i$, and cumulative positions:

$$p_i^{start} = 1 + \sum_{j < i} c_j$$
$$p_i^{end} = p_i^{start} + c_i - 1$$

Row 19 near the equator at $\varphi_{19} \approx -2.1°$ contains $c_{19} \approx 136$ columns, while row 0 near the north pole contains $c_0 \approx 24$ columns.

The `positionToSpherical` function converts a one-based slot position $p \in [1, 4000]$ into geographic coordinates $(\varphi, \lambda)$. The algorithm performs binary search over the row distribution to find row index $i$ such that $p_i^{start} \le p \le p_i^{end}$. Since rows are ordered with non-overlapping position ranges, binary search achieves $O(\log R) = O(\log 38) \approx O(5)$ lookup. The column index within that row is:

$$j = p - p_i^{start}$$

The longitude is computed as:

$$\lambda = \frac{j + 0.5}{c_i} \cdot 360° - 180°$$

The addition of 0.5 centers the slot within its longitudinal cell at position $(j + 0.5)/c_i$ of the full 360° range, then shifts to the standard $[-180°, 180°)$ range. The function returns $\{\text{lat}: \varphi_i, \text{lon}: \lambda, \text{rowIndex}: i\}$.

The `sphericalToCartesian` function implements the standard geographic-to-Cartesian transformation. Given latitude $\varphi$ and longitude $\lambda$ in degrees and radius $r$, the polar angle is:

$$\theta = (90° - \varphi) \cdot \frac{\pi}{180}$$

This places $\theta = 0$ at the north pole and $\theta = \pi$ at the south pole. The azimuthal angle is:

$$\psi = (\lambda + 180°) \cdot \frac{\pi}{180}$$

The Cartesian coordinates follow Three.js convention where Y is up:

$$x = -r \cdot \sin(\theta) \cdot \cos(\psi)$$
$$y = r \cdot \cos(\theta)$$
$$z = r \cdot \sin(\theta) \cdot \sin(\psi)$$

The negation on $x$ accounts for coordinate system handedness. The function returns a THREE.Vector3 positioned on the sphere surface.

The `hitPointToSlotPosition` function reverses the mapping to convert a raycasted point $P = (x, y, z)$ in globe-local coordinates back to slot position. This replaced an earlier $O(N)$ brute-force approach. Given $P$ with magnitude $d = |P|$, the latitude is recovered via:

$$\varphi = \arcsin\left(\frac{y}{d}\right) \cdot \frac{180°}{\pi}$$

If $|\varphi| > \theta_{pole} = 80°$, the function returns null indicating a pole region click.

For longitude recovery, the original forward transformation used $\psi = (\lambda + 180°) \cdot (\pi/180)$ with $x = -r \sin(\theta) \cos(\psi)$ and $z = r \sin(\theta) \sin(\psi)$. Dividing:

$$\frac{z}{-x} = \frac{\sin(\psi)}{\cos(\psi)} = \tan(\psi)$$

Thus:

$$\psi = \text{atan2}(z, -x)$$

This yields $\psi \in [-\pi, \pi]$. Normalizing to $[0, 2\pi)$:

$$\psi_{norm} = \begin{cases} \psi + 2\pi & \text{if } \psi < 0 \\ \psi & \text{otherwise} \end{cases}$$

Then converting back:

$$\lambda = \psi_{norm} \cdot \frac{180°}{\pi} - 180°$$

With $(\varphi, \lambda)$ recovered, the algorithm finds row $i$ minimizing $|\varphi_i - \varphi|$ across all 38 rows. Within row $i$, the column index is:

$$j = \left\lfloor \frac{\lambda + 180°}{360°} \cdot c_i \right\rfloor$$

clamped to $[0, c_i - 1]$. The final position is $p = p_i^{start} + j$.

The `getTileSize` function computes mesh dimensions for row $i$. Tile height is uniform:

$$h = \Delta\varphi \cdot \frac{\pi}{180} \cdot r \cdot s$$

where $s = 0.84$ is the scale factor, yielding $h \approx 0.368$ units. Tile width varies with latitude:

$$w = \frac{2\pi r \cdot \cos(\varphi_i)}{c_i} \cdot s$$

At the equator with $c_{19} \approx 136$ columns and $\cos(\varphi_{19}) \approx 1$, width $w \approx 0.194$ units. At row 0 with $c_0 \approx 24$ and $\cos(77.89°) \approx 0.21$, width $w \approx 0.67$ units.

The Three.js scene hierarchy consists of a root Scene containing ambient light (intensity 1.0), directional front light (intensity 0.2 at $z=10$), and the globe Group. The globe group contains: all slot meshes, pole cap meshes, an inner occlusion sphere at radius $r - 0.06$, an invisible interaction sphere at radius $r$, and the floating debris group. The inner sphere with solid background color occludes back-facing tiles that would otherwise show through gaps between front-facing tiles. The interaction sphere serves as raycasting target for click detection. Pole caps use THREE.SphereGeometry with restricted $\theta$ ranges: north cap spans $\theta \in [0, \theta_{cap} \cdot \pi/180]$, south cap spans $\theta \in [\pi - \theta_{cap} \cdot \pi/180, \pi]$, both at radius $r + 0.02$ to overlay the slot layer.

The system creates $R = 38$ shared PlaneGeometry instances rather than $N = 4000$ individual geometries. Each row geometry has dimensions $(w_i, h)$ matching that row's tile size. Outline geometries for empty slots are BufferGeometry instances from five corner points:

$$\left[(-w/2, -h/2), (w/2, -h/2), (w/2, h/2), (-w/2, h/2), (-w/2, -h/2)\right]$$

Materials pool into five categories: `emptyDefault` (LineBasicMaterial, opacity 0.15), `emptyHover` (LineBasicMaterial, opacity 1.0), `purchased` (MeshBasicMaterial, solid fill), `search` (MeshBasicMaterial, magenta 0xc2185b), `owned` (MeshBasicMaterial, blue 0x1565c0). Slots with images receive unique MeshBasicMaterial with texture maps, tracked via `hasUniqueTexture` flag. Textures use sRGB color space with LinearFilter minification/magnification.

Tile creation iterates positions $p = 1$ to $4000$ in batches of 500 with setTimeout(0) yields between batches. For each position: compute $(\varphi, \lambda, i) = \text{positionToSpherical}(p)$, retrieve slot data from Map, create appropriate mesh type. Purchased slots with images get Mesh with textured material. Purchased slots without images get Mesh with search/owned/purchased material based on state. Empty slots get Line with outline geometry and emptyDefault material. Each mesh is positioned at $\text{sphericalToCartesian}(\varphi, \lambda, r)$ and oriented via lookAt($2 \cdot \text{position}$) to face outward. Highlighted slots scale to $1.15\times$. Mesh userData stores $\{\text{position}: p, \text{slot}, \text{baseScale}, \text{hasUniqueTexture}\}$. Meshes are added to globe group and position-keyed Map for $O(1)$ retrieval.

The camera is PerspectiveCamera with $\text{FOV} = 50°$, positioned at $(0, 0, z)$ where $z$ is the zoom distance. Default zoom $z_{default} = 16$ on desktop, $34$ on mobile. Minimum $z_{min} = 7$, maximum $z_{max} = 24$ desktop / $34$ mobile. Camera distance interpolates via exponential easing:

$$z_{current} \mathrel{+}= (z_{target} - z_{current}) \cdot 0.08$$

per frame.

Globe rotation uses two ref objects storing Euler angles $(\theta_x, \theta_y)$. $\theta_x$ controls vertical tilt, clamped to $[-\pi/2.2, \pi/2.2] \approx [-81.8°, 81.8°]$ to prevent pole flip. $\theta_y$ controls horizontal spin, unbounded with natural wrapping. During drag, pointer delta $(\Delta p_x, \Delta p_y)$ converts to angular velocity:

$$(\omega_x, \omega_y) = (\Delta p_y \cdot k, \Delta p_x \cdot k)$$

where sensitivity:

$$k = 0.004 \cdot \frac{z_{current}}{z_{default}}$$

scales with zoom for consistent feel. Velocity applies to target rotation each frame. After drag release, velocity decays:

$$\omega \mathrel{*}= 0.94$$

per frame, creating inertial spin. When $|\omega| < 0.0001$ and auto-rotate enabled, constant drift applies:

$$\theta_y^{target} \mathrel{+}= 0.0002 \text{ rad/frame}$$

Hover animation for purchased slots: on hover, mesh scale lerps toward $1.4 \cdot \text{baseScale}$ with factor 0.18:

$$\text{scale} \mathrel{+}= (1.4 \cdot \text{base} - \text{scale}) \cdot 0.18$$

Position lerps outward along surface normal $\hat{n} = \text{normalize}(\text{position})$ by 0.25 units:

$$\text{pos} \mathrel{+}= (\text{basePos} + 0.25 \cdot \hat{n} - \text{pos}) \cdot 0.18$$

On hover exit, mesh transfers to prevHovered ref, continues lerping back to baseScale and basePos. When $|\text{pos} - \text{basePos}| < 0.005$, snaps to exact base state. Empty slot outlines simply swap material from emptyDefault to emptyHover.

Pointer events use activePointers Map for multi-touch. On pointerdown: record $(x_0, y_0, t_0)$, set dragging=true, zero velocity. On pointermove during drag: compute $\Delta = (x - x_{prev}, y - y_{prev})$, accumulate $\text{totalDrag} \mathrel{+}= |\Delta|$, update velocity and targetRotation. For two-finger pinch: compute distance:

$$d = \sqrt{(x_1 - x_2)^2 + (y_1 - y_2)^2}$$

If previous $d_{prev}$ exists, zoom delta $= (d_{prev} - d) \cdot 0.03$, clamp $z_{target}$ to $[z_{min}, z_{max}]$. On pointerup: gesture is click if $|\text{direct distance}| < 10\text{px}$ AND $\text{totalDrag} < 15\text{px}$ AND hold time $< 300\text{ms}$, then raycast.

Click resolution stages: (1) raycast against floatingDebris array, if hit open detail modal with debris.userData.slot; (2) raycast against interactionSphere, if miss ignore click; (3) convert hit point to globe-local coordinates $P_{local} = \text{globeGroup.worldToLocal}(P_{world})$; (4) compute $\varphi = \arcsin(P_{local}.y / |P_{local}|) \cdot (180°/\pi)$, if $|\varphi| > 80°$ open wish modal; (5) compute slot position via hitPointToSlotPosition, retrieve mesh from Map, verify $|P_{local} - \text{meshPos}| < 0.8$, open slot modal.

Pole countdown display: $256 \times 256$ canvas with CanvasTexture, plane geometry sized:

$$r \cdot \sin(\theta_{cap} \cdot \pi/180) \cdot 1.4 \approx 1.22 \text{ units}$$

`renderPoleContent` draws phase-dependent content. Idle: countdown string at $(128, 90)$ in 44px monospace, "left to make a wish" at $(128, 140)$ in 22px sans-serif, muted colors. Teaser: same layout, brighter colors. Active: "Make a Wish" at $(128, 100)$ in 34px bold with shadow glow, seconds remaining at $(128, 145)$. South pole canvas applies ctx.translate(128,128); ctx.rotate($\pi$); ctx.translate(-128,-128) before drawing for upright text when viewed from below. Animation loop checks displayKey = phase + countdown + secondsLeft, redraws canvas and sets texture.needsUpdate = true on change.

Theme colors via getThemeColors(isDark): dark theme uses background 0x000000, emptyOutline 0x2a2a2a, hoverGlow 0x888888; light theme uses background 0xf5f5f5, emptyOutline 0xcccccc, hoverGlow 0x666666. Theme change updates materials in place without scene rebuild.

Performance optimizations: geometry sharing reduces allocations from 4000 to 38; material pooling reduces draw calls; $O(1)$ hit detection replaces $O(4000)$ iteration; texture caching via URL-keyed Map; pixel ratio capped at 1.5; antialiasing disabled; renderer uses powerPreference: 'high-performance'; batched tile creation with abort flag for cleanup.
