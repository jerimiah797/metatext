// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import SwiftUI
import ViewModels

struct ComposeView: View {
    @ObservedObject var viewModel: NewStatusViewModel
    @EnvironmentObject var rootViewModel: RootViewModel
    @State private var activeCompositionId: CompositionViewModel.Id?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.compositionViewModels, id: \.id) { compositionViewModel in
                        ComposeCompositionView(
                            viewModel: compositionViewModel,
                            parentViewModel: viewModel)

                        if compositionViewModel.id != viewModel.compositionViewModels.last?.id {
                            Divider()
                        }
                    }
                }
            }

            if viewModel.postingState == .posting {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                SwiftUIComposeAutocompleteView(
                    parentViewModel: viewModel,
                    autocompleteQuery: activeComposition?.autocompleteQuery,
                    onSelect: handleAutocompleteSelection)

                SwiftUIComposeToolbarView(
                    viewModel: activeComposition ?? viewModel.compositionViewModels[0],
                    parentViewModel: viewModel)
            }
        }
        .navigationTitle("compose")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(postButtonTitle) {
                    viewModel.post()
                }
                .disabled(!viewModel.canPost)
            }
        }
        .alertItem($viewModel.alertItem)
        .onReceive(viewModel.$postingState) { state in
            if state == .done {
                NotificationCenter.default.post(
                    name: NewStatusViewController.newStatusPostedNotification,
                    object: nil)
                dismiss()
            }
        }
        .onAppear {
            activeCompositionId = viewModel.compositionViewModels.first?.id
        }
    }
}

private extension ComposeView {
    var activeComposition: CompositionViewModel? {
        guard let id = activeCompositionId else {
            return viewModel.compositionViewModels.first
        }
        return viewModel.compositionViewModels.first { $0.id == id }
    }

    var postButtonTitle: LocalizedStringKey {
        switch viewModel.identityContext.appPreferences.statusWord {
        case .toot:
            return "toot"
        case .post:
            return "post"
        }
    }

    func dismiss() {
        rootViewModel.navigationViewModel?.presentedNewStatusViewModel = nil
    }

    func handleAutocompleteSelection(_ replacement: String) {
        guard let composition = activeComposition else { return }

        // Replace the autocomplete query in the text with the selection
        guard let query = composition.autocompleteQuery,
              let range = composition.text.range(
                of: query,
                options: .backwards)
        else { return }

        composition.text.replaceSubrange(range, with: replacement.appending(" "))
    }
}
