import Foundation

/// 计费方式：持续使用型资产按什么单位衡量成本——按天、按次，还是两个都看
/// 只有相机这类"不是天天用"的东西才需要按次计费，多数东西按天算就够了，
/// 所以这是一个可选功能：默认按天，用户自己选要不要打开"按次"
enum CostBasis: String, CaseIterable, Codable, Identifiable, Hashable {
    case byDay = "按天算"
    case byUse = "按次算"
    case both = "两个都看"

    var id: String { rawValue }

    /// 是否需要记录"使用次数"
    var tracksUsageCount: Bool {
        self != .byDay
    }

    var explanation: String {
        switch self {
        case .byDay: return "日均成本 = 买入价 ÷ 已用天数，适合天天用的东西"
        case .byUse: return "次均成本 = 买入价 ÷ 使用次数，适合不是天天用的东西（比如相机）"
        case .both: return "日均成本和次均成本都算出来，一起参考"
        }
    }
}
