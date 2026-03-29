// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import SwiftUI
import ViewModels

struct ComposeView: View {
    @ObservedObject var viewModel: NewStatusViewModel
    @EnvironmentObject var rootViewModel: RootViewModel

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
    }
}

private extension ComposeView {
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
}
