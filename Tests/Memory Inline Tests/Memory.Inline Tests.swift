import Memory_Address
import Memory_Region
import Testing

@testable import Memory_Inline

@Suite(.serialized)
struct `Memory.Inline Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Memory.Inline Tests`.Unit {
    @Test func `capacity equals the value generic byte count`() {
        let inline = Memory.Inline<256>()
        let cap = inline.capacity
        #expect(cap.underlying == 256)
    }

    @Test func `capacity tracks distinct instantiations`() {
        let a = Memory.Inline<16>()
        let b = Memory.Inline<4096>()
        #expect(a.capacity.underlying == 16)
        #expect(b.capacity.underlying == 4096)
    }

    @Test func `base is reachable and stable across reads`() {
        let inline = Memory.Inline<128>()
        let first = inline.base
        let second = inline.base
        #expect(first == second)
    }

    @Test func `conforms Memory Region generically`() {
        func capacity<R: Memory.Region & ~Copyable>(_ region: borrowing R) -> Memory.Address.Count {
            region.capacity
        }
        let inline = Memory.Inline<64>()
        #expect(capacity(inline).underlying == 64)
    }

    @Test func `drop does not crash`() {
        do {
            let inline = Memory.Inline<512>()
            #expect(inline.capacity.underlying == 512)
            _ = inline.base
        }

        #expect(Bool(true))
    }
}
