extension Rational {
    /// The greatest whole number not above the value: 7/2 gives 3 and -7/2 gives -4.
    public var floor: Integer {
        let division = Self.trapping { try numerator.quotientAndRemainder(dividingBy: denominator) }
        return division.remainder.isNegative ? division.quotient - .one : division.quotient
    }

    /// The least whole number not below the value: 7/2 gives 4 and -7/2 gives -3.
    public var ceiling: Integer { -(-self).floor }
}
