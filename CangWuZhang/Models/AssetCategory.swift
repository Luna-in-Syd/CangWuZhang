import Foundation

/// 资产分类：覆盖数码、球鞋手办、黄金茅台、奢品、游戏账号、会员权益等全品类
enum AssetCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case digital = "数码"
    case sneakers = "球鞋"
    case figures = "手办"
    case luxury = "奢品"
    case gold = "黄金"
    case liquor = "茅台/酒类"
    case gameAccount = "游戏账号"
    case membership = "会员权益"
    case other = "其他"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .digital: return "iphone"
        case .sneakers: return "figure.walk"
        case .figures: return "cube.box.fill"
        case .luxury: return "bag.fill"
        case .gold: return "medal.fill"
        case .liquor: return "wineglass"
        case .gameAccount: return "gamecontroller.fill"
        case .membership: return "crown.fill"
        case .other: return "shippingbox.fill"
        }
    }

    /// 每个分类默认适用的计价方式，录入时用户仍可手动改
    /// 黄金默认按投资收藏算，茅台/酒类默认按一次性消耗算（喝掉即结束，不摊天数）
    var defaultValuationMode: ValuationMode {
        switch self {
        case .gold:
            return .investment
        case .liquor:
            return .consumable
        case .digital, .sneakers, .figures, .luxury, .gameAccount, .membership, .other:
            return .continuous
        }
    }
}
