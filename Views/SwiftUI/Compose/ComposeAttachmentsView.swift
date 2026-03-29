// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import Mastodon
import SwiftUI
import ViewModels

struct ComposeAttachmentsView: View {
    @ObservedObject var viewModel: CompositionViewModel
    @ObservedObject var parentViewModel: NewStatusViewModel

    var body: some View {
        VStack(spacing: .defaultSpacing) {
            if !viewModel.attachmentUploadViewModels.isEmpty {
                ForEach(viewModel.attachmentUploadViewModels, id: \.id) { uploadVM in
                    ComposeAttachmentUploadRow(viewModel: uploadVM)
                }
            }

            if !viewModel.attachmentViewModels.isEmpty {
                attachmentGrid

                Toggle("compose.mark-media-sensitive", isOn: $viewModel.sensitive)
                    .font(.callout)
                    .disabled(viewModel.displayContentWarning)
            }
        }
        .padding(.horizontal)
    }
}

private extension ComposeAttachmentsView {
    var attachmentGrid: some View {
        let attachments = viewModel.attachmentViewModels

        return LazyVGrid(
            columns: attachments.count == 1
                ? [GridItem(.flexible())]
                : [GridItem(.flexible()), GridItem(.flexible())],
            spacing: .defaultSpacing
        ) {
            ForEach(attachments, id: \.attachment.id) { attachmentVM in
                attachmentCell(attachmentVM)
            }
        }
    }

    func attachmentCell(_ attachmentVM: AttachmentViewModel) -> some View {
        ZStack(alignment: .topTrailing) {
            if let previewUrl = attachmentVM.attachment.previewUrl?.url {
                AsyncImage(url: previewUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.secondarySystemBackground)
                }
                .frame(height: 150)
                .clipped()
                .cornerRadius(.defaultCornerRadius)
            } else {
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 150)
                    .overlay {
                        Image(systemName: iconName(for: attachmentVM.attachment.type))
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
            }

            Button(role: .destructive) {
                viewModel.removeAttachment(viewModel: attachmentVM)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.6))
            }
            .padding(4)

            if attachmentVM.attachment.description?.isEmpty ?? true {
                VStack {
                    Spacer()
                    HStack {
                        Text("compose.attachment.uncaptioned")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .cornerRadius(4)
                        Spacer()
                    }
                    .padding(4)
                }
            }
        }
        .onTapGesture {
            viewModel.attachmentSelected(viewModel: attachmentVM)
        }
    }

    func iconName(for type: Attachment.AttachmentType) -> String {
        switch type {
        case .image: return "photo"
        case .video, .gifv: return "video"
        case .audio: return "waveform"
        case .unknown: return "doc"
        }
    }
}

struct ComposeAttachmentUploadRow: View {
    @ObservedObject var viewModel: AttachmentUploadViewModel
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: .compactSpacing) {
            HStack {
                Text("compose.attachment.uploading")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Spacer()
                Button("cancel") {
                    viewModel.cancel()
                }
                .font(.callout)
            }
            ProgressView(value: progress)
        }
        .onReceive(viewModel.progress.publisher(for: \.fractionCompleted)) { value in
            progress = value
        }
    }
}
