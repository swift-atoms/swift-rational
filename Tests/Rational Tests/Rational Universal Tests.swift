import Foundation
import Rational
import Testing

enum `Rational Universal Tests` {}

extension `Rational Universal Tests` {
    @Suite struct `Rationals validate arbitrary precision construction and conversion` {
        @Test func `Signed components serialize with arbitrary precision`() throws {
            let a = try Rational(numerator: -6, denominator: -8)
            #expect(a.numerator == 3 && a.denominator == 4)
            let b = try Rational(numerator: 6, denominator: -8)
            #expect(b.numerator == -3 && b.denominator == 4)
            let value: Rational = 123_456_789_012_345_678_901_234_567_890_123_456_789_012_345_678_901_234_567_890
            #expect(value == Rational(value.description))
            let fraction = try value.divided(by: value + 1)
            #expect(try JSONDecoder().decode(Rational.self, from: JSONEncoder().encode(fraction)) == fraction)
            #expect(Rational("-6/-8") == a)
            for text in ["", "1/", "/1", "1/0", "1/2/3", "NaN", "Infinity"] { #expect(Rational(text) == nil) }
            #expect(try Rational(numerator: 4, denominator: 9).root(2) == Rational("2/3"))
            #expect(Rational(2).root(2) == nil)
        }

        @Test func `Destination ranges are checked after exact arithmetic`() throws {
            let enormous = try Rational(10).raised(to: 200)
            #expect(try (enormous + 1 - enormous).integer(as: Int8.self) == 1)
            #expect(throws: Rational.Error.overflow) { try enormous.integer(as: Int128.self) }
            #expect(try Rational(-128).integer(as: Int8.self) == .min)
            #expect(throws: Rational.Error.overflow) { try Rational(128).integer(as: Int8.self) }
            #expect(try Rational(numerator: 2, denominator: 3).applying(to: Int8(3)) == 2)
            #expect(try enormous.divided(by: enormous + 1).approximation == 1)
        }

        @Test func `Decimals read exactly as digits over a power of ten`() throws {
            #expect(Rational("0.5") == .half)
            #expect(Rational("-12.25") == (try Rational(numerator: 49, denominator: 4, polarity: .negative)))
            #expect(Rational("+0.50") == .half)
            #expect(Rational("-0.0") == .zero)
            #expect(Rational("3") == 3 && Rational("3.000") == 3)
            #expect(Rational("0." + String(repeating: "0", count: 99) + "1") == (try Rational(10).raised(to: -100)))
            #expect(Rational("0.1")! + Rational("0.2")! == Rational("0.3"))
            for text in [".5", "5.", "-.5", "1.2.3", "1.5/2", "1/2.5", "1e3", "0x1", " 1", "1.-5", "1.+5", "1,5", "-", "."] {
                #expect(Rational(text) == nil)
            }
        }

        @Test func `Every description reads back as the same value`() throws {
            try (-30...30).forEach { numerator in
                try (-7...7).filter { $0 != 0 }.forEach { denominator in
                    let value = try Rational(numerator: numerator, denominator: denominator)
                    #expect(Rational(String(describing: value)) == value)
                }
            }
            let wide = try Rational(numerator: UInt128.max, denominator: UInt128.max - 1, polarity: .negative)
            #expect(Rational(String(describing: wide)) == wide)
        }
    }
}
