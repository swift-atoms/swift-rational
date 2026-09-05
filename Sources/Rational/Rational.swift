public import Magnitude
public import Polarity

/// An exact, reduced fraction with full-width unsigned numerator and denominator.
///
/// The denominator is positive. Zero has denominator one and no polarity.
public struct Rational: Hashable, Sendable {
    public let numerator: UInt128
    public let denominator: UInt128
    internal let sign: Polarity
}

extension Rational {
    public enum Error: Swift.Error, Hashable, Sendable {
        case denominator
        case zero
        case overflow
        case inexact
        case unrepresentable
    }

    public init(
        numerator: UInt128,
        denominator: UInt128 = 1,
        polarity: Polarity = .positive
    ) throws(Error) {
        guard denominator != 0 else { throw .denominator }
        guard numerator != 0 else { self = .zero; return }
        let common = Self.gcd(numerator, denominator)
        self.init(
            normalized: numerator / common,
            denominator: denominator / common,
            polarity: polarity
        )
    }

    public init(_ value: Int128) {
        self.init(
            normalized: value.magnitude,
            denominator: 1,
            polarity: value < 0 ? .negative : .positive
        )
    }

    internal init(normalized numerator: UInt128, denominator: UInt128, polarity: Polarity) {
        self.numerator = numerator
        self.denominator = numerator == 0 ? 1 : denominator
        self.sign = numerator == 0 ? .positive : polarity
    }

    public static var zero: Self { Self(0) }
    public static var one: Self { Self(1) }

    public var polarity: Polarity? { numerator == 0 ? nil : sign }

    public var absolute: Self {
        Self(normalized: numerator, denominator: denominator, polarity: .positive)
    }

    public static prefix func - (value: Self) -> Self {
        Self(normalized: value.numerator, denominator: value.denominator, polarity: value.sign.opposite)
    }

    internal static func gcd(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
        var left = lhs
        var right = rhs
        while right != 0 {
            (left, right) = (right, left % right)
        }
        return left
    }
}

extension Rational: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.sign != rhs.sign { return lhs.sign == .negative }
        let left = Wide.product(lhs.numerator, rhs.denominator)
        let right = Wide.product(rhs.numerator, lhs.denominator)
        return lhs.sign == .negative ? right < left : left < right
    }
}

extension Rational: Magnitude::Scalar {
    public var isFinite: Bool { true }
}

extension Rational: Magnitude::Representable {
    public typealias Magnitude = Magnitude::Magnitude<Rational>
    public var magnitude: Magnitude { try! Magnitude(validating: absolute) }
}

extension Rational: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int128) { self.init(value) }
}

extension Rational: CustomStringConvertible {
    public var description: String {
        let prefix = sign == .negative ? "-" : ""
        return denominator == 1
            ? "\(prefix)\(numerator)"
            : "\(prefix)\(numerator)/\(denominator)"
    }
}

#if !hasFeature(Embedded)
    extension Rational: Codable {
        private enum CodingKeys: String, CodingKey {
            case numerator
            case denominator
            case polarity
        }

        public init(from decoder: any Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let numerator = try values.decode(UInt128.self, forKey: .numerator)
            let denominator = try values.decode(UInt128.self, forKey: .denominator)
            let polarity = try values.decodeIfPresent(Polarity.self, forKey: .polarity)
            guard (numerator == 0) == (polarity == nil) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .polarity, in: values,
                    debugDescription: "Rational polarity must be absent exactly when numerator is zero"
                )
            }
            do {
                try self.init(numerator: numerator, denominator: denominator, polarity: polarity ?? .positive)
            } catch {
                throw DecodingError.dataCorruptedError(
                    forKey: .denominator, in: values,
                    debugDescription: "Rational denominator must be positive"
                )
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var values = encoder.container(keyedBy: CodingKeys.self)
            try values.encode(numerator, forKey: .numerator)
            try values.encode(denominator, forKey: .denominator)
            try values.encodeIfPresent(polarity, forKey: .polarity)
        }
    }
#endif
