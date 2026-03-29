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
            }

            ComposeTextEditor(
                text: $viewModel.text,
                textToSelectedRange: $viewModel.textToSelectedRange,
                isInitialFirstResponder: isFirstComposition)

            HStack {
                Spacer()
                Text("\(viewModel.remainingCharacters)")
                    .foregroundColor(viewModel.remainingCharacters < 0 ? .red : .secondary)
                    .font(.callout.monospacedDigit())
            }
        }
        .padding()
    }
}

private extension ComposeCompositionView {
    var isFirstComposition: Bool {
        parentViewModel.compositionViewModels.first?.id == viewModel.id
    }
}
