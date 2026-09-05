# Rational

`Rational` is an exact signed fraction with a UInt128 numerator and positive
UInt128 denominator. Values are reduced at construction. Zero has denominator
one and no polarity. Codable decoding enforces the same invariants.

```swift
let half = try Rational(numerator: 1, denominator: 2)
let third = try Rational(numerator: 1, denominator: 3)
let sum = try half.add.exact(third) // 5/6
let difference = try half.subtract.exact(third) // 1/6
let product = try half.multiplied(by: third) // 1/6
let inverse = try half.inverted() // 2
```

Named operations and `add.exact` / `subtract.exact` expose typed errors for
unrepresentable results. Ordinary `+`, `-`, and `*` require representable results.
Multiplication cancels cross factors first. Addition and subtraction use temporary
double-width products and reduce the result before checking stored bounds.
Comparison also uses full-width products.

`applying(to: Int128)` and `applying(to: UInt128)` require exact integral results.
`quotient(dividing: Int128)` divides by a positive integral value with a
nonnegative Euclidean remainder. Zero divisors, inexact integer results, and
bounds failures are explicit.

`Magnitude<Rational>` validates the absolute-size role. `Tagged<Domain, Rational>`
supports checked and ordinary same-domain addition/subtraction and negation,
preserving the domain in the result. Unit conversion is owned by Ratio.

Build and test through `arithmetic.xcworkspace`, whose local package references
override the URL dependencies in this package manifest.
