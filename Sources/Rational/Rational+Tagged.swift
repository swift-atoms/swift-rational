public import Addition
public import Property
public import Subtraction
public import Tagged

extension Tagged where Underlying == Rational, Tag: ~Copyable & ~Escapable {
    public static var zero: Self { Self(_unchecked: .zero) }
    public static var one: Self { Self(_unchecked: .one) }

    public var add: Property<Addition, Self> { Property(self) }
    public var subtract: Property<Subtraction, Self> { Property(self) }

    public func adding(_ other: Self) -> Self {
        Self(_unchecked: underlying.add.exact(other.underlying))
    }

    public func subtracting(_ other: Self) -> Self {
        Self(_unchecked: underlying.subtract.exact(other.underlying))
    }

    public static prefix func - (value: Self) -> Self {
        Self(_unchecked: -value.underlying)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(_unchecked: lhs.underlying + rhs.underlying)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(_unchecked: lhs.underlying - rhs.underlying)
    }

    public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
}

extension Property {
    public func exact<T: ~Copyable & ~Escapable>(_ other: Base) -> Base
    where Tag == Addition, Base == Tagged<T, Rational> {
        base.adding(other)
    }

    public func exact<T: ~Copyable & ~Escapable>(_ other: Base) -> Base
    where Tag == Subtraction, Base == Tagged<T, Rational> {
        base.subtracting(other)
    }
}
