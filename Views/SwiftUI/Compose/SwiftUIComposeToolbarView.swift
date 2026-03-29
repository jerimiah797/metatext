// Copyright © 2024 Metabolist. All rights reserved.

import Mastodon
import SwiftUI
import ViewModels

struct SwiftUIComposeToolbarView: View {
    @ObservedObject var viewModel: CompositionViewModel
    @ObservedObject var parentViewModel: NewStatusViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: .defaultSpacing) {
                attachmentMenu
                pollButton
                visibilityMenu
                contentWarningButton

                Spacer()

                Text("\(viewModel.remainingCharacters)")
                    .foregroundColor(viewModel.remainingCharacters < 0 ? .red : .primary)
                    .font(.callout.monospacedDigit())

                addButton
            }
            .padding(.horizontal, .defaultSpacing)
            .frame(height: .minimumButtonDimension)
        }
        .background(.bar)
    }
}

private extension SwiftUIComposeToolbarView {
    var attachmentMenu: some View {
        Menu {
            Button {
                parentViewModel.presentMediaPicker(viewModel: viewModel)
            } label: {
                Label("compose.photo-library", systemImage: "rectangle.on.rectangle")
            }
            Button {
                parentViewModel.presentCamera(viewModel: viewModel)
            } label: {
                Label("compose.take-photo-or-video", systemImage: "camera.fill")
            }
            Button {
                parentViewModel.presentDocumentPicker(viewModel: viewModel)
            } label: {
                Label("compose.browse", systemImage: "ellipsis")
            }
        } label: {
            Image(systemName: "paperclip")
                .foregroundColor(.primary)
        }
        .disabled(!viewModel.canAddAttachment)
        .accessibilityIdentifier("compose.attachment")
        .accessibilityLabel(Text("compose.attachments-button.accessibility-label"))
    }

    var pollButton: some View {
        Button {
            viewModel.displayPoll.toggle()
        } label: {
            Image(systemName: "chart.bar.xaxis")
                .foregroundColor(.primary)
        }
        .disabled(!viewModel.attachmentViewModels.isEmpty || !viewModel.attachmentUploadViewModels.isEmpty)
        .accessibilityIdentifier("compose.poll")
        .accessibilityLabel(Text("compose.poll-button.accessibility-label"))
    }

    var visibilityMenu: some View {
        Menu {
            ForEach(Status.Visibility.allCasesExceptUnknown.reversed(), id: \.self) { visibility in
                Button {
                    parentViewModel.visibility = visibility
                } label: {
                    Label {
                        Text(visibility.title ?? "")
                    } icon: {
                        Image(systemName: visibility.systemImageName)
                    }
                }
            }
        } label: {
            Image(systemName: parentViewModel.visibility.systemImageName)
                .foregroundColor(.primary)
        }
        .disabled(!parentViewModel.canChangeVisibility)
        .accessibilityIdentifier("compose.visibility")
    }

    var contentWarningButton: some View {
        Button {
            viewModel.displayContentWarning.toggle()
        } label: {
            Text("status.content-warning-abbreviation")
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .accessibilityIdentifier("compose.content-warning")
        .accessibilityHint(Text(viewModel.displayContentWarning
            ? "compose.content-warning-button.remove"
            : "compose.content-warning-button.add"))
    }

    var addButton: some View {
        Button {
            parentViewModel.insert(after: viewModel)
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.primary)
        }
        .disabled(!viewModel.isPostable)
        .accessibilityIdentifier("compose.add")
    }
}
