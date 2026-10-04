import Foundation

/// 资产生命周期状态：现役在用 → 退役闲置 → 已卖出
enum AssetStatus: String, CaseIterable, Codable, Identifiable, Hashable {
    case active = "现役在用"
    case retired = "退役闲置"
    case sold = "已卖出"

    var id: String { rawValue }
}
