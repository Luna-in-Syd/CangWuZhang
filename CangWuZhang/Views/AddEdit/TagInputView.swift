import SwiftUI

struct TagInputView: View {
    @Binding var tags: [String]
    /// 已有的标签，用于快速点选（不会重复展示已经加上的标签）
    var suggestions: [String] = []
    @State private var newTag: String = ""

    private var visibleSuggestions: [String] {
        suggestions.filter { !tags.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text(tag).font(.caption)
                                Button {
                                    remove(tag)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption2)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.accentColor.opacity(0.12))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            HStack {
                TextField("添加标签后回车，例如：数码 / 常用", text: $newTag)
                    .onSubmit(addTag)
                Button("添加", action: addTag)
                    .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            if !visibleSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("常用标签").font(.caption2).foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(visibleSuggestions, id: \.self) { tag in
                                Button {
                                    tags.append(tag)
                                } label: {
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color(.secondarySystemBackground))
                                        .foregroundStyle(.primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        newTag = ""
    }

    private func remove(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}
