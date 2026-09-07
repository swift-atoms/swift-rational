import Rational
import Testing

@Suite struct `Rational approximation preserves scale before conversion` {
    @Test func `Huge components can form a finite small ratio`() throws {
        let huge = powerOfTwo(4096)
        let fraction = try Rational(numerator: huge + 1, denominator: huge * 2 + 1)
        #expect(fraction.approximation(as: Float16.self) == 0.5)
        #expect(fraction.approximation(as: Float.self) == 0.5)
        #expect(fraction.approximation(as: Double.self) == 0.5)
        #expect((-fraction).approximation(as: Double.self) == -0.5)
    }

    @Test func `Binary fractions preserve destination subnormal values`() throws {
        let denominator = powerOfTwo(24)
        let fraction = try Rational(numerator: 1, denominator: denominator)
        #expect(fraction.approximation(as: Float16.self) == .leastNonzeroMagnitude)
        #expect((-fraction).approximation(as: Float16.self) == -.leastNonzeroMagnitude)
        #expect(try Rational(numerator: 1, denominator: denominator * 2).approximation(as: Float16.self) == 0)
        #expect(try Rational(numerator: 3, denominator: denominator * 2).approximation(as: Float16.self) == 2 * Float16.leastNonzeroMagnitude)
    }
}

private func powerOfTwo(_ exponent: Int) -> Integer {
    (0..<exponent).reduce(Integer.one) { value, _ in value * 2 }
}
