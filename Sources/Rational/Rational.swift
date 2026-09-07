public import Integer
public import Magnitude
public import Polarity



public struct Rational: Hashable, Sendable {
    public let numerator: Integer
    public let denominator: Integer
}

extension Rational {
    public enum Error: Swift.Error, Hashable, Sendable {
        case denominator
        case zero

        case overflow
        case inexact
        case unrepresentable
    }

    public init(numerator: Integer, denominator: Integer = 1, polarity: Polarity = .positive) throws(Error) {
        guard !denominator.isZero else { throw .denominator }
        self.init(reducing: polarity == .negative ? -numerator : numerator, denominator: denominator)
    }

    public init(_ value: Integer) {
        self.numerator = value
        self.denominator = .one
    }

    internal init(reducing numerator: Integer, denominator: Integer) {
        precondition(!denominator.isZero)
        if numerator.isZero { self.numerator = .zero; self.denominator = .one; return }
        let common = Integer.gcd(numerator, denominator)
        let sign = denominator.isNegative
        self.numerator = try! (sign ? -numerator : numerator).quotientAndRemainder(dividingBy: common).quotient
        self.denominator = try! denominator.absolute.quotientAndRemainder(dividingBy: common).quotient
    }

    public static var zero: Self { Self(Integer.zero) }
    public static var one: Self { Self(Integer.one) }
    public var polarity: Polarity? { numerator.isZero ? nil : numerator.isNegative ? .negative : .positive }
    public var absolute: Self { numerator.isNegative ? -self : self }
    public static prefix func - (value: Self) -> Self {
        Self(reducing: -value.numerator, denominator: value.denominator)
    }
}

extension Rational: Magnitude::Scalar {
    public var isFinite: Bool { true }
}
extension Rational: Magnitude::Representable {
    public typealias Magnitude = Magnitude::Magnitude<Rational>
    public var magnitude: Magnitude { try! Magnitude(validating: absolute) }
}
