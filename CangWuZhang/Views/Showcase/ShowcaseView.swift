import SwiftUI
import SwiftData

struct ShowcaseView: View {
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @Environment(\.modelContext) private var modelContext

    @State private var displayMode: DisplayMode = .sticker
    @State private var statusFilter: AssetStatus?
    @State private var categoryFilter: AssetCategory?
    @State private var tagFilter: String?
    @State private var searchText = ""
    @State private var showingAdd = false

    enum DisplayMode: String, CaseIterable {
        case sticker = "贴纸"
        case list = "列表"
    }

    private var allTags: [String] {
        Array(Set(items.flatMap(\.tags))).sorted()
    }

    private var filteredItems: [Item] {
        items.filter { item in
            (statusFilter == nil || item.status == statusFilter) &&
            (categoryFilter == nil || item.category == categoryFilter) &&
            (tagFilter == nil || item.tags.contains(tagFilter!)) &&
            (searchText.isEmpty
                || item.name.localizedCaseInsensitiveContains(searchText)
                || item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FilterBarView(statusFilter: $statusFilter, categoryFilter: $categoryFilter, tagFilter: $tagFilter, availableTags: allTags)

                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        items.isEmpty ? "还没有藏品" : "没有符合条件的藏品",
                        systemImage: "shippingbox",
                        description: Text(items.isEmpty ? "点击右上角 + 录入你的第一件资产" : "试试调整筛选条件")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        switch displayMode {
                        case .sticker:
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                                ForEach(filteredItems) { item in
                                    NavigationLink {
                                        AssetDetailView(item: item)
                                    } label: {
                                        StickerCardView(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(14)
                        case .list:
                            LazyVStack(spacing: 10) {
                                ForEach(filteredItems) { item in
                                    NavigationLink {
                                        AssetDetailView(item: item)
                                    } label: {
                                        AssetListRowView(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(14)
                        }
                    }
                }
            }
            .navigationTitle("陈列柜")
            .searchable(text: $searchText, prompt: "搜索名称或标签")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("展示模式", selection: $displayMode) {
                        ForEach(DisplayMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditAssetView(item: nil)
            }
        }
    }
}

#Preview {
    ShowcaseView()
        .modelContainer(for: Item.self, inMemory: true)
}
