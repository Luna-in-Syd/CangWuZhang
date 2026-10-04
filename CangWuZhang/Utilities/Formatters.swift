import Foundation

enum CurrencyFormatter {
    static func string(from value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        let str = formatter.string(from: number) ?? "\(value)"
        return "¥\(str)"
    }
}

enum DateFormatting {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
