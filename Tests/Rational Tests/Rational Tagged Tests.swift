import Rational
import Tagged
import Testing

private enum Unit {}

@Suite
struct `Rational Tagged Tests` {}

extension `Rational Tagged Tests` {
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
    func `checked quantities expose representational overflow`() throws {
        let maximum = Tagged<Unit, Rational>(_unchecked: try Rational(numerator: .max))
        #expect(throws: Rational.Error.overflow) { try maximum.add.exact(.one) }
        #expect(throws: Rational.Error.overflow) { try (-maximum).subtract.exact(.one) }
    }
}
