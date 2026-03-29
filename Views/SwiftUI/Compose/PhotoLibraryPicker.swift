// Copyright © 2024 Metabolist. All rights reserved.

import Photos
import SwiftUI
import UIKit

enum MediaFilter {
    case all
    case imagesOnly
}

struct PhotoLibraryPicker: View {
    let selectionLimit: Int
    let filter: MediaFilter
    let onComplete: ([NSItemProvider]) -> Void
    let onCancel: () -> Void

    @StateObject private var viewModel = PhotoLibraryPickerViewModel()
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Text(
                    String.localizedStringWithFormat(
                        NSLocalizedString("photo-picker.title-%ld", comment: ""),
                        selectionLimit)))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            onCancel()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityIdentifier("photo-picker.cancel")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if isExporting {
                            ProgressView()
                        } else {
                            Button {
                                confirmSelection()
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(viewModel.selectedAssets.isEmpty)
                            .accessibilityIdentifier("photo-picker.add")
                        }
                    }
                }
        }
        .task {
            await viewModel.requestAccessIfNeeded()
            viewModel.fetchAssets(filter: filter)
        }
    }
}

// MARK: - Content Views

private extension PhotoLibraryPicker {
    @ViewBuilder
    var content: some View {
        switch viewModel.authorizationStatus {
        case .authorized, .limited:
            photoGrid
        case .denied, .restricted:
            deniedView
        case .notDetermined:
            ProgressView()
        @unknown default:
            deniedView
        }
    }

    var photoGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 4),
                spacing: 2
            ) {
                ForEach(0..<viewModel.assetCount, id: \.self) { index in
                    PhotoGridCell(
                        asset: viewModel.asset(at: index),
                        index: index,
                        selectionNumber: viewModel.selectionIndex(at: index),
                        cachingManager: viewModel.cachingManager,
                        thumbnailSize: viewModel.thumbnailSize
                    ) {
                        viewModel.toggle(at: index)
                    }
                    .accessibilityIdentifier("photo-picker.photo-\(index)")
                }
            }
        }
    }

    var deniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("photo-picker.access-denied")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("photo-picker.open-settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .accessibilityIdentifier("photo-picker.open-settings")
        }
        .padding()
    }

    func confirmSelection() {
        isExporting = true
        viewModel.buildItemProviders { providers in
            isExporting = false
            onComplete(providers)
        }
    }
}

// MARK: - Grid Cell

private struct PhotoGridCell: View {
    let asset: PHAsset
    let index: Int
    let selectionNumber: Int?
    let cachingManager: PHCachingImageManager
    let thumbnailSize: CGSize
    let onTap: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geometry in
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                } else {
                    Color(.secondarySystemBackground)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                }
            }
            .aspectRatio(1, contentMode: .fit)

            if asset.mediaType == .video {
                durationBadge
            }

            if let number = selectionNumber {
                selectionBadge(number: number)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UISelectionFeedbackGenerator().selectionChanged()
            onTap()
        }
        .task(id: asset.localIdentifier) {
            await loadThumbnail()
        }
    }
}

private extension PhotoGridCell {
    var durationBadge: some View {
        Text(formatDuration(asset.duration))
            .font(.caption2.monospacedDigit())
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(.black.opacity(0.6))
            .cornerRadius(2)
            .padding(4)
    }

    func selectionBadge(number: Int) -> some View {
        ZStack {
            Circle()
                .fill(.blue)
                .frame(width: 24, height: 24)
            Text("\(number)")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    func loadThumbnail() async {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        thumbnail = await withCheckedContinuation { continuation in
            cachingManager.requestImage(
                for: asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                } else if thumbnail == nil {
                    // Accept degraded only if we have nothing yet
                    // But don't resume continuation — wait for the full image
                }
            }
        }
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - View Model

final class PhotoLibraryPickerViewModel: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var selectedAssets = [PHAsset]()
    @Published private(set) var assetCount = 0

    let cachingManager = PHCachingImageManager()
    var selectionLimit = 4

    private var fetchResult: PHFetchResult<PHAsset>?

    let thumbnailSize: CGSize = {
        let side = (UIScreen.main.bounds.width / 4) * UIScreen.main.scale
        return CGSize(width: side, height: side)
    }()

    func requestAccessIfNeeded() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            await MainActor.run { authorizationStatus = newStatus }
        } else {
            await MainActor.run { authorizationStatus = status }
        }
    }

    func fetchAssets(filter: MediaFilter) {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else { return }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        if filter == .imagesOnly {
            options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        }

        let result = PHAsset.fetchAssets(with: options)
        fetchResult = result
        assetCount = result.count
    }

    func asset(at index: Int) -> PHAsset {
        fetchResult!.object(at: index)
    }

    func toggle(at index: Int) {
        let asset = self.asset(at: index)
        if let existingIndex = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: existingIndex)
        } else if selectedAssets.count < selectionLimit {
            selectedAssets.append(asset)
        }
    }

    func selectionIndex(at index: Int) -> Int? {
        let asset = self.asset(at: index)
        guard let i = selectedAssets.firstIndex(of: asset) else { return nil }
        return i + 1
    }

    func buildItemProviders(completion: @escaping ([NSItemProvider]) -> Void) {
        let assets = selectedAssets
        let group = DispatchGroup()
        var providers = [(Int, NSItemProvider)]()
        let lock = NSLock()

        for (index, asset) in assets.enumerated() {
            group.enter()

            if asset.mediaType == .video {
                buildVideoProvider(asset: asset) { provider in
                    if let provider = provider {
                        lock.lock()
                        providers.append((index, provider))
                        lock.unlock()
                    }
                    group.leave()
                }
            } else {
                buildImageProvider(asset: asset) { provider in
                    if let provider = provider {
                        lock.lock()
                        providers.append((index, provider))
                        lock.unlock()
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            let sorted = providers.sorted { $0.0 < $1.0 }.map(\.1)
            completion(sorted)
        }
    }
}

private extension PhotoLibraryPickerViewModel {
    func buildImageProvider(asset: PHAsset, completion: @escaping (NSItemProvider?) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, uti, _, _ in
            guard let data = data, let uti = uti else {
                completion(nil)
                return
            }

            let provider = NSItemProvider()
            provider.registerDataRepresentation(forTypeIdentifier: uti, visibility: .all) { handler in
                handler(data, nil)
                return Progress()
            }
            completion(provider)
        }
    }

    func buildVideoProvider(asset: PHAsset, completion: @escaping (NSItemProvider?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            guard let urlAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }

            let provider = NSItemProvider(contentsOf: urlAsset.url)
            completion(provider)
        }
    }
}
