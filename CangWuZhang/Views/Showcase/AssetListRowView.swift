import SwiftUI
import UIKit

struct AssetListRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 56, height: 56)
                .overlay {
                    if let data = item.stickerImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage).resizable().scaledToFit().padding(4)
                    } else {
                        Image(systemName: item.category.systemImage)
                            .foregroundStyle(.secondary)
                    }
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.body.weight(.medium))
                HStack(spacing: 6) {
                    Text(item.category.rawValue)
                    Text("·")
                    Text(item.statusDisplayText)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(item.trailingMetricValue)
                    .font(.subheadline.weight(.semibold))
                Text(item.trailingMetricLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
