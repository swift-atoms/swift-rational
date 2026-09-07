public import Integer
extension Rational: Swift.LosslessStringConvertible {
    /// Parses a signed integer or a pair of signed integers separated by /.
    public init?(_ description: String) {
        let parts = description.split(separator: "/", omittingEmptySubsequences: false)
        guard (1...2).contains(parts.count), let n = Integer(String(parts[0])) else { return nil }
        let d = parts.count == 2 ? Integer(String(parts[1])) : .one
        guard let d, !d.isZero else { return nil }
        self.init(reducing: n, denominator: d)
    }
}
