internal import Addition
internal import Subtraction

extension Rational {
    /// A temporary double-width unsigned value for exact products and cancellation.
    internal struct Wide: Equatable, Comparable {
        internal let high: UInt128
        internal let low: UInt128
    }
}

extension Rational.Wide {
    internal static func product(_ lhs: UInt128, _ rhs: UInt128) -> Self {
        let result = lhs.multipliedFullWidth(by: rhs)
        return Self(high: result.high, low: result.low)
    }

    internal static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.high == rhs.high ? lhs.low < rhs.low : lhs.high < rhs.high
    }

    internal func adding(_ rhs: Self) throws(Rational.Error) -> Self {
        let low = Addition.reporting(low, rhs.low)
        do {
            let high = try Addition.exact(high, rhs.high)
            return Self(high: try Addition.exact(high, low.overflow ? 1 : 0), low: low.value)
        } catch { throw .overflow }
    }

    /// Subtracts a value known not to exceed this one.
    internal func subtracting(_ rhs: Self) -> Self {
        let low = Subtraction.reporting(low, rhs.low)
        let high = Subtraction.reporting(high, rhs.high).value
        return Self(high: Subtraction.reporting(high, low.overflow ? 1 : 0).value, low: low.value)
    }

    internal func remainder(dividingBy divisor: UInt128) -> UInt128 {
        divisor.dividingFullWidth((high: high % divisor, low: low)).remainder
    }

    internal func divided(by divisor: UInt128) throws(Rational.Error) -> UInt128 {
        guard high < divisor else { throw .overflow }
        return divisor.dividingFullWidth((high: high, low: low)).quotient
    }
}
