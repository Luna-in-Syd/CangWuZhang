import Foundation

/// 计价方式：决定一件资产该用哪种逻辑衡量"值不值"，而不是只看分类
enum ValuationMode: String, CaseIterable, Codable, Identifiable, Hashable {
    /// 持续使用型：买来会陪伴一段时间，每天都在产生价值，适合按天摊销日均成本
    case continuous = "持续使用"
    /// 一次性消耗型：一次用掉/吃喝掉，不存在"用了多少天"，不计算日均成本
    case consumable = "一次性消耗"
    /// 投资收藏型：买来为了保值增值，跟踪现值涨跌，而不是日均成本
    case investment = "投资收藏"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .continuous: return "clock.arrow.circlepath"
        case .consumable: return "flame"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
    }

    /// 选择计价方式时给用户看的说明
    var explanation: String {
        switch self {
        case .continuous: return "会持续使用一段时间，按天摊销日均成本"
        case .consumable: return "一次性用掉 / 吃喝掉，不计算日均成本"
        case .investment: return "买来保值增值，跟踪现值涨跌，不算日均成本"
        }
    }
}
