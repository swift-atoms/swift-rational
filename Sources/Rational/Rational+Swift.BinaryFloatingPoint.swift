extension Rational {
    /// Approximates in the requested binary format without an intermediate Double.
    /// Coefficients are rounded before division; this is not a correctly-rounded conversion guarantee.
    /// Overflow produces signed infinity and underflow follows the destination format.
    public func approximation<Scalar: BinaryFloatingPoint>(as type: Scalar.Type) -> Scalar {
        let value = scaledApproximation(as: type)
        return Scalar(sign: numerator.isNegative ? .minus : .plus,
            exponent: Scalar.Exponent(clamping: value.exponent),
            significand: value.significand.magnitude)
    }

    /// Approximates the ratio while leaving its binary scale unapplied.
    /// The significand stays finite even when either integer exceeds the scalar's range.
    public func scaledApproximation<Scalar: BinaryFloatingPoint>(
        as type: Scalar.Type
    ) -> (significand: Scalar, exponent: Int) {
        let n = numerator.scaledApproximation(as: type)
        let d = denominator.scaledApproximation(as: type)
        return (n.significand / d.significand, n.exponent - d.exponent)
    }
}
