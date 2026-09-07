extension Rational: Swift.CustomStringConvertible {
    public var description: String {
        denominator == 1 ? numerator.description : numerator.description + "/" + denominator.description
    }
}
