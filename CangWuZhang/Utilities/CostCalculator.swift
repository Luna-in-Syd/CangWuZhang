import Foundation

/// 日均成本 & 折旧核算逻辑，全部围绕"买入总价 ÷ 使用天数"展开
extension Item {
    /// 结束计费日期：已卖出用卖出日，已退役用退役日，仍在使用中则为今天
    var serviceEndDate: Date {
        soldAt ?? retiredAt ?? Date()
    }

    /// 已使用天数（至少 1 天，避免除零）
    var daysUsed: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: purchaseDate)
        let end = calendar.startOfDay(for: serviceEndDate)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(days, 1)
    }

    /// 日均成本 = 买入总价 / 使用天数
    var dailyCost: Decimal {
        purchasePrice / Decimal(daysUsed)
    }

    /// 次均成本 = 买入总价 / 使用次数（还没记录过使用次数时为 nil）
    var costPerUse: Decimal? {
        guard useCount > 0 else { return nil }
        return purchasePrice / Decimal(useCount)
    }

    /// 平均每隔多少天使用一次（用来看出"是不是天天用"）
    var daysPerUse: Double? {
        guard useCount > 0 else { return nil }
        return Double(daysUsed) / Double(useCount)
    }

    /// 当前生效的"主指标"：按天算或都看时用日均成本，按次算时用次均成本；
    /// 回本进度、目标达成都以这个指标为准
    var primaryUnitCost: Decimal? {
        costBasis == .byUse ? costPerUse : dailyCost
    }

    /// 主指标对应的文案："日均成本" 或 "次均成本"
    var unitCostLabel: String {
        costBasis == .byUse ? "次均成本" : "日均成本"
    }

    /// 距离目标单位成本（日均或次均，取决于计费方式）的回本进度（0...1），未设置目标或还没有主指标时返回 nil
    var payoffProgress: Double? {
        guard let target = targetDailyCost, target > 0 else { return nil }
        guard let current = primaryUnitCost else { return nil }
        guard current > 0 else { return 1 }
        let ratio = target / current
        let value = NSDecimalNumber(decimal: ratio).doubleValue
        return min(max(value, 0), 1)
    }

    /// 是否已达成目标单位成本
    var hasReachedTarget: Bool {
        guard let target = targetDailyCost, let current = primaryUnitCost else { return false }
        return current <= target
    }

    /// 卖出后的净盈亏（正数为盈利，负数为亏损）
    var profitLoss: Decimal? {
        guard let sellPrice else { return nil }
        return sellPrice - purchasePrice
    }

    /// 卖出后的实际日均损耗（按买入价与卖出价的差额平摊到每一天）
    var actualDailyLoss: Decimal? {
        guard let sellPrice else { return nil }
        let loss = purchasePrice - sellPrice
        return loss / Decimal(daysUsed)
    }

    // MARK: - 投资收藏型：现值涨跌

    /// 现值相对买入价的浮动盈亏（未设置现值时为 nil）
    var unrealizedGainLoss: Decimal? {
        guard let currentValue else { return nil }
        return currentValue - purchasePrice
    }

    /// 浮动盈亏涨跌幅（例如 0.12 代表 +12%）
    var unrealizedGainLossPercent: Double? {
        guard let currentValue, purchasePrice > 0 else { return nil }
        let ratio = (currentValue - purchasePrice) / purchasePrice
        return NSDecimalNumber(decimal: ratio).doubleValue
    }

    // MARK: - 展示辅助：不同计价方式下的状态文案与账面价值

    /// 状态文案：一次性消耗型把"现役在用/退役闲置"换成更贴切的"未消耗/已消耗"
    var statusDisplayText: String {
        guard valuationMode == .consumable else { return status.rawValue }
        switch status {
        case .active: return "未消耗"
        case .retired: return "已消耗"
        case .sold: return "已卖出"
        }
    }

    /// 陈列柜贴纸卡片副标题：按计价方式展示日均成本 / 消耗状态 / 涨跌幅
    var showcaseSubtitle: String {
        switch valuationMode {
        case .continuous:
            guard let current = primaryUnitCost else { return "还没记录使用次数" }
            let prefix = costBasis == .byUse ? "次均" : "日均"
            return "\(prefix) \(CurrencyFormatter.string(from: current))"
        case .consumable:
            return statusDisplayText
        case .investment:
            guard let percent = unrealizedGainLossPercent else { return "现值待更新" }
            let sign = percent >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.1f", percent * 100))%"
        }
    }

    /// 列表模式右侧的数值 + 标签：按计价方式展示不同指标
    var trailingMetricValue: String {
        switch valuationMode {
        case .continuous:
            guard let current = primaryUnitCost else { return "—" }
            return CurrencyFormatter.string(from: current)
        case .consumable: return CurrencyFormatter.string(from: purchasePrice)
        case .investment: return CurrencyFormatter.string(from: currentValue ?? purchasePrice)
        }
    }

    var trailingMetricLabel: String {
        switch valuationMode {
        case .continuous: return unitCostLabel
        case .consumable: return "买入价"
        case .investment: return "现值"
        }
    }

    /// 账面价值：持续使用/消耗型按买入价计入净值，投资收藏型按现值（未更新现值时退回买入价）
    var currentBookValue: Decimal {
        valuationMode == .investment ? (currentValue ?? purchasePrice) : purchasePrice
    }
}
