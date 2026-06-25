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

public import Memory_Primitive

extension Memory {
    /// An element-free, fixed-capacity inline raw byte region of exactly `n` bytes.
    ///
    /// `Memory.Inline<n>` is a `Memory.Region` (raw `base` + `capacity` in bytes) whose storage is
    /// **inline** — `@_rawLayout(likeArrayOf: UInt8, count: n)` lays out `n` raw bytes directly in the
    /// value (no heap allocation). It backs inline allocators: `Memory.Allocator<Memory.Inline<n>>.Pool`
    /// / `.Arena` carve slots within these bytes.
    ///
    /// **Distinct from `Storage.Contiguous.Inline<Element, n>`** (Storage tier, W2): that is *typed*
    /// inline elements (`@_rawLayout(likeArrayOf: Element, count: n)`, with the initialization ledger +
    /// element deinit-oracle). `Memory.Inline<n>` is *raw inline bytes* — element-free, no ledger, no
    /// typed teardown. Raw inline bytes ⇒ Memory; typed inline elements ⇒ Storage.
    ///
    /// The value-generic `n` is expressible because `@_rawLayout(likeArrayOf: UInt8, count: n)` accepts a
    /// value-generic `count` (unlike `@_rawLayout(size:)`, which needs an integer literal — the form that
    /// is NOT usable here). `UInt8` is always in scope (no `Element` parameter needed), so the leaf is
    /// genuinely element-free.
    public struct Inline<let n: Int>: ~Copyable {
        /// `[MEM-SAFE-027]` swift#86652 workaround — forces non-trivial destructibility so the
        /// `@_rawLayout` storage is not misclassified as trivial and skipped across a package boundary.
        ///
        /// MUST be the FIRST stored property (before the `@_rawLayout` storage). Always `nil`.
        @usableFromInline
        package var _deinitWorkaround: AnyObject? = nil

        /// Inline raw storage: exactly `n` bytes laid out in the value.
        ///
        /// `@_rawLayout` storage MUST be the LAST stored property (a fixed-size field after it trips an
        /// LLVM verifier crash in release).
        @_rawLayout(likeArrayOf: UInt8, count: n)
        @usableFromInline
        package struct _Raw: ~Copyable {
            @inlinable package init() {}
        }

        @usableFromInline
        package var _storage: _Raw

        /// Creates an uninitialized inline region of `n` raw bytes.
        @inlinable
        public init() {
            self._deinitWorkaround = nil
            self._storage = _Raw()
        }
    }
}

extension Memory.Inline: @unchecked Sendable {}
