import SwiftUI
import UIKit

/// 贴纸模式卡片：个人数字陈列柜的核心视觉单元
struct StickerCardView: View {
    let item: Item

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        if let data = item.stickerImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                        } else {
                            Image(systemName: item.category.systemImage)
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                        }
                    }

                StatusDot(status: item.status)
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(item.showcaseSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

struct StatusDot: View {
    let status: AssetStatus

    var color: Color {
        switch status {
        case .active: return .green
        case .retired: return .orange
        case .sold: return .gray
        }
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
    }
}
