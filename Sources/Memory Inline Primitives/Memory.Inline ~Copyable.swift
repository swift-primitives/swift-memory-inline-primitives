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

// MARK: - Pointer Access

extension Memory.Inline where Element: ~Copyable {
    /// Returns a mutable pointer to the element at the given zero-based slot.
    ///
    /// The primitive raw-access entry point for callers managing lifecycle
    /// themselves (e.g. inline job deques). The pointer is valid for the lifetime
    /// of `self`.
    ///
    /// - Parameter slot: The zero-based slot index.
    /// - Precondition: `slot` must be in `0 ..< count`.
    @unsafe
    @inlinable
    public func pointer(at slot: Int) -> UnsafeMutablePointer<Element> {
        precondition(slot >= 0 && slot < count, "Memory.Inline slot \(slot) out of range 0..<\(count)")
        return unsafe withUnsafePointer(to: _storage) { base in
            unsafe UnsafeMutablePointer(
                mutating: UnsafeRawPointer(base)
                    .advanced(by: slot * MemoryLayout<Element>.stride)
                    .assumingMemoryBound(to: Element.self)
            )
        }
    }

    /// Returns an immutable pointer to the element at the given zero-based slot.
    ///
    /// Disfavored overload — the mutable variant wins when both match.
    @unsafe
    @inlinable
    @_disfavoredOverload
    public func pointer(at slot: Int) -> UnsafePointer<Element> {
        unsafe UnsafePointer(pointer(at: slot) as UnsafeMutablePointer<Element>)
    }

    /// Returns an immutable pointer to the element at the given physical slot.
    ///
    /// The typed-`Index` address computation behind the `Store.`Protocol`` witnesses.
    @unsafe
    @inlinable
    package func pointer(at slot: Index<Element>) -> UnsafePointer<Element> {
        unsafe withUnsafePointer(to: _storage) { base in
            unsafe UnsafeRawPointer(base)
                .advanced(by: Index<Element>.Offset(fromZero: slot) * .stride)
                .assumingMemoryBound(to: Element.self)
        }
    }

    /// Returns a mutable pointer to the element at the given physical slot.
    @unsafe
    @inlinable
    package func _mutablePointer(at slot: Index<Element>) -> UnsafeMutablePointer<Element> {
        unsafe UnsafeMutablePointer(mutating: pointer(at: slot))
    }
}

// MARK: - Properties

extension Memory.Inline where Element: ~Copyable {
    /// Storage capacity in slot count — the typed `Store.`Protocol`` witness.
    ///
    /// A runtime-accessible view of the compile-time `count` parameter.
    @inlinable
    public var capacity: Index<Element>.Count {
        // WHY: `count` is a compile-time constant generic, so the conversion is total.
        // swift-format-ignore: NeverUseForceTry
        // swiftlint:disable:next force_try
        try! Index<Element>.Count(count)
    }

    /// The initialization ledger — the `Store.Tracked.`Protocol`` witness.
    ///
    /// The getter exposes the stored ledger; the setter lets composing disciplines
    /// sync it (`storage.initialization = header.initialization`). The leaf's
    /// `deinit` honors whatever ranges are set here.
    @inlinable
    public var initialization: Store.Initialization<Element> {
        get { _initialization }
        set { _initialization = newValue }
    }

    /// Whether no slots are initialized.
    @inlinable
    public var isEmpty: Bool {
        _initialization.isEmpty
    }

    /// The byte stride between consecutive elements.
    @inlinable
    public var elementStride: Int {
        MemoryLayout<Element>.stride
    }
}

// MARK: - Sendable

/// Sendable conformance for `Memory.Inline._Raw`.
///
/// `@_rawLayout` bypasses normal Sendable analysis. Unique ownership (via
/// `~Copyable`) guarantees the raw bytes transfer as one block.
extension Memory.Inline._Raw: @unsafe @unchecked Sendable where Element: Sendable {}

/// Sendable conformance for `Memory.Inline`.
///
/// `~Copyable` guarantees single ownership: the inline `@_rawLayout` buffer and
/// its ledger travel together as one unit; transfer across isolation boundaries
/// is a move, not a share.
extension Memory.Inline: @unsafe @unchecked Sendable where Element: Sendable {}
