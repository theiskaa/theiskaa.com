---
title: Drawing a space debris around main globe of Elevens
date: 2026-02-10
description: Multi-layered orbital debris system with 5 concentric shells, Keplerian differential rotation, seeded deterministic positioning, and sinusoidal breathing animation in 11s.art
---

The space debris visualization creates a multi-layered orbital particle system surrounding the main globe. Floating slots that lack fixed grid positions orbit the globe at varying distances, tilts, and angular velocities, producing depth through parallax and cosmic atmosphere through subtle animation. The system implements deterministic positioning via seeded pseudo-randomness, differential rotation speeds across orbital shells, and organic life through sinusoidal breathing effects.

The debris system organizes particles into $L = 5$ concentric orbital layers. Each layer $l \in [0, 4]$ is defined by four parameters: radius offset $\Delta r_l$ from globe surface, X-axis tilt $\alpha_l$, Z-axis tilt $\beta_l$, and angular velocity $\omega_l$ in radians per second. The globe radius is $r = 5$ units. The layers are configured as:

$$\begin{aligned}
\text{Layer 0:} \quad r_0 &= r + 0.7 = 5.7, \quad (\alpha_0, \beta_0) = (0.05, 0.0), \quad \omega_0 = 0.12 \\
\text{Layer 1:} \quad r_1 &= r + 1.2 = 6.2, \quad (\alpha_1, \beta_1) = (0.45, 0.15), \quad \omega_1 = 0.08 \\
\text{Layer 2:} \quad r_2 &= r + 1.8 = 6.8, \quad (\alpha_2, \beta_2) = (-0.25, 0.35), \quad \omega_2 = 0.055 \\
\text{Layer 3:} \quad r_3 &= r + 2.5 = 7.5, \quad (\alpha_3, \beta_3) = (0.15, -0.4), \quad \omega_3 = 0.035 \\
\text{Layer 4:} \quad r_4 &= r + 3.2 = 8.2, \quad (\alpha_4, \beta_4) = (-0.5, 0.1), \quad \omega_4 = 0.02
\end{aligned}$$

The relationship $\omega_l \propto 1/r_l$ approximates Keplerian orbital mechanics where closer objects orbit faster. This creates natural parallax: inner debris sweeps rapidly across the viewport while outer debris drifts slowly, establishing depth perception without stereoscopy. The varied tilt angles ensure orbital planes intersect at different inclinations, preventing the debris field from appearing as flat concentric rings.

Each layer is implemented as a THREE.Group with rotation.x $= \alpha_l$ and rotation.z $= \beta_l$ set at construction time. This establishes the orbital plane orientation. All particle meshes within layer $l$ are children of its group. The layer groups are children of floatingGroup, which is itself a child of globeGroup. This hierarchy means user-driven globe rotation (from drag interaction) rotates the entire debris system, while the animation loop additionally increments each layer group's rotation.y by $\omega_l \cdot \Delta t$ per frame where $\Delta t \approx 0.016$s at 60fps. The per-layer Y rotation creates orbital motion independent of interactive rotation.

Floating slot distribution across layers uses round-robin assignment. Given $M$ floating slots indexed $i \in [0, M-1]$, slot $i$ is assigned to layer:

$$l = i \mod L$$

This ensures approximately equal distribution regardless of total count. If $M = 47$ slots across $L = 5$ layers, layers receive $[10, 10, 9, 9, 9]$ slots respectively.

Within each layer, particles are evenly spaced angularly. If layer $l$ contains $m_l$ particles indexed $j \in [0, m_l - 1]$, particle $j$ is positioned at base angle:

$$\theta_j = \frac{j}{m_l} \cdot 2\pi$$

This places particles at regular intervals around the orbital ring before random offsets are applied.

Deterministic randomness is essential for consistent presentation across sessions. The `seededRandom(seed)` function implements a hash-based PRNG:

$$x = \sin(\text{seed} \cdot 127.1 + 311.7) \cdot 43758.5453$$
$$\text{return } x - \lfloor x \rfloor$$

The result lies in $[0, 1)$. The sine function combined with large multipliers creates pseudo-random distribution. Identical seeds produce identical outputs, ensuring particle positions remain stable across page reloads.

Each particle receives three random offsets derived from its global index $g$ (position across all layers, not just within its layer). The vertical offset uses seed $= g \cdot 5.3$:

$$\delta_y = (\text{seededRandom}(g \cdot 5.3) - 0.5) \cdot 0.6 \in [-0.3, 0.3]$$

The radius jitter uses seed $= g \cdot 7.1$:

$$\delta_r = (\text{seededRandom}(g \cdot 7.1) - 0.5) \cdot 0.4 \in [-0.2, 0.2]$$

The breathing phase uses seed $= g \cdot 13.7$:

$$\varphi_{breath} = \text{seededRandom}(g \cdot 13.7) \cdot 2\pi \in [0, 2\pi)$$

The different seed multipliers $(5.3, 7.1, 13.7)$ ensure uncorrelated random streams for each offset dimension.

The final position of particle $j$ in layer $l$ with global index $g$ is computed as follows. The effective radius is $r_{eff} = r_l + \delta_r$. The base angle is $\theta_j = (j / m_l) \cdot 2\pi$. In the layer's local coordinate system (before tilt rotation), the position is:

$$x = \cos(\theta_j) \cdot r_{eff}$$
$$y = \delta_y$$
$$z = \sin(\theta_j) \cdot r_{eff}$$

The particle lies in the XZ plane of its layer group at angle $\theta_j$ from the X axis, offset vertically by $\delta_y$ and radially by $\delta_r$ from the nominal layer radius.

Particle meshes use shared THREE.PlaneGeometry with dimensions matching equatorial globe tiles. The equatorial row is row 19 at latitude $\varphi_{19} \approx -2.1°$. Tile dimensions from getTileSize(19) yield width $w \approx 0.194$ units and height $h \approx 0.368$ units. All debris particles share this single geometry instance.

Materials follow the same pattern as globe slots. If the floating slot has image data, a unique THREE.MeshBasicMaterial is created with texture map loaded via TextureLoader. The texture cache (keyed by URL) is shared with the globe system, preventing duplicate network requests. If no image exists, a shared default material with color 0xbbbbbb (dark theme) or 0x999999 (light theme) is used. Material side is THREE.DoubleSide since debris particles may be viewed from either direction as they orbit.

Each particle mesh is oriented to face outward from the globe center. After positioning at $(x, y, z)$, the mesh calls lookAt$(2x, 2y, 2z)$, which orients the mesh's local Z axis toward a point at twice its position vector. Since the target lies along the same radial direction, the mesh face becomes perpendicular to the radial line, facing away from the globe center.

The edge glow effect uses a THREE.Line mesh with BufferGeometry constructed from five corner points matching the particle dimensions:

$$\left[(-w/2, -h/2, 0), (w/2, -h/2, 0), (w/2, h/2, 0), (-w/2, h/2, 0), (-w/2, -h/2, 0)\right]$$

The material is THREE.LineBasicMaterial with color 0x5588cc (dark) or 0x4477aa (light) at opacity 0.35. This creates a subtle luminous border distinguishing debris from the dark background. Each outline mesh copies the position and quaternion of its paired particle mesh, then both are added to the same layer group for synchronized orbital motion.

The breathing animation adds organic life to the static debris field. Each particle stores its breath phase $\varphi_{breath}$ in userData. During each animation frame at time $t$, the system iterates all debris meshes and computes:

$$\text{breath} = \sin(t \cdot 0.6 + \varphi_{breath}) \cdot 0.04$$
$$\text{scale} = \text{baseScale} + \text{breath}$$

With baseScale $= 1.0$, the scale oscillates in $[0.96, 1.04]$. The frequency factor $0.6$ rad/s means each particle completes a full breath cycle in:

$$T = \frac{2\pi}{0.6} \approx 10.47 \text{ seconds}$$

The staggered phases $\varphi_{breath} \in [0, 2\pi)$ ensure particles breathe asynchronously, preventing synchronized pulsing that would appear mechanical.

The animation loop integrates with the main rendering cycle. After processing globe rotation and camera zoom, the loop iterates orbitalLayers array: for each layer, group.rotation.y $\mathrel{+}=$ layer.speed $\cdot$ 0.016. Then it iterates floatingDebris array applying the breathing scale computation. Both operations are $O(M)$ where $M$ is debris count, with minimal per-iteration cost (arithmetic and property assignment only).

Debris particles participate in click detection with higher priority than globe slots. The pointerUp handler first raycasts against the floatingDebris array. If intersection occurs, the hit mesh's userData.slot provides the floating slot data to open the detail modal. Only if no debris is hit does raycasting proceed to the globe interaction sphere.

Hover detection for debris occurs during pointerMove when not dragging. If the interaction sphere raycast misses (pointer not over globe), the system additionally tests the debris array. If any debris is hit, cursor is set to 'pointer' indicating interactability. This provides visual feedback that debris particles are clickable objects.

Resource cleanup on data change or unmount iterates floatingDebris array, removing each mesh from its parent group and disposing unique texture materials (tracked via hasUniqueTexture flag). Outline meshes are removed via references stored in mesh.userData.outlineMesh. Layer groups are removed from floatingGroup and orbitalLayers array is cleared. Shared resources (geometry, default material, outline geometry, outline material) are disposed last. This ensures no GPU memory leaks when debris is recreated with new slot data.

The debris visualization serves aesthetic and functional purposes. Visually, it communicates that floating slots exist as a distinct category from grid-anchored slots, occupying liminal space around the primary surface. The orbital motion suggests these slots await placement. The parallax depth from differential layer speeds establishes three-dimensionality. The breathing animation provides organic life without distraction.

Functionally, debris must remain performant. Geometry sharing minimizes GPU allocations. The fixed layer count $L = 5$ bounds animation loop iterations. Texture caching prevents redundant loading. The total debris count $M$ is typically modest (tens to low hundreds), keeping per-frame cost negligible relative to the 4000-slot globe grid.

View in [https://11s.art](https://11s.art)
