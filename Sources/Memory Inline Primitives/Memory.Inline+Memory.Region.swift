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

public import Memory_Address_Primitives
public import Memory_Primitive
public import Memory_Region_Primitives

// MARK: - Region (the inline raw bytes ARE the region)

extension Memory.Inline: Memory.Region {
    /// The capacity in bytes — exactly the value-generic `n`.
    @inlinable
    public var capacity: Memory.Address.Count {
        Memory.Address.Count(UInt(n))
    }

    /// The base address of the inline storage's first byte.
    @inlinable
    public var base: Memory.Address {
        // SAFETY: `_storage` is inline in `self`; its address is the region's base and is valid for
        // SAFETY: `self`'s lifetime (the owner outlives every use of the base). The integer-address
        // SAFETY: model carries no provenance. [MEM-SAFE-025a]
        unsafe withUnsafePointer(to: _storage) { pointer in
            unsafe Memory.Address(UnsafeMutableRawPointer(mutating: pointer))
        }
    }
}
