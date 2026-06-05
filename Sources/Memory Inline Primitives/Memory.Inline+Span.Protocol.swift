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
public import Memory_Primitive
public import Span_Protocol_Primitives
public import Store_Initialization_Primitives

// MARK: - Span / MutableSpan (~Copyable)

extension Memory.Inline where Element: ~Copyable {
    /// Safe, bounds-checked read access to the initialized prefix.
    ///
    /// Returns a `Span` over elements `0..<initialization.count`.
    ///
    /// - Precondition: Storage must be linearly initialized (`.empty` or `.one(0..<n)`).
    /// - Complexity: O(1)
    @inlinable
    public var span: Swift.Span<Element> {
        @_lifetime(borrow self)
        borrowing get {
            let span = unsafe Swift.Span(
                _unsafeStart: pointer(at: Index<Element>.zero),
                count: initialization.count
            )
            return unsafe _overrideLifetime(span, borrowing: self)
        }
    }

    /// Safe, bounds-checked write access to the initialized prefix.
    ///
    /// - Precondition: Storage must be linearly initialized.
    /// - Complexity: O(1)
    @inlinable
    public var mutableSpan: Swift.MutableSpan<Element> {
        @_lifetime(&self)
        mutating get {
            let span = unsafe Swift.MutableSpan(
                _unsafeStart: _mutablePointer(at: Index<Element>.zero),
                count: initialization.count
            )
            return unsafe _overrideLifetime(span, mutating: &self)
        }
    }
}

// MARK: - Span.Protocol Conformance

extension Memory.Inline: Span.`Protocol` where Element: ~Copyable {
    /// Unsafe read access for C interop with unannotated APIs.
    ///
    /// - Precondition: Storage must be linearly initialized.
    @inlinable
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<Element>) throws(E) -> R
    ) throws(E) -> R {
        return try unsafe body(
            UnsafeBufferPointer(
                start: pointer(at: Index<Element>.zero),
                count: initialization.count
            )
        )
    }
}
