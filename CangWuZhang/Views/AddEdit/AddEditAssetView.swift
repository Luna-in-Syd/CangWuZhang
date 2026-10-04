import SwiftUI
import PhotosUI
import SwiftData
import UIKit

/// 万物资产录入：全品类、买入价格/时间、备注、标签，并触发 AI 抠图生成贴纸卡片
struct AddEditAssetView: View {
    var item: Item?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [Item]

    @State private var name: String = ""
    @State private var category: AssetCategory = .digital
    @State private var priceText: String = ""
    @State private var purchaseDate: Date = .now
    @State private var notes: String = ""
    @State private var tags: [String] = []
    @State private var status: AssetStatus = .active
    @State private var targetDailyCostText: String = ""
    @State private var valuationMode: ValuationMode = .continuous
    @State private var currentValueText: String = ""
    @State private var didManuallySetValuationMode = false
    @State private var costBasis: CostBasis = .byDay
    @State private var useCountText: String = "0"

    @State private var photoItem: PhotosPickerItem?
    @State private var originalImage: UIImage?
    @State private var stickerImage: UIImage?
    @State private var isProcessingImage = false
    @State private var processingError: String?

    private var isEditing: Bool { item != nil }

    private var existingTags: [String] {
        Array(Set(allItems.flatMap(\.tags))).sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("照片（AI 自动抠图生成贴纸）") {
                    PhotosPickerSection(
                        photoItem: $photoItem,
                        stickerImage: stickerImage,
                        isProcessing: isProcessingImage,
                        onPick: handlePhotoPick
                    )
                    if let processingError {
                        Text(processingError).font(.caption).foregroundStyle(.orange)
                    }
                }

                Section("基本信息") {
                    TextField("名称，例如：iPhone 15 Pro", text: $name)
                    Picker("分类", selection: $category) {
                        ForEach(AssetCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .onChange(of: category) { _, newCategory in
                        // 只在新建、且用户还没手动改过计价方式时，跟随分类换默认值
                        if !isEditing && !didManuallySetValuationMode {
                            valuationMode = newCategory.defaultValuationMode
                        }
                    }
                    HStack {
                        Text("买入价格")
                        Spacer()
                        TextField("0", text: $priceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    DatePicker("购买时间", selection: $purchaseDate, in: ...Date(), displayedComponents: .date)
                    Picker("状态", selection: $status) {
                        ForEach(AssetStatus.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                }

                Section {
                    Picker("计价方式", selection: $valuationMode) {
                        ForEach(ValuationMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .onChange(of: valuationMode) { _, _ in
                        didManuallySetValuationMode = true
                    }
                } header: {
                    Text("计价方式")
                } footer: {
                    Text(valuationMode.explanation)
                }

                if valuationMode == .continuous {
                    Section {
                        Picker("计费方式", selection: $costBasis) {
                            ForEach(CostBasis.allCases) { basis in
                                Text(basis.rawValue).tag(basis)
                            }
                        }
                        if costBasis.tracksUsageCount {
                            HStack {
                                Text("使用次数")
                                Spacer()
                                TextField("0", text: $useCountText)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    } header: {
                        Text("计费方式")
                    } footer: {
                        Text(costBasis.explanation + (costBasis.tracksUsageCount ? "。详情页可以随时点「+1 使用」增加次数，这里也能手动改。" : "。相机这类不是天天用的东西，可以改成「按次算」或「两个都看」。"))
                    }

                    Section {
                        HStack {
                            Text(costBasis == .byUse ? "目标次均成本" : "目标日均成本")
                            Spacer()
                            TextField("不设置", text: $targetDailyCostText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    } header: {
                        Text("目标（可选）")
                    } footer: {
                        Text("设置后可在详情页看到\"回本进度\"，判断这件物品什么时候才算用回本。")
                    }
                } else if valuationMode == .investment {
                    Section {
                        HStack {
                            Text("当前现值")
                            Spacer()
                            TextField("不设置", text: $currentValueText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    } header: {
                        Text("现值（可选）")
                    } footer: {
                        Text("填入现在大概值多少钱，详情页会算出浮动盈亏，之后也可以随时更新。")
                    }
                } else {
                    Section {
                        Text("一次性消耗型不计算日均成本，消耗后可以在详情页把状态标记为「已消耗」。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("标签") {
                    TagInputView(tags: $tags, suggestions: existingTags)
                }

                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "编辑藏品" : "录入藏品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: priceText) == nil)
                }
            }
            .onAppear(perform: loadExisting)
        }
    }

    private func loadExisting() {
        guard let item else {
            valuationMode = category.defaultValuationMode
            return
        }
        name = item.name
        category = item.category
        priceText = "\(item.purchasePrice)"
        purchaseDate = item.purchaseDate
        notes = item.notes
        tags = item.tags
        status = item.status
        valuationMode = item.valuationMode
        didManuallySetValuationMode = true
        costBasis = item.costBasis
        useCountText = "\(item.useCount)"
        if let target = item.targetDailyCost {
            targetDailyCostText = "\(target)"
        }
        if let currentValue = item.currentValue {
            currentValueText = "\(currentValue)"
        }
        if let data = item.stickerImageData {
            stickerImage = UIImage(data: data)
        }
    }

    private func handlePhotoPick(_ newItem: PhotosPickerItem?) {
        guard let newItem else { return }
        Task {
            isProcessingImage = true
            processingError = nil
            defer { isProcessingImage = false }
            do {
                guard let data = try await newItem.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                originalImage = uiImage
                do {
                    stickerImage = try await BackgroundRemover.removeBackground(from: uiImage)
                } catch {
                    // 抠图失败（例如没有识别到清晰主体）时退回使用原图，不阻断录入流程
                    stickerImage = uiImage
                    processingError = "未识别到清晰主体，已使用原图"
                }
            } catch {
                processingError = "图片加载失败，请重试"
            }
        }
    }

    private func save() {
        guard let price = Decimal(string: priceText) else { return }
        // 目标日均成本、现值只在各自对应的计价方式下才有意义，切换计价方式后自动清空另一边
        let target = valuationMode == .continuous && !targetDailyCostText.isEmpty
            ? Decimal(string: targetDailyCostText) : nil
        let currentValue = valuationMode == .investment && !currentValueText.isEmpty
            ? Decimal(string: currentValueText) : nil
        let resolvedCostBasis = valuationMode == .continuous ? costBasis : .byDay
        let resolvedUseCount = valuationMode == .continuous ? (Int(useCountText) ?? 0) : 0
        let stickerData = stickerImage?.pngData()
        let originalData = originalImage?.jpegData(compressionQuality: 0.85)

        if let item {
            item.name = name
            item.category = category
            item.purchasePrice = price
            item.purchaseDate = purchaseDate
            item.notes = notes
            item.tags = tags
            item.status = status
            item.valuationMode = valuationMode
            item.currentValue = currentValue
            item.targetDailyCost = target
            item.costBasis = resolvedCostBasis
            item.useCount = resolvedUseCount
            item.updatedAt = .now
            if let stickerData { item.stickerImageData = stickerData }
            if let originalData { item.originalImageData = originalData }
        } else {
            let newItem = Item(
                name: name,
                category: category,
                purchasePrice: price,
                purchaseDate: purchaseDate,
                notes: notes,
                tags: tags,
                status: status,
                valuationMode: valuationMode,
                currentValue: currentValue,
                targetDailyCost: target,
                costBasis: resolvedCostBasis,
                useCount: resolvedUseCount
            )
            newItem.stickerImageData = stickerData
            newItem.originalImageData = originalData
            modelContext.insert(newItem)
        }
        dismiss()
    }
}
