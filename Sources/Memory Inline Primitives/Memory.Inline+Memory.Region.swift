public import Memory_Address_Primitives
public import Memory_Primitive
public import Memory_Region_Primitives

extension Memory.Inline: Memory.Region {

    @inlinable
    public var capacity: Memory.Address.Count {
        Memory.Address.Count(UInt(n))
    }

    @inlinable
    public var base: Memory.Address {

        withUnsafePointer(to: _storage) { pointer in
            unsafe Memory.Address(UnsafeMutableRawPointer(mutating: pointer))
        }
    }
}
