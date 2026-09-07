extension Rational: Swift.Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
}
