extension Rational {
    public var approximation: Double {
        let n = numerator.scaledApproximation
        let d = denominator.scaledApproximation
        return Double(sign: numerator.isNegative ? .minus : .plus,
            exponent: n.exponent - d.exponent, significand: abs(n.significand) / d.significand)
    }
}
