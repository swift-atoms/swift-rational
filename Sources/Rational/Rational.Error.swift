import Integer
import Magnitude
import Polarity

extension Rational {
    public enum Error: Swift::Error, Hashable, Sendable {
        case denominator
        case zero

        case overflow
        case inexact
        case unrepresentable
    }
}
