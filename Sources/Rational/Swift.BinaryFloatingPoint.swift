extension Swift::BinaryFloatingPoint {
    /// The nearest representable value to a rational, exactly `value.approximation(as: Self.self)`.
    public init(_ value: Rational) {
        self = value.approximation(as: Self.self)
    }
}
