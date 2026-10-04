import SwiftUI
import PhotosUI
import UIKit

struct PhotosPickerSection: View {
    @Binding var photoItem: PhotosPickerItem?
    let stickerImage: UIImage?
    let isProcessing: Bool
    let onPick: (PhotosPickerItem?) -> Void

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 140, height: 140)

                    if isProcessing {
                        ProgressView("AI 抠图中…")
                    } else if let stickerImage {
                        Image(uiImage: stickerImage)
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    } else {
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("添加照片")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text(stickerImage == nil ? "选择照片" : "更换照片")
                        .font(.caption)
                }
                .onChange(of: photoItem) { _, newValue in
                    onPick(newValue)
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
