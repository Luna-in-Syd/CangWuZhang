import SwiftUI

/// 闲置卖出盈亏复盘：填入卖出价格，实时预览盈亏
struct SellAssetSheet: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss

    @State private var sellPriceText: String = ""
    @State private var sellDate: Date = .now

    private var sellPrice: Decimal? {
        Decimal(string: sellPriceText)
    }

    private var previewProfitLoss: Decimal? {
        guard let sellPrice else { return nil }
        return sellPrice - item.purchasePrice
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("卖出信息") {
                    HStack {
                        Text("卖出价格")
                        Spacer()
                        TextField("0", text: $sellPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    DatePicker("卖出日期", selection: $sellDate, in: item.purchaseDate...Date(), displayedComponents: .date)
                }

                if let previewProfitLoss {
                    Section("预览") {
                        HStack {
                            Text(previewProfitLoss >= 0 ? "预计盈利" : "预计亏损")
                            Spacer()
                            Text(CurrencyFormatter.string(from: abs(previewProfitLoss)))
                                .foregroundStyle(previewProfitLoss >= 0 ? .green : .red)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("卖出复盘")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确认卖出") {
                        guard let sellPrice else { return }
                        item.sellPrice = sellPrice
                        item.soldAt = sellDate
                        item.status = .sold
                        item.updatedAt = .now
                        dismiss()
                    }
                    .disabled(sellPrice == nil)
                }
            }
        }
    }
}
