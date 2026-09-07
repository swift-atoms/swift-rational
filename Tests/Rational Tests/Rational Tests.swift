import Foundation
import Magnitude
import Polarity
import Rational
import Testing

@Suite
struct `Rational Tests` {}

extension `Rational Tests` {
    @Test
    func `fractions are reduced and zero is canonical`() throws {
        let value = try Rational(numerator: 60, denominator: 120, polarity: .negative)
        #expect(value.numerator == -1 && value.denominator == 2 && value.polarity == .negative)
        #expect(try Rational(numerator: 0, denominator: UInt128.max, polarity: .negative) == .zero)
        #expect(Rational.zero.polarity == nil && Rational.zero.denominator == 1)
        #expect(throws: Rational.Error.denominator) { try Rational(numerator: 0, denominator: 0) }
        #expect(throws: Rational.Error.zero) { try Rational.zero.inverted() }
    }

    @Test
    func `small fractions agree with exact wider integer arithmetic`() throws {
        for left in Int128(-16)...16 {
            for right in Int128(-16)...16 {
                for a in UInt128(1)...8 {
                    for b in UInt128(1)...8 {
                        let lhs = try Rational(numerator: left.magnitude, denominator: a, polarity: left < 0 ? .negative : .positive)
                        let rhs = try Rational(numerator: right.magnitude, denominator: b, polarity: right < 0 ? .negative : .positive)
                        let expected = try Rational(left * Int128(b) + right * Int128(a)).divided(by: Rational(Int128(a * b)))
                        #expect(try lhs.adding(rhs) == expected)
                        #expect(try lhs.subtracting(rhs).adding(rhs) == lhs)
                        #expect((lhs < rhs) == (left * Int128(b) < right * Int128(a)))
                        let product = try Rational(left * right).divided(by: Rational(Int128(a * b)))
                        #expect(try lhs.multiplied(by: rhs) == product)
                    }
                }
            }
        }
    }

    @Test
    func `full-width products cancel before storage overflow`() throws {
        let lhs = try Rational(numerator: UInt128.max, denominator: UInt128.max - 1)
        #expect(try lhs.multiplied(by: lhs.inverted()) == .one)
        #expect(try lhs.subtracting(Rational(numerator: 1, denominator: UInt128.max - 1)) == .one)
        #expect(try lhs.subtracting(lhs) == .zero)
        let half = try Rational(numerator: UInt128.max, denominator: 2)
        let maximum = try Rational(numerator: UInt128.max)
        #expect(try half.adding(half) == maximum)
        #expect(try (-half).adding(-half) == -maximum)
        #expect(try maximum.adding(-maximum) == .zero)
        #expect(maximum.adding(.one) - maximum == .one)
        #expect(try maximum.multiplied(by: Rational(2)).divided(by: 2) == maximum)
    }

    @Test
    func `comparison uses exact full-width cross products`() throws {
        let a = try Rational(numerator: UInt128.max, denominator: UInt128.max - 1)
        let b = try Rational(numerator: UInt128.max - 1, denominator: UInt128.max - 2)
        #expect(a < b)
        #expect(-b < -a)
        #expect(a > .one && -a < .zero)
    }

    @Test
    func `fine temporal units compose and invert exactly`() throws {
        let yocto: UInt128 = 1_000_000_000_000_000_000_000_000
        let factor = try Rational(numerator: yocto)
        #expect(try factor.inverted().multiplied(by: factor) == .one)
        #expect(try factor.applying(to: Int128(-3)) == -3_000_000_000_000_000_000_000_000)
        #expect(try factor.inverted().applying(to: -Int128(yocto)) == -1)
        #expect(throws: Rational.Error.inexact) { try factor.inverted().applying(to: Int128(1)) }
    }

    @Test
    func `integer boundaries include Int128 minimum and unsigned maximum`() throws {
        #expect(try Rational(Int128.min).integer(as: Int128.self) == .min)
        #expect(try Rational.one.applying(to: Int128.min) == .min)
        #expect(try Rational(numerator: 1, denominator: 2).applying(to: Int128.min) == Int128.min / 2)
        #expect(throws: Rational.Error.overflow) { try Rational(-1).applying(to: Int128.min) }
        #expect(throws: Rational.Error.inexact) { try Rational(numerator: 1, denominator: 2).integer(as: Int128.self) }
        #expect(try Rational.one.applying(to: UInt128.max) == .max)
        #expect(try Rational(numerator: UInt128.max, denominator: 2).applying(to: UInt128(2)) == .max)
        #expect(throws: Rational.Error.unrepresentable) { try Rational(-1).applying(to: UInt128(1)) }
    }

    @Test
    func `signed quotient floors negative quantities`() throws {
        let ratio = Rational(60)
        for input in [Int128(-121), -120, -61, -60, -1, 0, 1, 59, 60, 121] {
            let result = try ratio.quotient(dividing: input)
            #expect(result.quotient * 60 + result.remainder == input)
            #expect(result.remainder >= 0 && result.remainder < 60)
        }
        #expect(try ratio.quotient(dividing: -1).quotient == -1)
        #expect(try ratio.quotient(dividing: -1).remainder == 59)
    }

    @Test
    func `magnitude validates rational polarity and exposes absolute value`() throws {
        let value = try Rational(numerator: 1, denominator: 3, polarity: .negative)
        #expect(value.magnitude.value == -value)
        #expect(throws: Magnitude<Rational>.Error.negative) { try Magnitude(validating: value) }
        #expect(try Magnitude(validating: Int128.max).value == .max)
        #expect(try Magnitude(validating: UInt128.max).value == .max)
    }

    @Test
    func `Codable round trips full-width fractions and rejects invalid denominators`() throws {
        let value = try Rational(numerator: UInt128.max, denominator: UInt128.max - 1, polarity: .negative)
        #expect(try JSONDecoder().decode(Rational.self, from: JSONEncoder().encode(value)) == value)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(Rational.self, from: Data(#"{"numerator":1,"denominator":0,"polarity":{"positive":{}}}"#.utf8))
        }
    }
}

extension `Rational Tests` {
    @Test
    func `denominator reduction happens after full-width addition`() throws {
        let denominator = UInt128.max - 1
        let lhs = try Rational(numerator: UInt128.max, denominator: denominator)
        let rhs = try Rational(numerator: UInt128.max - 2, denominator: denominator)
        #expect(try lhs.add.exact(rhs) == Rational(2))
        let a = try Rational(numerator: 1, denominator: UInt128.max)
        let b = try Rational(numerator: 1, denominator: UInt128.max - 1)
        #expect(a.adding(b).subtracting(b) == a)
    }
}
