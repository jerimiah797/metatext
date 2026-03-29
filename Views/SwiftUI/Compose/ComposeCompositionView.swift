// Copyright © 2024 Metabolist. All rights reserved.

import SwiftUI
import ViewModels

struct ComposeCompositionView: View {
    @ObservedObject var viewModel: CompositionViewModel
    @ObservedObject var parentViewModel: NewStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
            if viewModel.displayContentWarning {
                TextField("status.content-warning-abbreviation", text: $viewModel.contentWarning)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }

            ComposeTextEditor(
                text: $viewModel.text,
                textToSelectedRange: $viewModel.textToSelectedRange,
                isInitialFirstResponder: isFirstComposition)
                .padding(.horizontal)

            if !viewModel.attachmentViewModels.isEmpty || !viewModel.attachmentUploadViewModels.isEmpty {
                ComposeAttachmentsView(
                    viewModel: viewModel,
                    parentViewModel: parentViewModel)
            }

            if viewModel.displayPoll {
                ComposePollView(viewModel: viewModel)
            }
        }
        .padding(.vertical)
    }
}

private extension ComposeCompositionView {
    var isFirstComposition: Bool {
        parentViewModel.compositionViewModels.first?.id == viewModel.id
    }
}
