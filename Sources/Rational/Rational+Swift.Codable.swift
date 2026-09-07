public import Integer
#if !hasFeature(Embedded)
extension Rational: Swift.Codable {
    private enum CodingKeys: String, CodingKey { case numerator, denominator }
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let n = try values.decode(Integer.self, forKey: .numerator)
        let d = try values.decode(Integer.self, forKey: .denominator)
        guard d > .zero else {
            throw DecodingError.dataCorruptedError(forKey: .denominator, in: values,
                debugDescription: "Rational denominator must be positive")
        }
        self.init(reducing: n, denominator: d)
    }
    public func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(numerator, forKey: .numerator)
        try values.encode(denominator, forKey: .denominator)
    }
}
#endif
