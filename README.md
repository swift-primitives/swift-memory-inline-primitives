# Memory Inline Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

`Memory.Inline<n>` — an element-free, fixed-capacity raw byte region of exactly `n` bytes laid out inline in the value, with no heap allocation.

---

## Quick Start

`Memory.Inline<n>` is a raw memory region whose storage lives *inline* — the `n` bytes are laid out directly in the value, so the region needs no heap. It travels wherever the value travels: on the stack, inside another aggregate, or inside a move-only wrapper.

```swift
import Memory_Inline_Primitives

// 256 raw bytes laid out inline in the value — no heap allocation.
let region = Memory.Inline<256>()

// It is a `Memory.Region`: a raw `base` address and a byte `capacity`.
print(region.capacity.underlying)   // 256
```

The capacity is fixed at the type level, so different sizes are different types — `Memory.Inline<256>` is a distinct type from `Memory.Inline<512>`:

```swift
import Memory_Inline_Primitives

let small = Memory.Inline<16>()     // 16 inline bytes
let large = Memory.Inline<4096>()   // 4096 inline bytes
```

The region is `~Copyable` (move-only), so an allocator carving it is never silently duplicated. This makes `Memory.Inline<n>` the substrate for inline allocators: a `Memory.Allocator<Memory.Inline<n>>` pool or arena carves its slots within these in-value bytes, giving a pool or bump allocator with no heap backing at all.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-memory-inline-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Memory Inline Primitives", package: "swift-memory-inline-primitives"),
    ]
)
```

Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain). The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged.

---

## Architecture

One library product.

| Product | Target | Purpose |
|---------|--------|---------|
| `Memory Inline Primitives` | `Sources/Memory Inline Primitives/` | The `Memory.Inline<n>` inline raw byte region, with its `Memory.Region` conformance (`base` + `capacity`) and its `Memory.Allocatable` adopt-role conformance. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Related Packages

- [`swift-memory-primitives`](https://github.com/swift-primitives/swift-memory-primitives) — `Memory.Region`, the raw-byte region seam `Memory.Inline` conforms to.
- [`swift-memory-heap-primitives`](https://github.com/swift-primitives/swift-memory-heap-primitives) — `Memory.Heap`, the heap-allocated sibling region for capacities not known at compile time.
- [`swift-memory-allocation-primitives`](https://github.com/swift-primitives/swift-memory-allocation-primitives) — the pool and arena allocators that carve slots within an inline region.

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
