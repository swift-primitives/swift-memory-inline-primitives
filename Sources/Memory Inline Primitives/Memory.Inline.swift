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

import Index_Primitives
import Memory_Address_Primitives
public import Memory_Primitive
public import Store_Initialization_Primitives

extension Memory {
    /// Fixed-capacity typed inline memory leaf with initialization tracking — the
    /// inline twin of ``Memory/Heap``.
    ///
    /// `Memory.Inline<Element, count>` is the inline allocation-strategy leaf of the
    /// substitution tower: `@_rawLayout` inline storage plus a `Store.Initialization`
    /// ledger. It conforms `Store.Tracked.`Protocol`` so that
    /// `Storage.Contiguous<Memory.Inline<Element, n>>` composes it exactly as
    /// `Storage.Contiguous<Memory.Heap<Element>>` composes the heap leaf — this leaf
    /// REPLACES the fused `Storage.Inline`, relocating inline storage down to the
    /// memory tier where it belongs.
    ///
    /// ## Layout
    ///
    /// `@_rawLayout(likeArrayOf: Element, count: count)` computes optimal layout at
    /// compile time: `size = stride(Element) × count`, `alignment = alignment(Element)`.
    ///
    /// ## Cleanup Oracle
    ///
    /// Unconditionally `~Copyable` with a self-cleaning `deinit` that walks the
    /// `initialization` ledger and deinitializes exactly the initialized ranges — the
    /// `Store.Tracked.`Protocol`` contract (disciplines composed above SYNC the ledger;
    /// the leaf's `deinit` HONORS it). This mirrors `Memory.Heap`'s backing-class
    /// `deinit`, but the storage is inline rather than a heap allocation.
    public struct Inline<Element: ~Copyable, let count: Int>: ~Copyable {
        // WHY: works around swiftlang/swift#86652 — @_rawLayout triviality
        // misclassification. Forces the compiler to recognize the type as
        // non-trivially destructible so `deinit` executes. COST: 8 bytes per instance.
        // Must be declared BEFORE the @_rawLayout storage (which must be last).
        @usableFromInline
        package var _deinitWorkaround: AnyObject? = nil

        /// The initialization ledger the `deinit` honors (the `Store.Tracked` contract).
        ///
        /// Disciplines composed above sync it (`storage.initialization = header.initialization`);
        /// the leaf's own teardown walks exactly these ranges.
        @usableFromInline
        package var _initialization: Store.Initialization<Element>

        /// Internal raw inline storage with automatic layout computation.
        ///
        /// MUST be the last stored property: when a containing type has a custom
        /// `deinit`, fixed-size fields after the variable-size @_rawLayout storage
        /// trip an LLVM "Instruction does not dominate all uses" verifier crash in
        /// release builds (stride-based offset computed outside the deinit loop).
        @_rawLayout(likeArrayOf: Element, count: count)
        @usableFromInline
        package struct _Raw: ~Copyable {
            @usableFromInline
            init() {}
        }

        @usableFromInline
        package var _storage: _Raw

        /// Creates uninitialized inline memory with an empty ledger.
        ///
        /// All `count` slots contain indeterminate memory. The composing discipline
        /// is responsible for initializing slots and syncing the `initialization`
        /// ledger before this value is destroyed.
        @inlinable
        public init() {
            _initialization = .empty
            _storage = _Raw()
        }

        // MARK: - Deinit (the cleanup oracle)

        /// Deinitializes exactly the slots tracked by the `initialization` ledger.
        ///
        /// Walks the ledger ranges and deinitializes each — handling linear (`.one`)
        /// and ring-wrapped (`.two`) patterns. Disciplines that bypass tracking leave
        /// the ledger `.empty`, making this a no-op.
        deinit {
            _initialization.forEach { range in
                guard !range.isEmpty else { return }
                _ = unsafe withUnsafePointer(to: _storage) { base in
                    unsafe UnsafeMutableRawPointer(mutating: UnsafeRawPointer(base))
                        .advanced(by: Index<Element>.Offset(fromZero: range.lowerBound) * .stride)
                        .assumingMemoryBound(to: Element.self)
                        .deinitialize(count: range.count)
                }
            }
        }
    }
}
