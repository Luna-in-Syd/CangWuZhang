import SwiftUI

struct FilterBarView: View {
    @Binding var statusFilter: AssetStatus?
    @Binding var categoryFilter: AssetCategory?
    @Binding var tagFilter: String?
    var availableTags: [String] = []

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Button("全部状态") { statusFilter = nil }
                    ForEach(AssetStatus.allCases) { status in
                        Button(status.rawValue) { statusFilter = status }
                    }
                } label: {
                    FilterChip(title: statusFilter?.rawValue ?? "状态", isActive: statusFilter != nil)
                }

                Menu {
                    Button("全部分类") { categoryFilter = nil }
                    ForEach(AssetCategory.allCases) { category in
                        Button(category.rawValue) { categoryFilter = category }
                    }
                } label: {
                    FilterChip(title: categoryFilter?.rawValue ?? "分类", isActive: categoryFilter != nil)
                }

                if !availableTags.isEmpty {
                    Menu {
                        Button("全部标签") { tagFilter = nil }
                        ForEach(availableTags, id: \.self) { tag in
                            Button(tag) { tagFilter = tag }
                        }
                    } label: {
                        FilterChip(title: tagFilter ?? "标签", isActive: tagFilter != nil)
                    }
                }

                if statusFilter != nil || categoryFilter != nil || tagFilter != nil {
                    Button("清除") {
                        statusFilter = nil
                        categoryFilter = nil
                        tagFilter = nil
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            Image(systemName: "chevron.down")
                .font(.caption2)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isActive ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
        .foregroundStyle(isActive ? Color.accentColor : .primary)
        .clipShape(Capsule())
    }
}
