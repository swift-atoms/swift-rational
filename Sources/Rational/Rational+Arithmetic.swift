public import Integer

extension Rational {
    public func inverted() throws(Error) -> Self {
        guard !numerator.isZero else { throw .zero }
        return Self(reducing: denominator, denominator: numerator)
    }

    public func adding(_ other: Self) -> Self {
        let common = Integer.gcd(denominator, other.denominator)
        let left = try! denominator.quotientAndRemainder(dividingBy: common).quotient
        let right = try! other.denominator.quotientAndRemainder(dividingBy: common).quotient
        return Self(reducing: numerator * right + other.numerator * left, denominator: left * other.denominator)
    }

    public func subtracting(_ other: Self) -> Self { adding(-other) }

    /// Cross-cancels before multiplication to limit intermediate storage.
    public func multiplied(by other: Self) -> Self {
        if numerator.isZero || other.numerator.isZero { return .zero }
        let a = Integer.gcd(numerator, other.denominator)
        let b = Integer.gcd(other.numerator, denominator)
        let n = try! numerator.quotientAndRemainder(dividingBy: a).quotient
            * other.numerator.quotientAndRemainder(dividingBy: b).quotient
        let d = try! denominator.quotientAndRemainder(dividingBy: b).quotient
            * other.denominator.quotientAndRemainder(dividingBy: a).quotient
        return Self(reducing: n, denominator: d)
    }

    public func divided(by other: Self) throws(Error) -> Self { multiplied(by: try other.inverted()) }

    public func raised(to exponent: Integer) throws(Error) -> Self {
        var factor = exponent.isNegative ? try inverted() : self
        var count = exponent.absolute
        var result = Self.one
        while !count.isZero {
            if count.isOdd { result = result * factor }
            count = try! count.quotientAndRemainder(dividingBy: 2).quotient
            if !count.isZero { factor = factor * factor }
        }
        return result
    }

    /// Returns a rational root only when both integer components have exact roots.
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
