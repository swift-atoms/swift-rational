import Rational
import Testing
import Foundation

@Suite struct UniversalRationalTests {
    @Test func signedComponentsAndArbitraryPrecisionSerialization() throws {
        let a = try Rational(numerator: -6, denominator: -8)
        #expect(a.numerator == 3 && a.denominator == 4)
        let b = try Rational(numerator: 6, denominator: -8)
        #expect(b.numerator == -3 && b.denominator == 4)
        let value: Rational = 123456789012345678901234567890123456789012345678901234567890
        #expect(value == Rational(value.description))
        let fraction = try value.divided(by: value + 1)
        #expect(try JSONDecoder().decode(Rational.self, from: JSONEncoder().encode(fraction)) == fraction)
        #expect(Rational("-6/-8") == a)
        for text in ["", "1/", "/1", "1/0", "1/2/3", "NaN", "Infinity"] { #expect(Rational(text) == nil) }
        #expect(try Rational(numerator: 4, denominator: 9).root(2) == Rational("2/3"))
        #expect(Rational(2).root(2) == nil)
    }

    @Test func destinationRangeIsCheckedAfterExactArithmetic() throws {
        let enormous = try Rational(10).raised(to: 200)
        #expect(try (enormous + 1 - enormous).integer(as: Int8.self) == 1)
        #expect(throws: Rational.Error.overflow) { try enormous.integer(as: Int128.self) }
        #expect(try Rational(-128).integer(as: Int8.self) == .min)
        #expect(throws: Rational.Error.overflow) { try Rational(128).integer(as: Int8.self) }
        #expect(try Rational(numerator: 2, denominator: 3).applying(to: Int8(3)) == 2)
        #expect(try enormous.divided(by: enormous + 1).approximation == 1)
    }
}
