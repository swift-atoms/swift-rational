import Rational
import Testing

@Suite struct `Arbitrary precision rationals preserve field laws and normalization` {
    @Test func `large exact fractions retain cancellation equality and hash`() throws {
        let large = try Rational(10).raised(to: 120)
        let third = try Rational(1).divided(by: 3)
        let value = try (large * 7).divided(by: large * 21)
        #expect(value == third)
        #expect(Set([value, third]).count == 1)
        #expect(value.description == "1/3")
        #expect((large + 1) - large == 1)
        #expect(try (large + 1).divided(by: large + 1) == 1)
        #expect(large.description == "1" + String(repeating: "0", count: 120))
    }

    @Test func `field laws agree with small integer arithmetic`() throws {
        for a in -12...12 {
            for b in -12...12 where b != 0 {
                let lhs = Rational(Int128(a))
                let rhs = Rational(Int128(b))
                #expect(lhs + rhs == Rational(Int128(a + b)))
                #expect(lhs - rhs == Rational(Int128(a - b)))
                #expect(lhs * rhs == Rational(Int128(a * b)))
                #expect(try lhs.divided(by: rhs) * rhs == lhs)
                #expect((lhs < rhs) == (a < b))
                #expect(try (lhs + rhs).divided(by: rhs) == lhs.divided(by: rhs) + 1)
            }
        }
    }

    @Test func `Signs normalize and negative powers invert while zero division fails`() throws {
        #expect(-Rational.zero == .zero)
        #expect(try Rational(-2).raised(to: -3) == Rational(-1).divided(by: 8))
        #expect(try Rational.zero.raised(to: 0) == .one)
        #expect(throws: Rational.Error.zero) { try Rational.one.divided(by: .zero) }
        #expect(throws: Rational.Error.zero) { try Rational.zero.raised(to: -1) }
        #expect(Rational(Int128.min).description == String(Int128.min))
    }
}
