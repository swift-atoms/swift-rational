import Integer
import Rational
import Testing

enum `Rational Floating Point Tests` {}

extension `Rational Floating Point Tests` {
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
}

extension `Rational Floating Point Tests` {
    @Suite struct `Floating point values convert to rationals exactly and back unchanged` {
        @Test func `Finite Float16 values across every binade convert exactly and back to themselves`() throws {
            try stride(from: UInt16.min, through: UInt16.max, by: 7).map(Float16.init(bitPattern:)).filter(\.isFinite).forEach { value in
                let exact = try Rational(exactly: value)
                #expect(Float16(exact) == value)
                #expect(exact.approximation(as: Float16.self) == value)
                #expect(Double(exact) == Double(value))
            }
        }

        @Test func `Exact conversion keeps every binary digit`() throws {
            #expect(try Rational(exactly: 0.1) == Rational(numerator: 3_602_879_701_896_397, denominator: powerOfTwo(55)))
            #expect(try Rational(exactly: -12.25) == Rational("-49/4"))
            #expect(try Rational(exactly: Double.leastNonzeroMagnitude) == Rational(numerator: 1, denominator: powerOfTwo(1074)))
            #expect(try Rational(exactly: Double.greatestFiniteMagnitude) == Rational(powerOfTwo(1024) - powerOfTwo(971)))
            #expect(try Rational(exactly: -0.0) == .zero)
            #expect(try Rational(exactly: Float(1) / 3).approximation(as: Float.self) == Float(1) / 3)
            for value in [Double.nan, .infinity, -.infinity] {
                #expect(throws: Rational.Error.unrepresentable) { try Rational(exactly: value) }
            }
        }

        @Test func `Floating point initializers equal approximation`() throws {
            let value = try Rational(numerator: 2, denominator: 3, polarity: .negative)
            #expect(Double(value) == value.approximation(as: Double.self))
            #expect(Float(value) == value.approximation(as: Float.self))
            #expect(Double(Rational.half) == 0.5)
        }
    }

    @Suite struct `Rounding to a denominator finds the nearest fraction` {
        @Test func `A fixed denominator gives the nearest multiple with ties away from zero`() throws {
            try (-40...40).forEach { numerator in
                try (1...12).forEach { denominator in
                    let value = try Rational(numerator: numerator, denominator: denominator)
                    try [1, 2, 3, 8, 120].forEach { grid in
                        let result = try value.rounded(denominator: grid)
                        #expect((result * Rational(grid)).denominator == 1)
                        let distance = (result - value).absolute * Rational(grid) * 2
                        #expect(distance <= 1)
                        if distance == 1 { #expect(result.absolute > value.absolute) }
                    }
                }
            }
            #expect(try Rational(numerator: 5, denominator: 8).rounded(denominator: 4) == Rational("3/4"))
            #expect(try Rational(exactly: 0.3).rounded(denominator: 120) == Rational("3/10"))
            #expect(throws: Rational.Error.denominator) { try Rational.half.rounded(denominator: 0) }
        }

        @Test func `A bounded denominator gives the closest fraction found by brute force`() throws {
            try (-24...24).forEach { numerator in
                try (1...16).forEach { denominator in
                    let value = try Rational(numerator: numerator, denominator: denominator)
                    try (1...7).forEach { bound in
                        let candidates = try (1...bound).flatMap { q in
                            let scaled = value * Rational(q)
                            return try [scaled.floor, scaled.ceiling].map { try Rational(numerator: $0, denominator: Integer(q)) }
                        }
                        let nearest = candidates.map { ($0 - value).absolute }.min()!
                        let expected = candidates.filter { ($0 - value).absolute == nearest }.max { $0.absolute < $1.absolute }!
                        let result = try value.rounded(denominator: ...bound)
                        #expect(result == expected)
                        #expect(result.denominator <= Integer(bound))
                    }
                }
            }
            let pi = try Rational(exactly: Double.pi)
            #expect(try pi.rounded(denominator: ...7) == Rational("22/7"))
            #expect(try pi.rounded(denominator: ...1000) == Rational("355/113"))
            #expect(try Rational.half.rounded(denominator: ...2) == .half)
            #expect(throws: Rational.Error.denominator) { try Rational.half.rounded(denominator: ...0) }
        }
    }
}

private func powerOfTwo(_ exponent: Int) -> Integer {
    (0..<exponent).reduce(Integer.one) { value, _ in value * 2 }
}
