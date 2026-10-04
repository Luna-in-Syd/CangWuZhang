import SwiftUI
import SwiftData

/// 标签管理：查看全部标签的使用情况，支持重命名（重命名成已有标签即合并）与删除
struct TagManagementView: View {
    @Query private var items: [Item]

    @State private var renamingTag: String?
    @State private var renameText: String = ""
    @State private var deletingTag: String?

    private var tagCounts: [(tag: String, count: Int)] {
        var counts: [String: Int] = [:]
        for item in items {
            for tag in item.tags {
                counts[tag, default: 0] += 1
            }
        }
        return counts
            .map { (tag: $0.key, count: $0.value) }
            .sorted { $0.count == $1.count ? $0.tag < $1.tag : $0.count > $1.count }
    }

    var body: some View {
        List {
            if tagCounts.isEmpty {
                ContentUnavailableView(
                    "还没有标签",
                    systemImage: "tag",
                    description: Text("在录入或编辑藏品时添加标签，会显示在这里")
                )
            } else {
                Section {
                    ForEach(tagCounts, id: \.tag) { entry in
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundStyle(Color.accentColor)
                            Text(entry.tag)
                            Spacer()
                            Text("\(entry.count) 件")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deletingTag = entry.tag
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            Button {
                                renameText = entry.tag
                                renamingTag = entry.tag
                            } label: {
                                Label("重命名", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                } footer: {
                    Text("左滑标签可以重命名或删除。重命名成一个已经存在的标签名，会自动合并成一个标签；删除标签只会从藏品上移除，不会删除藏品本身。")
                }
            }
        }
        .navigationTitle("标签管理")
        .alert("重命名标签", isPresented: Binding(
            get: { renamingTag != nil },
            set: { if !$0 { renamingTag = nil } }
        )) {
            TextField("标签名称", text: $renameText)
            Button("取消", role: .cancel) { renamingTag = nil }
            Button("确定") {
                if let oldTag = renamingTag {
                    rename(oldTag, to: renameText)
                }
                renamingTag = nil
            }
        } message: {
            Text("重命名为已存在的标签会自动合并")
        }
        .confirmationDialog(
            "确定删除标签「\(deletingTag ?? "")」吗？",
            isPresented: Binding(
                get: { deletingTag != nil },
                set: { if !$0 { deletingTag = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                if let tag = deletingTag {
                    delete(tag)
                }
                deletingTag = nil
            }
            Button("取消", role: .cancel) { deletingTag = nil }
        } message: {
            Text("只会从藏品上移除这个标签，不会删除藏品本身")
        }
    }

    private func rename(_ oldTag: String, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != oldTag else { return }
        for item in items where item.tags.contains(oldTag) {
            item.tags.removeAll { $0 == oldTag }
            if !item.tags.contains(trimmed) {
                item.tags.append(trimmed)
            }
            item.updatedAt = .now
        }
    }

    private func delete(_ tag: String) {
        for item in items where item.tags.contains(tag) {
            item.tags.removeAll { $0 == tag }
            item.updatedAt = .now
        }
    }
}

#Preview {
    NavigationStack {
        TagManagementView()
    }
    .modelContainer(for: Item.self, inMemory: true)
}
