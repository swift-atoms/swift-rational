public import Integer
public import Magnitude
public import Polarity


extension Rational {
    public enum Error: Swift::Error, Hashable, Sendable {
        case denominator
        case zero

        case overflow
        case inexact
        case unrepresentable
    }
}
