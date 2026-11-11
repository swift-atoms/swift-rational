# swift-rational

Use this package when you need an exact fraction: a factor, a quantity or an intermediate result that must never round or overflow, such as a unit conversion factor or a sum of many small parts. Start from `Rational`; wrap it in `Tagged<Tag, Rational>` when the quantity belongs to a domain that must not mix with others. When the fraction converts between two typed domains, use the sibling swift-ratio. When values must round in base ten, use swift-decimal. When an approximate floating-point factor is good enough, use swift-scale.

## Laws

- Every `Rational` is stored in one canonical form: the sign is on `numerator`, `denominator` is positive, the two share no common factor, and zero is 0/1. So equal fractions are `==` and hash alike however they were built (60/120 equals 1/2), and `Rational.zero.polarity` is `nil`.
- On construction, `polarity: .negative` negates the given numerator, and a negative denominator moves its sign onto the numerator (-6/-8 is 3/4). A zero denominator fails.
- Both components are arbitrary-precision `Integer`s, so `+`, `-`, `*`, `divided(by:)`, `raised(to:)` and `<` are exact and never overflow, however large the components grow. Range is checked only when converting to a fixed-width integer.
- Inverting zero, dividing by zero and raising zero to a negative power fail. A negative exponent inverts first. Anything raised to zero is one, including zero.
- `root(_:)` returns `nil` unless both the reduced numerator and denominator are exact roots of that degree.
- `integer(as:)` checks, in this order: a fraction that is not a whole number is inexact, a negative value into an unsigned type is unrepresentable, and a whole number outside the type's range overflows. `applying(to:)` multiplies exactly first and then converts by the same rules.
- `quotient(dividing:)` divides by the rational as a whole positive divisor and floors: the remainder is never negative and always below the divisor, also for negative dividends (-1 divided by 60 is quotient -1, remainder 59).
- `floor` is the greatest whole number not above the value and `ceiling` the least not below it, for negative values too (-7/2 floors to -4 and its ceiling is -3). Both are exact `Integer`s and are equal exactly when the value is whole.
- `description` prints the numerator alone when the denominator is one and numerator/denominator otherwise. The string initializer accepts exactly that shape, with an optional sign on either component and a non-zero denominator, and reduces the result. It rejects anything else, including empty components, more than one `/`, `NaN` and `Infinity`.
- `Codable` uses the keys `numerator` and `denominator`. Decoding rejects a denominator that is not positive and reduces the result.
- `approximation(as:)` scales numerator and denominator before converting, so components far beyond the destination's range still give a finite result when their ratio is in range. A result below the destination's normal range comes out as a subnormal rather than as zero.
- `magnitude` is the absolute value. `isFinite` is always `true`.
