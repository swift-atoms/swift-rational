# Rational

One exact rational type, backed by the arbitrary-precision Integer atom. The signed numerator and positive denominator are coprime; zero is always 0/1. There is no separate bounded or Unbounded rational type.

```swift
let half = try Rational(numerator: 1, denominator: 2)
let third = try Rational(numerator: 1, denominator: 3)
let sum = half + third // 5/6
let huge = try Rational(10).raised(to: 200)
let recovered = huge + 1 - huge // exactly 1
let machineValue = try recovered.integer(as: Int8.self)
```

Addition, subtraction and multiplication are exact, nonthrowing operations. Division and negative powers reject zero divisors. Integer exponents have arbitrary precision. `root(_:)` returns a value only for exact rational roots; symbolic irrational roots belong to the separate Radical atom.

`integer(as:)` and `applying(to:)` require an integral result within the explicitly chosen Swift integer type. Range and precision failures belong to these conversions, never to the rational arithmetic itself.

Integer literals use StaticBigInt. String parsing accepts signed integers and fractions. Codable now encodes the signed numerator and positive denominator as decimal strings, for example `{"numerator":"-1","denominator":"3"}`. This intentionally replaces the old bounded numeric components and separate polarity field; persisted old payloads require migration. Decoding normalizes fractions and rejects nonpositive denominators.

Magnitude and Tagged integrations preserve exact arithmetic. Foundation remains outside the core target. All manifest dependencies use full GitHub URLs; build and test through atoms.xcworkspace for local resolution.
