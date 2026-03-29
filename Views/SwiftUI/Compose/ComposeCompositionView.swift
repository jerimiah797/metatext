// Copyright © 2024 Metabolist. All rights reserved.

import SwiftUI
import ViewModels

struct ComposeCompositionView: View {
    @ObservedObject var viewModel: CompositionViewModel
    @ObservedObject var parentViewModel: NewStatusViewModel

    var body: some View {
        HStack(alignment: .top, spacing: .defaultSpacing) {
            avatarView
                .padding(.leading)

            VStack(alignment: .leading, spacing: .defaultSpacing) {
                if viewModel.displayContentWarning {
                    TextField("status.content-warning-abbreviation", text: $viewModel.contentWarning)
                        .textFieldStyle(.roundedBorder)
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.text.isEmpty {
                        Text("compose.prompt")
                            .foregroundColor(.secondary)
                            .padding(.top, 1)
                    }

                    ComposeTextEditor(
                        text: $viewModel.text,
                        textToSelectedRange: $viewModel.textToSelectedRange,
                        isInitialFirstResponder: isFirstComposition)
                }

                if !viewModel.attachmentViewModels.isEmpty || !viewModel.attachmentUploadViewModels.isEmpty {
                    ComposeAttachmentsView(
                        viewModel: viewModel,
                        parentViewModel: parentViewModel)
                }

                if viewModel.displayPoll {
                    ComposePollView(viewModel: viewModel)
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical)
    }
}

private extension ComposeCompositionView {
    var isFirstComposition: Bool {
        parentViewModel.compositionViewModels.first?.id == viewModel.id
    }

    var avatarView: some View {
        AsyncImage(url: avatarURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color(.secondarySystemBackground)
        }
        .frame(width: .avatarDimension, height: .avatarDimension)
        .clipShape(Circle())
    }

    var avatarURL: URL? {
        let identity = parentViewModel.identityContext.identity
        let animate = parentViewModel.identityContext.appPreferences.animateAvatars == .everywhere
        return (animate ? identity.account?.avatar : identity.account?.avatarStatic)?.url
    }
}
