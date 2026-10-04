import SwiftUI
import SwiftData
import Charts

/// 资产总览数据看板：净值、分类占比、持有时长分布、消费趋势、保值率
struct DashboardView: View {
    @Query private var items: [Item]

    private var heldItems: [Item] { items.filter { $0.status != .sold } }
    private var soldItems: [Item] { items.filter { $0.status == .sold } }

    /// 持续使用/消耗型按买入价计入净值，投资收藏型按现值计入，更贴近真实资产状况
    private var totalNetWorth: Decimal {
        heldItems.reduce(Decimal(0)) { $0 + $1.currentBookValue }
    }

    private var categoryDistribution: [(category: AssetCategory, total: Decimal)] {
        let grouped = Dictionary(grouping: heldItems, by: \.category)
        return grouped
            .map { (key, value) in (category: key, total: value.reduce(Decimal(0)) { $0 + $1.currentBookValue }) }
            .sorted { $0.total > $1.total }
    }

    private var investmentItemsWithValue: [Item] {
        heldItems.filter { $0.valuationMode == .investment && $0.currentValue != nil }
    }

    private var totalUnrealizedGainLoss: Decimal? {
        guard !investmentItemsWithValue.isEmpty else { return nil }
        return investmentItemsWithValue.reduce(Decimal(0)) { $0 + ($1.unrealizedGainLoss ?? 0) }
    }

    private var preservationRate: Double? {
        guard !soldItems.isEmpty else { return nil }
        let totalCost = soldItems.reduce(Decimal(0)) { $0 + $1.purchasePrice }
        let totalSell = soldItems.reduce(Decimal(0)) { $0 + ($1.sellPrice ?? 0) }
        guard totalCost > 0 else { return nil }
        return NSDecimalNumber(decimal: totalSell / totalCost).doubleValue
    }

    private var holdingBuckets: [(label: String, count: Int)] {
        let labels = ["<30天", "30-90天", "90-365天", ">365天"]
        var counts = [0, 0, 0, 0]
        for item in items {
            switch item.daysUsed {
            case ..<30: counts[0] += 1
            case 30..<90: counts[1] += 1
            case 90..<365: counts[2] += 1
            default: counts[3] += 1
            }
        }
        return zip(labels, counts).map { (label: $0, count: $1) }
    }

    private var monthlySpend: [(month: String, total: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var months: [(String, Double)] = []
        for offset in stride(from: 11, through: 0, by: -1) {
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: now) else { continue }
            let comps = calendar.dateComponents([.month], from: monthDate)
            let label = "\(comps.month ?? 0)月"
            let total = items
                .filter { calendar.isDate($0.purchaseDate, equalTo: monthDate, toGranularity: .month) }
                .reduce(Decimal(0)) { $0 + $1.purchasePrice }
            months.append((label, NSDecimalNumber(decimal: total).doubleValue))
        }
        return months
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    netWorthCard
                    if let totalUnrealizedGainLoss {
                        unrealizedGainLossCard(amount: totalUnrealizedGainLoss)
                    }
                    statusCountsRow
                    categoryPieCard
                    holdingDistributionCard
                    monthlyTrendCard
                    if let preservationRate {
                        preservationCard(rate: preservationRate)
                    }
                }
                .padding(16)
            }
            .navigationTitle("数据看板")
        }
    }

    private var netWorthCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("持有资产总值").font(.caption).foregroundStyle(.secondary)
            Text(CurrencyFormatter.string(from: totalNetWorth))
                .font(.system(size: 32, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statusCountsRow: some View {
        HStack(spacing: 12) {
            ForEach(AssetStatus.allCases) { status in
                let count = items.filter { $0.status == status }.count
                VStack(spacing: 4) {
                    Text("\(count)").font(.title2.weight(.bold))
                    Text(status.rawValue).font(.caption2).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var categoryPieCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("持有资产分类占比").font(.subheadline.weight(.semibold))
            if categoryDistribution.isEmpty {
                Text("暂无数据").font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(categoryDistribution, id: \.category) { entry in
                    SectorMark(
                        angle: .value("金额", NSDecimalNumber(decimal: entry.total).doubleValue),
                        innerRadius: .ratio(0.55)
                    )
                    .foregroundStyle(by: .value("分类", entry.category.rawValue))
                }
                .frame(height: 200)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var holdingDistributionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("持有时长分布").font(.subheadline.weight(.semibold))
            Chart(holdingBuckets, id: \.label) { bucket in
                BarMark(x: .value("区间", bucket.label), y: .value("数量", bucket.count))
                    .foregroundStyle(Color.accentColor.gradient)
            }
            .frame(height: 160)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var monthlyTrendCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("近 12 个月消费趋势").font(.subheadline.weight(.semibold))
            Chart(monthlySpend, id: \.month) { point in
                LineMark(x: .value("月份", point.month), y: .value("支出", point.total))
                    .interpolationMethod(.catmullRom)
                PointMark(x: .value("月份", point.month), y: .value("支出", point.total))
            }
            .frame(height: 160)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func unrealizedGainLossCard(amount: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("投资收藏型浮动盈亏").font(.caption).foregroundStyle(.secondary)
            Text("\(amount >= 0 ? "+" : "")\(CurrencyFormatter.string(from: amount))")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(amount >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func preservationCard(rate: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("已卖出藏品保值率").font(.subheadline.weight(.semibold))
            Text("\(Int(rate * 100))%")
                .font(.title.weight(.bold))
                .foregroundStyle(rate >= 0.7 ? .green : (rate >= 0.4 ? .orange : .red))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Item.self, inMemory: true)
}
