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
//
// Inline-backed allocator integration tests — relocated from swift-memory-allocation-primitives when
// the inline → allocation edge was inverted (allocation must not name the concrete `Memory.Inline`;
// the leaf hosts both its adopt-role conformance AND these tests). Materializes
// `Memory.Allocator<Memory.Inline<n>>.{Arena, Pool}` over inline raw bytes and tears them down.
//
// The inline region's base is 8-aligned because the [MEM-SAFE-027] _deinitWorkaround (8-byte
// AnyObject?) sits FIRST, placing the @_rawLayout storage at offset 8 — so the Pool's typed free-list
// stores/loads are aligned.

import Index_Primitives
import Memory_Allocation_Primitives
import Memory_Inline_Primitives
import Testing

@Suite(.serialized)
struct MemoryAllocatorInlineBackedTests {
    @Test func arenaOverInlineBumpsAndTearsDown() throws {
        do {
            var arena = Memory.Allocator<Memory.Inline<1024>>.Arena(Memory.Inline<1024>())
            let cap = arena.capacity
            #expect(cap.underlying == 1024)
            _ = try arena.allocate(count: Memory.Address.Count(UInt(64)), alignment: .`8`)
            let alloc = arena.allocated
            #expect(alloc.underlying >= 64)
        }
        // The inline backing is reclaimed with the value (no heap free); reaching here = clean drop.
        #expect(Bool(true))
    }

    @Test func poolOverInlineCarvesSlotsAllocatesAndDetectsDoubleFree() throws {
        typealias Slot = Memory.Allocator<Memory.Inline<512>>.Pool.Slot
        do {
            var pool = try Memory.Allocator<Memory.Inline<512>>.Pool(
                carving: Memory.Inline<512>(),
                slotSize: Memory.Address.Count(UInt(16)),
                slotAlignment: .`8`
            )
            // 512 bytes / 16-byte slots = 32 slots.
            let cap = pool.capacity
            #expect(cap == Index<Slot>.Count(32))

            let s0 = try pool.allocateSlot()
            let s1 = try pool.allocateSlot()
            unsafe pool.pointer(at: s0).storeBytes(of: 0xABCD, as: Int.self)
            let read = unsafe pool.pointer(at: s0).load(as: Int.self)
            #expect(read == 0xABCD)

            // Bit.Vector double-free detection works over inline bytes too.
            try pool.deallocate(at: s1)
            var doubleFreed = false
            do { try pool.deallocate(at: s1) } catch { if case .doubleFree = error { doubleFreed = true } }
            #expect(doubleFreed)
        }
        #expect(Bool(true))
    }
}
