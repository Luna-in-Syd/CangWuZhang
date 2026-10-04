import SwiftUI
import SwiftData
import UIKit

struct AssetDetailView: View {
    @Bindable var item: Item
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingSell = false
    @State private var showingDeleteConfirm = false
    @State private var showingUpdateValue = false
    @State private var currentValueText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                imageHeader
                statCards

                if item.valuationMode == .continuous, item.status != .sold, let progress = item.payoffProgress {
                    payoffProgressSection(progress: progress)
                }

                if item.valuationMode == .investment {
                    investmentSection
                }

                if item.valuationMode == .continuous, item.costBasis.tracksUsageCount {
                    usageSection
                }

                serviceProgressSection

                if item.status == .sold {
                    sellSummarySection
                }

                if !item.notes.isEmpty {
                    notesSection
                }

                actionButtons
            }
            .padding(16)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("编辑信息", systemImage: "pencil") { showingEdit = true }
                    if item.valuationMode == .investment {
                        Button("更新现值", systemImage: "arrow.triangle.2.circlepath") {
                            currentValueText = item.currentValue.map { "\($0)" } ?? ""
                            showingUpdateValue = true
                        }
                    }
                    if item.status == .active {
                        Button(
                            item.valuationMode == .consumable ? "标记为已消耗" : "标记为退役闲置",
                            systemImage: item.valuationMode == .consumable ? "flame" : "pause.circle"
                        ) {
                            item.status = .retired
                            item.retiredAt = .now
                            item.updatedAt = .now
                        }
                    }
                    if item.status != .sold {
                        Button("标记为已卖出", systemImage: "yensign.circle") { showingSell = true }
                    }
                    Button("删除", systemImage: "trash", role: .destructive) { showingDeleteConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditAssetView(item: item)
        }
        .sheet(isPresented: $showingSell) {
            SellAssetSheet(item: item)
        }
        .alert("更新现值", isPresented: $showingUpdateValue) {
            TextField("现在大概值多少钱", text: $currentValueText)
                .keyboardType(.decimalPad)
            Button("取消", role: .cancel) {}
            Button("保存") {
                if let value = Decimal(string: currentValueText) {
                    item.currentValue = value
                    item.updatedAt = .now
                }
            }
        } message: {
            Text("用于计算浮动盈亏，可以随时来更新")
        }
        .confirmationDialog("确定删除这件藏品吗？", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                modelContext.delete(item)
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
    }

    private var imageHeader: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 220)
            .overlay {
                if let data = item.stickerImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFit().padding(24)
                } else {
                    Image(systemName: item.category.systemImage)
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                }
            }
    }

    private var statCards: some View {
        HStack(spacing: 12) {
            switch item.valuationMode {
            case .continuous:
                StatCard(title: "买入价格", value: CurrencyFormatter.string(from: item.purchasePrice))
                switch item.costBasis {
                case .byDay:
                    StatCard(title: "日均成本", value: CurrencyFormatter.string(from: item.dailyCost), highlight: true)
                    StatCard(title: "已使用", value: "\(item.daysUsed) 天")
                case .byUse:
                    StatCard(title: "次均成本", value: item.costPerUse.map { CurrencyFormatter.string(from: $0) } ?? "待记录", highlight: true)
                    StatCard(title: "使用次数", value: "\(item.useCount) 次")
                case .both:
                    StatCard(title: "日均成本", value: CurrencyFormatter.string(from: item.dailyCost), highlight: true)
                    StatCard(title: "次均成本", value: item.costPerUse.map { CurrencyFormatter.string(from: $0) } ?? "待记录")
                }
            case .consumable:
                StatCard(title: "买入价格", value: CurrencyFormatter.string(from: item.purchasePrice))
                StatCard(title: "状态", value: item.statusDisplayText, highlight: true)
            case .investment:
                StatCard(title: "买入价格", value: CurrencyFormatter.string(from: item.purchasePrice))
                StatCard(title: "现值", value: item.currentValue.map { CurrencyFormatter.string(from: $0) } ?? "待更新", highlight: true)
                if let gainLoss = item.unrealizedGainLoss {
                    StatCard(
                        title: gainLoss >= 0 ? "浮动盈利" : "浮动亏损",
                        value: CurrencyFormatter.string(from: abs(gainLoss))
                    )
                }
            }
        }
    }

    private var investmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("浮动盈亏").font(.subheadline.weight(.semibold))
                Spacer()
                if let percent = item.unrealizedGainLossPercent {
                    let sign = percent >= 0 ? "+" : ""
                    Text("\(sign)\(String(format: "%.1f", percent * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(percent >= 0 ? .green : .red)
                }
            }
            if let gainLoss = item.unrealizedGainLoss {
                Text("\(gainLoss >= 0 ? "盈利" : "亏损") \(CurrencyFormatter.string(from: abs(gainLoss)))")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(gainLoss >= 0 ? .green : .red)
            } else {
                Text("还没填写现值，点右上角「更新现值」来计算浮动盈亏")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func payoffProgressSection(progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("回本进度").font(.subheadline.weight(.semibold))
                Spacer()
                Text(item.hasReachedTarget ? "已达成目标" : "\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(item.hasReachedTarget ? .green : .secondary)
            }
            ProgressView(value: progress)
                .tint(item.hasReachedTarget ? .green : .accentColor)
            if let target = item.targetDailyCost {
                Text("目标\(item.unitCostLabel) \(CurrencyFormatter.string(from: target))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("使用记录").font(.subheadline.weight(.semibold))
                Spacer()
                if let daysPerUse = item.daysPerUse {
                    Text("平均每 \(String(format: "%.0f", daysPerUse)) 天用一次")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(item.useCount)")
                    .font(.title.weight(.bold))
                Text("次")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let lastUsedAt = item.lastUsedAt {
                    Text("· 上次 \(DateFormatting.short.string(from: lastUsedAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 10) {
                Button {
                    item.useCount += 1
                    item.lastUsedAt = .now
                    item.updatedAt = .now
                } label: {
                    Label("记一次使用", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    guard item.useCount > 0 else { return }
                    item.useCount -= 1
                    item.updatedAt = .now
                } label: {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.bordered)
                .disabled(item.useCount == 0)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var serviceProgressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.valuationMode == .consumable ? "消耗状态" : "服役状态").font(.subheadline.weight(.semibold))
                Spacer()
                Text(item.statusDisplayText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Label("买入 \(DateFormatting.short.string(from: item.purchaseDate))", systemImage: "calendar")
                if let retiredAt = item.retiredAt {
                    let label = item.valuationMode == .consumable ? "消耗" : "退役"
                    Label("\(label) \(DateFormatting.short.string(from: retiredAt))", systemImage: item.valuationMode == .consumable ? "flame" : "pause.circle")
                }
                if let soldAt = item.soldAt {
                    Label("卖出 \(DateFormatting.short.string(from: soldAt))", systemImage: "yensign.circle")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var sellSummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("卖出复盘").font(.subheadline.weight(.semibold))
            if let profitLoss = item.profitLoss {
                HStack {
                    Text(profitLoss >= 0 ? "盈利" : "亏损")
                    Spacer()
                    Text(CurrencyFormatter.string(from: abs(profitLoss)))
                        .foregroundStyle(profitLoss >= 0 ? .green : .red)
                        .font(.headline)
                }
            }
            if let actualDailyLoss = item.actualDailyLoss {
                HStack {
                    Text("实际日均损耗")
                    Spacer()
                    Text(CurrencyFormatter.string(from: actualDailyLoss))
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("备注").font(.subheadline.weight(.semibold))
            Text(item.notes).font(.body).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            if item.status != .sold {
                Button {
                    showingSell = true
                } label: {
                    Text("卖出复盘")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    var highlight: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(highlight ? .title3.weight(.bold) : .subheadline.weight(.semibold))
                .foregroundStyle(highlight ? Color.accentColor : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
