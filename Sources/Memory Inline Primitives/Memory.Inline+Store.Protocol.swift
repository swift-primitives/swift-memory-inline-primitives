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

public import Index_Primitives
public import Memory_Address_Primitives
public import Memory_Primitive
public import Store_Initialization_Primitives
public import Store_Protocol_Primitives
public import Store_Tracked_Primitives

// MARK: - Store.Protocol Witnesses (the element-store seam)

extension Memory.Inline where Element: ~Copyable {
    /// Reads or writes the initialized element at the given physical slot.
    ///
    /// Witnesses the `subscript(slot:)` requirement of `Store.`Protocol``. The
    /// `_modify` accessor is `mutating` → exclusive `&self`, so it derives its
    /// mutable pointer from `withUnsafeMutablePointer(to: &_storage)` (exclusive
    /// access). Ledger-neutral, exactly as `Memory.Heap` — composed disciplines
    /// sync `initialization`.
    @inlinable
    public subscript(slot: Index<Element>) -> Element {
        _read {
            let pointer = unsafe _mutablePointer(at: slot)
            yield unsafe pointer.pointee
        }
        _modify {
            let pointer = unsafe withUnsafeMutablePointer(to: &_storage) { raw in
                unsafe UnsafeMutableRawPointer(raw)
                    .advanced(by: Index<Element>.Offset(fromZero: slot) * .stride)
                    .assumingMemoryBound(to: Element.self)
            }
            yield &(unsafe pointer.pointee)
        }
    }

    /// Initializes the uninitialized element at `slot` to `element`.
    ///
    /// Witnesses `initialize(at:to:)`. Ledger-neutral (the composing discipline
    /// syncs `initialization`).
    @inlinable
    public mutating func initialize(at slot: Index<Element>, to element: consuming Element) {
        let pointer = unsafe withUnsafeMutablePointer(to: &_storage) { raw in
            unsafe UnsafeMutableRawPointer(raw)
                .advanced(by: Index<Element>.Offset(fromZero: slot) * .stride)
                .assumingMemoryBound(to: Element.self)
        }
        unsafe pointer.initialize(to: consume element)
    }

    /// Moves the initialized element out of `slot`, leaving it uninitialized.
    ///
    /// Witnesses `move(at:)`. Ledger-neutral.
    @inlinable
    public mutating func move(at slot: Index<Element>) -> Element {
        unsafe withUnsafeMutablePointer(to: &_storage) { raw in
            unsafe UnsafeMutableRawPointer(raw)
                .advanced(by: Index<Element>.Offset(fromZero: slot) * .stride)
                .assumingMemoryBound(to: Element.self)
                .move()
        }
    }

    /// Deinitializes the initialized element at `slot` in place.
    ///
    /// Witnesses `deinitialize(at:)`. Ledger-neutral.
    @inlinable
    public mutating func deinitialize(at slot: Index<Element>) {
        let pointer = unsafe withUnsafeMutablePointer(to: &_storage) { raw in
            unsafe UnsafeMutableRawPointer(raw)
                .advanced(by: Index<Element>.Offset(fromZero: slot) * .stride)
                .assumingMemoryBound(to: Element.self)
        }
        unsafe pointer.deinitialize(count: 1)
    }
}

// MARK: - Store.Protocol + Store.Tracked.Protocol Conformances

extension Memory.Inline: Store.`Protocol` where Element: ~Copyable {}
extension Memory.Inline: Store.Tracked.`Protocol` where Element: ~Copyable {}
