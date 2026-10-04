import Foundation
import SwiftData

/// 万物资产模型：数码、球鞋手办、黄金茅台、奢品、游戏账号、会员权益都用同一个模型录入
@Model
final class Item {
    var id: UUID
    var name: String
    var categoryRaw: String
    var purchasePrice: Decimal
    var purchaseDate: Date
    var notes: String
    var tags: [String]
    var statusRaw: String

    /// 计价方式：持续使用 / 一次性消耗 / 投资收藏，决定详情页展示哪些指标
    /// 旧数据没有这个字段时留空，读取时会按分类自动推断默认值
    var valuationModeRaw: String = ""

    /// 投资收藏型资产的当前估值（现值），用于计算浮动盈亏
    var currentValue: Decimal?

    /// 计费方式：按天 / 按次 / 都看，仅持续使用型资产适用，旧数据留空按"按天"处理
    var costBasisRaw: String = ""
    /// 使用次数（计费方式为"按次"或"都看"时才会用到）
    var useCount: Int = 0
    /// 最近一次使用的时间
    var lastUsedAt: Date?

    /// 退役（转为闲置，或一次性消耗型的"已消耗"）日期
    var retiredAt: Date?
    /// 卖出日期
    var soldAt: Date?
    /// 卖出价格
    var sellPrice: Decimal?
    /// 目标日均成本，用于计算"回本进度"（仅持续使用型适用）
    var targetDailyCost: Decimal?

    /// 抠图后的贴纸图（透明背景），用于陈列柜贴纸模式
    @Attribute(.externalStorage) var stickerImageData: Data?
    /// 原始照片，作为备份保留
    @Attribute(.externalStorage) var originalImageData: Data?

    var createdAt: Date
    var updatedAt: Date

    init(
        name: String,
        category: AssetCategory,
        purchasePrice: Decimal,
        purchaseDate: Date,
        notes: String = "",
        tags: [String] = [],
        status: AssetStatus = .active,
        valuationMode: ValuationMode? = nil,
        currentValue: Decimal? = nil,
        targetDailyCost: Decimal? = nil,
        costBasis: CostBasis = .byDay,
        useCount: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.notes = notes
        self.tags = tags
        self.statusRaw = status.rawValue
        self.valuationModeRaw = (valuationMode ?? category.defaultValuationMode).rawValue
        self.currentValue = currentValue
        self.targetDailyCost = targetDailyCost
        self.costBasisRaw = costBasis.rawValue
        self.useCount = useCount
        self.createdAt = .now
        self.updatedAt = .now
    }

    var category: AssetCategory {
        get { AssetCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var status: AssetStatus {
        get { AssetStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    /// 计价方式：旧数据没有存过就按分类推断默认值，不需要迁移脚本
    var valuationMode: ValuationMode {
        get { ValuationMode(rawValue: valuationModeRaw) ?? category.defaultValuationMode }
        set { valuationModeRaw = newValue.rawValue }
    }

    /// 计费方式：旧数据没有存过就按"按天"处理
    var costBasis: CostBasis {
        get { CostBasis(rawValue: costBasisRaw) ?? .byDay }
        set { costBasisRaw = newValue.rawValue }
    }
}
