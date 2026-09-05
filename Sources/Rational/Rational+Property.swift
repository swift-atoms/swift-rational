public import Addition
public import Property
public import Subtraction

extension Rational {
    public var add: Property<Addition, Self> { Property(self) }
    public var subtract: Property<Subtraction, Self> { Property(self) }
}

extension Property where Tag == Addition, Base == Rational {
    public func exact(_ other: Base) throws(Rational.Error) -> Base {
        try base.adding(other)
    }
}

extension Property where Tag == Subtraction, Base == Rational {
    public func exact(_ other: Base) throws(Rational.Error) -> Base {
        try base.subtracting(other)
    }
}
