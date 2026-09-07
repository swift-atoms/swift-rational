public import Integer
extension Rational: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Swift.StaticBigInt) {
        self.init(Integer(integerLiteral: value))
    }
}
