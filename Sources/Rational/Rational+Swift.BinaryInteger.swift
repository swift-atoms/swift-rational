public import Integer
public import Polarity
extension Rational {
    public init<T: Swift.BinaryInteger>(_ value: T) { self.init(Integer(value)) }

    @_disfavoredOverload
    public init<N: Swift.BinaryInteger, D: Swift.BinaryInteger>(
        numerator: N, denominator: D, polarity: Polarity = .positive
    ) throws(Error) {
        try self.init(numerator: Integer(numerator), denominator: Integer(denominator), polarity: polarity)
    }

    @_disfavoredOverload
    public init<N: Swift.BinaryInteger>(numerator: N, polarity: Polarity = .positive) throws(Error) {
        try self.init(numerator: Integer(numerator), polarity: polarity)
    }

    @_disfavoredOverload
    public func raised<T: Swift.BinaryInteger>(to exponent: T) throws(Error) -> Self {
        try raised(to: Integer(exponent))
    }

    public func integer<T: Swift.FixedWidthInteger>(as type: T.Type) throws(Error) -> T {
        guard denominator == .one else { throw .inexact }
        guard !numerator.isNegative || T.isSigned else { throw .unrepresentable }
        guard let result = numerator.exactly(type) else { throw .overflow }
        return result
    }

    public func applying<T: Swift.FixedWidthInteger>(to value: T) throws(Error) -> T {
        try (self * Self(value)).integer(as: T.self)
    }


    public func quotient<T: Swift.FixedWidthInteger>(dividing value: T) throws(Error) -> (quotient: T, remainder: T) {
        guard !numerator.isZero else { throw .zero }
        guard !numerator.isNegative else { throw .unrepresentable }
        guard denominator == .one else { throw .inexact }
        var result = try! Integer(value).quotientAndRemainder(dividingBy: numerator)
        if result.remainder.isNegative {
            result.quotient -= .one
            result.remainder += numerator
        }
        guard let q = result.quotient.exactly(T.self), let r = result.remainder.exactly(T.self) else { throw .overflow }
        return (q, r)
    }
}
