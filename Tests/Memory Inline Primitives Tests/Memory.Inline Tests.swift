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

import Memory_Address_Primitives
import Memory_Region_Primitives
import Testing

@testable import Memory_Inline_Primitives

// `Memory.Inline<n>` — the element-free, fixed-capacity inline raw byte region. It conforms
// `Memory.Region` (base + capacity) and backs `Memory.Allocator<Memory.Inline<n>>.{Pool, Arena}`
// (cross-package teardown is exercised in the allocation package's tests).

@Suite(.serialized)
struct MemoryInlineTests {

    @Test func capacityEqualsTheValueGenericByteCount() {
        let inline = Memory.Inline<256>()
        let cap = inline.capacity
        #expect(cap.underlying == 256)
    }

    @Test func capacityTracksDistinctInstantiations() {
        let a = Memory.Inline<16>()
        let b = Memory.Inline<4096>()
        #expect(a.capacity.underlying == 16)
        #expect(b.capacity.underlying == 4096)
    }

    @Test func baseIsReachableAndStableAcrossReads() {
        let inline = Memory.Inline<128>()
        let first = inline.base
        let second = inline.base
        #expect(first == second)
    }

    @Test func conformsMemoryRegionGenerically() {
        func capacity<R: Memory.Region & ~Copyable>(_ region: borrowing R) -> Memory.Address.Count {
            region.capacity
        }
        let inline = Memory.Inline<64>()
        #expect(capacity(inline).underlying == 64)
    }

    @Test func dropDoesNotCrash() {
        do {
            let inline = Memory.Inline<512>()
            #expect(inline.capacity.underlying == 512)
            _ = inline.base
        }
        // The inline storage is reclaimed with the value; the _deinitWorkaround keeps destruction
        // from being skipped (swift#86652). Reaching here without a crash is the assertion.
        #expect(Bool(true))
    }
}
