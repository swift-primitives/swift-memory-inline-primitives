// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Memory_Allocator_Protocol_Primitives

// MARK: - Memory.Allocatable (adopt-role ONLY — no growth)

/// `Memory.Inline<n>` adopts the allocation **adopt-role**: it can be wrapped as a passthrough
/// `Memory.Allocator<Memory.Inline<n>>` over its inline bytes (the default `makeAllocator()` adopts
/// the whole region).
///
/// It deliberately does **not** conform `Memory.Growable`: its capacity is the fixed value-generic
/// `n`, so it cannot be constructed to an arbitrary byte count — a growable column over `Memory.Inline`
/// is correctly unrepresentable.
///
/// This is the post-inversion `Memory.Allocatable` conformance the leaf declares now that the edge
/// points inline → allocation.
extension Memory.Inline: Memory.Allocatable {}
