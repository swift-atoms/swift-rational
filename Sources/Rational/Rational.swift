public import Integer
public import Magnitude
public import Polarity

public struct Rational: Hashable, Sendable {
    public let numerator: Integer
    public let denominator: Integer
}

extension Rational {

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
        if numerator.isZero {
            self.numerator = .zero
            self.denominator = .one
            return
        }
        let common = Integer.gcd(numerator, denominator)
        let sign = denominator.isNegative
        self.numerator = Self.trapping {
            try (sign ? -numerator : numerator).quotientAndRemainder(dividingBy: common).quotient
        }
        self.denominator = Self.trapping {
            try denominator.absolute.quotientAndRemainder(dividingBy: common).quotient
        }
    }

    /// Evaluates `body`, whose failure would violate an invariant of the call site.
    ///
    /// Used for exact division by a non-zero common divisor and for validating
    /// values that are valid by construction.
    internal static func trapping<T, Failure: Swift::Error>(_ body: () throws(Failure) -> T) -> T {
        do {
            return try body()
        } catch {
            preconditionFailure("Invariant violated")
        }
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
    public var magnitude: Magnitude { Self.trapping { try Magnitude(validating: absolute) } }
}

extension Rational {
    public func inverted() throws(Error) -> Self {
        guard !numerator.isZero else { throw .zero }
        return Self(reducing: denominator, denominator: numerator)
    }

    public func adding(_ other: Self) -> Self {
        let common = Integer.gcd(denominator, other.denominator)
        let left = Self.trapping { try denominator.quotientAndRemainder(dividingBy: common).quotient }
        let right = Self.trapping { try other.denominator.quotientAndRemainder(dividingBy: common).quotient }
        return Self(reducing: numerator * right + other.numerator * left, denominator: left * other.denominator)
    }

    public func subtracting(_ other: Self) -> Self { adding(-other) }

    public func multiplied(by other: Self) -> Self {
        if numerator.isZero || other.numerator.isZero { return .zero }
        let a = Integer.gcd(numerator, other.denominator)
        let b = Integer.gcd(other.numerator, denominator)
        let n = Self.trapping {
            try numerator.quotientAndRemainder(dividingBy: a).quotient
                * other.numerator.quotientAndRemainder(dividingBy: b).quotient
        }
        let d = Self.trapping {
            try denominator.quotientAndRemainder(dividingBy: b).quotient
                * other.denominator.quotientAndRemainder(dividingBy: a).quotient
        }
        return Self(reducing: n, denominator: d)
    }

    public func divided(by other: Self) throws(Error) -> Self { multiplied(by: try other.inverted()) }

    public func raised(to exponent: Integer) throws(Error) -> Self {
        var factor = exponent.isNegative ? try inverted() : self
        var count = exponent.absolute
        var result = Self.one
        while !count.isZero {
            if count.isOdd { result *= factor }
            count = Self.trapping { try count.quotientAndRemainder(dividingBy: 2).quotient }
            if !count.isZero { factor *= factor }
        }
        return result
    }

    public func root(_ degree: Int) -> Self? {
        guard let n = numerator.root(degree), let d = denominator.root(degree) else { return nil }
        return Self(reducing: n, denominator: d)
    }

    public static func + (lhs: Self, rhs: Self) -> Self { lhs.adding(rhs) }
    public static func - (lhs: Self, rhs: Self) -> Self { lhs.subtracting(rhs) }
    public static func * (lhs: Self, rhs: Self) -> Self { lhs.multiplied(by: rhs) }
    public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
    public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }
}

extension Rational {

    public func approximation<Scalar: BinaryFloatingPoint>(as type: Scalar.Type) -> Scalar {
        let value = scaledApproximation(as: type)
        return Scalar(
            sign: numerator.isNegative ? .minus : .plus,
            exponent: Scalar.Exponent(clamping: value.exponent),
            significand: value.significand.magnitude
        )
    }

    public func scaledApproximation<Scalar: BinaryFloatingPoint>(
        as type: Scalar.Type
    ) -> (significand: Scalar, exponent: Int) {
        let n = numerator.scaledApproximation(as: type)
        let d = denominator.scaledApproximation(as: type)
        return (n.significand / d.significand, n.exponent - d.exponent)
    }
}

extension Rational {
    public init<T: Swift::BinaryInteger>(_ value: T) { self.init(Integer(value)) }

    @_disfavoredOverload
    public init<N: Swift::BinaryInteger, D: Swift::BinaryInteger>(
        numerator: N,
        denominator: D,
        polarity: Polarity = .positive
    ) throws(Error) {
        try self.init(numerator: Integer(numerator), denominator: Integer(denominator), polarity: polarity)
    }

    @_disfavoredOverload
    public init<N: Swift::BinaryInteger>(numerator: N, polarity: Polarity = .positive) throws(Error) {
        try self.init(numerator: Integer(numerator), polarity: polarity)
    }

    @_disfavoredOverload
    public func raised<T: Swift::BinaryInteger>(to exponent: T) throws(Error) -> Self {
        try raised(to: Integer(exponent))
    }

    public func integer<T: Swift::FixedWidthInteger>(as type: T.Type) throws(Error) -> T {
        guard denominator == .one else { throw .inexact }
        guard !numerator.isNegative || T.isSigned else { throw .unrepresentable }
        guard let result = numerator.exactly(type) else { throw .overflow }
        return result
    }

    public func applying<T: Swift::FixedWidthInteger>(to value: T) throws(Error) -> T {
        try (self * Self(value)).integer(as: T.self)
    }

    public func quotient<T: Swift::FixedWidthInteger>(dividing value: T) throws(Error) -> (quotient: T, remainder: T) {
        guard !numerator.isZero else { throw .zero }
        guard !numerator.isNegative else { throw .unrepresentable }
        guard denominator == .one else { throw .inexact }
        var result = Self.trapping { try Integer(value).quotientAndRemainder(dividingBy: numerator) }
        if result.remainder.isNegative {
            result.quotient -= .one
            result.remainder += numerator
        }
        guard let q = result.quotient.exactly(T.self), let r = result.remainder.exactly(T.self) else { throw .overflow }
        return (q, r)
    }
}

extension Rational {
    /// The greatest whole number not above the value: 7/2 gives 3 and -7/2 gives -4.
    public var floor: Integer {
        let division = Self.trapping { try numerator.quotientAndRemainder(dividingBy: denominator) }
        return division.remainder.isNegative ? division.quotient - .one : division.quotient
    }

    /// The least whole number not below the value: 7/2 gives 4 and -7/2 gives -3.
    public var ceiling: Integer { -(-self).floor }
}

extension Rational: Swift::Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
}

extension Rational: Swift::CustomStringConvertible {
    public var description: String {
        denominator == 1 ? numerator.description : numerator.description + "/" + denominator.description
    }
}

extension Rational {
    public var approximation: Double { approximation(as: Double.self) }
}

extension Rational: Swift::ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Swift::StaticBigInt) {
        self.init(Integer(integerLiteral: value))
    }
}

extension Rational: Swift::LosslessStringConvertible {

    public init?(_ description: String) {
        let parts = description.split(separator: "/", omittingEmptySubsequences: false)
        guard (1...2).contains(parts.count), let n = Integer(String(parts[0])) else { return nil }
        let d = parts.count == 2 ? Integer(String(parts[1])) : .one
        guard let d, !d.isZero else { return nil }
        self.init(reducing: n, denominator: d)
    }
}
