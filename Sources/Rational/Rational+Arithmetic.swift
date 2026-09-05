internal import Division
internal import Multiplication
internal import Polarity

extension Rational {
    public func inverted() throws(Error) -> Self {
        guard numerator != 0 else { throw .zero }
        return Self(normalized: denominator, denominator: numerator, polarity: sign)
    }

    /// Multiplies after cross-cancellation, avoiding unnecessary intermediate overflow.
    public func multiplied(by other: Self) throws(Error) -> Self {
        guard numerator != 0 && other.numerator != 0 else { return .zero }
        let left = Self.gcd(numerator, other.denominator)
        let right = Self.gcd(other.numerator, denominator)
        do {
            return Self(
                normalized: try Multiplication.exact(numerator / left, other.numerator / right),
                denominator: try Multiplication.exact(denominator / right, other.denominator / left),
                polarity: sign == other.sign ? .positive : .negative
            )
        } catch { throw .overflow }
    }

    public func divided(by other: Self) throws(Error) -> Self {
        try multiplied(by: other.inverted())
    }

    /// Adds with double-width intermediates, then reduces before checking stored bounds.
    public func adding(_ other: Self) throws(Error) -> Self {
        if numerator == 0 { return other }
        if other.numerator == 0 { return self }
        let common = Self.gcd(denominator, other.denominator)
        let left = Wide.product(numerator, other.denominator / common)
        let right = Wide.product(other.numerator, denominator / common)
        let sum: Wide
        let polarity: Polarity
        if sign == other.sign {
            sum = try left.adding(right)
            polarity = sign
        } else if left >= right {
            sum = left.subtracting(right)
            polarity = sign
        } else {
            sum = right.subtracting(left)
            polarity = other.sign
        }
        if sum.high == 0 && sum.low == 0 { return .zero }
        let reduction = Self.gcd(sum.remainder(dividingBy: common), common)
        let numerator = try sum.divided(by: reduction)
        let denominator: UInt128
        do {
            denominator = try Multiplication.exact(self.denominator / common, other.denominator / reduction)
        } catch { throw .overflow }
        return Self(normalized: numerator, denominator: denominator, polarity: polarity)
    }

    public func subtracting(_ other: Self) throws(Error) -> Self {
        try adding(-other)
    }

    public func integer() throws(Error) -> Int128 {
        guard denominator == 1 else { throw .inexact }
        return try Self.integer(magnitude: numerator, polarity: sign)
    }

    /// Applies the factor only when the signed result is exactly representable.
    public func applying(to value: Int128) throws(Error) -> Int128 {
        guard value != 0 && numerator != 0 else { return 0 }
        let magnitude = try applying(magnitude: value.magnitude)
        return try Self.integer(
            magnitude: magnitude,
            polarity: (value < 0) == (sign == .negative) ? .positive : .negative
        )
    }

    /// Applies the absolute factor to an unsigned integer, requiring an integral result.
    internal func applying(magnitude value: UInt128) throws(Error) -> UInt128 {
        let quotient: UInt128
        do { quotient = try Division.exact(value, by: denominator) }
        catch {
            switch error {
            case .inexact: throw .inexact
            default: throw .overflow
            }
        }
        do { return try Multiplication.exact(quotient, numerator) }
        catch { throw .overflow }
    }

    public func applying(to value: UInt128) throws(Error) -> UInt128 {
        guard value != 0 && numerator != 0 else { return 0 }
        guard sign == .positive else { throw .unrepresentable }
        return try applying(magnitude: value)
    }

    /// Divides an integer by a positive integral factor, with a nonnegative remainder.
    public func quotient(dividing value: Int128) throws(Error) -> (quotient: Int128, remainder: Int128) {
        guard numerator != 0 else { throw .zero }
        guard sign == .positive else { throw .unrepresentable }
        guard denominator == 1 else { throw .inexact }
        let result: (polarity: Polarity, quotient: UInt128, remainder: UInt128)
        do {
            result = try Division.Signed.euclidean(
                magnitude: value.magnitude,
                polarity: value < 0 ? .negative : .positive,
                by: numerator
            )
        } catch { throw .overflow }
        return (
            try Self.integer(magnitude: result.quotient, polarity: result.polarity),
            try Self.integer(magnitude: result.remainder, polarity: .positive)
        )
    }

    internal static func integer(magnitude: UInt128, polarity: Polarity) throws(Error) -> Int128 {
        if polarity == .negative && magnitude == Int128.min.magnitude { return .min }
        guard let value = Int128(exactly: magnitude) else { throw .overflow }
        return polarity == .negative ? -value : value
    }
}

extension Rational {
    public static func + (lhs: Self, rhs: Self) -> Self {
        do { return try lhs.adding(rhs) }
        catch { preconditionFailure("Rational overflow in addition") }
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        do { return try lhs.subtracting(rhs) }
        catch { preconditionFailure("Rational overflow in subtraction") }
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        do { return try lhs.multiplied(by: rhs) }
        catch { preconditionFailure("Rational overflow in multiplication") }
    }
}
