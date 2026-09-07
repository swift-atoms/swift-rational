extension Rational {



    public func approximation<Scalar: BinaryFloatingPoint>(as type: Scalar.Type) -> Scalar {
        let value = scaledApproximation(as: type)
        return Scalar(sign: numerator.isNegative ? .minus : .plus,
            exponent: Scalar.Exponent(clamping: value.exponent),
            significand: value.significand.magnitude)
    }



    public func scaledApproximation<Scalar: BinaryFloatingPoint>(
        as type: Scalar.Type
    ) -> (significand: Scalar, exponent: Int) {
        let n = numerator.scaledApproximation(as: type)
        let d = denominator.scaledApproximation(as: type)
        return (n.significand / d.significand, n.exponent - d.exponent)
    }
}
