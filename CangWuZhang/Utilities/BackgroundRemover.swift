import UIKit
import Vision

/// 基于苹果 Vision 框架的本地 AI 抠图：识别照片主体并生成透明背景的贴纸图。
/// 完全离线运行，无需网络、无第三方费用（iOS 17+，对应"主体识别抠图"能力）。
enum BackgroundRemover {
    enum RemovalError: Error {
        case noSubjectFound
        case processingFailed
    }

    static func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else { throw RemovalError.processingFailed }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImagePropertyOrientation)
            do {
                try handler.perform([request])
                guard let result = request.results?.first,
                      !result.allInstances.isEmpty else {
                    continuation.resume(throwing: RemovalError.noSubjectFound)
                    return
                }
                let maskedPixelBuffer = try result.generateMaskedImage(
                    ofInstances: result.allInstances,
                    from: handler,
                    croppedToInstancesExtent: true
                )
                let ciImage = CIImage(cvPixelBuffer: maskedPixelBuffer)
                let context = CIContext()
                guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                    continuation.resume(throwing: RemovalError.processingFailed)
                    return
                }
                let stickerImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: .up)
                continuation.resume(returning: stickerImage)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

private extension UIImage {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
