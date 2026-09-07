import Rational
import Tagged
import Testing

private enum Unit {}

@Suite
struct `Rational arithmetic preserves the tagged quantity domain` {}

extension `Rational arithmetic preserves the tagged quantity domain` {
    @Test
    func `checked and ordinary arithmetic preserve the quantity domain`() throws {
        let half = Tagged<Unit, Rational>(_unchecked: try Rational(numerator: 1, denominator: 2))
        let third = Tagged<Unit, Rational>(_unchecked: try Rational(numerator: 1, denominator: 3))
        let sum: Tagged<Unit, Rational> = try half.add.exact(third)
        #expect(try sum.underlying == Rational(numerator: 5, denominator: 6))
        #expect(try sum.subtract.exact(third) == half)
        #expect(half + third == sum)
        #expect(sum - third == half)
        #expect(half + (-half) == .zero)
    }

    @Test
    func `exact quantities grow beyond machine integer bounds`() throws {
        let maximum = Tagged<Unit, Rational>(_unchecked: try Rational(numerator: UInt128.max))
        #expect(maximum.add.exact(.one) - maximum == .one)
        #expect((-maximum).subtract.exact(.one) + maximum == -Tagged<Unit, Rational>.one)
    }
}
