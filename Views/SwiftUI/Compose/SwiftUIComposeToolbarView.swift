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
            HStack(spacing: 0) {
                attachmentMenu
                pollButton
                visibilityMenu
                contentWarningButton
                emojiButton

                Spacer()

                Text("\(viewModel.remainingCharacters)")
                    .foregroundColor(viewModel.remainingCharacters < 0 ? .red : .primary)
                    .font(.callout.monospacedDigit())
                    .padding(.trailing, 4)

                addButton
            }
            .padding(.horizontal, 4)
            .frame(height: .minimumButtonDimension)
        }
        .background(.bar)
    }
}

private extension SwiftUIComposeToolbarView {
    var toolbarButtonFont: Font { .body }

    func toolbarButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(toolbarButtonFont)
                .foregroundColor(.primary)
                .frame(width: .minimumButtonDimension, height: .minimumButtonDimension)
                .contentShape(Rectangle())
        }
    }

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
                .font(toolbarButtonFont)
                .foregroundColor(.primary)
                .frame(width: .minimumButtonDimension, height: .minimumButtonDimension)
                .contentShape(Rectangle())
        }
        .disabled(!viewModel.canAddAttachment)
        .accessibilityIdentifier("compose.attachment")
        .accessibilityLabel(Text("compose.attachments-button.accessibility-label"))
    }

    var pollButton: some View {
        toolbarButton(systemImage: "chart.bar.xaxis") {
            viewModel.displayPoll.toggle()
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
                .font(toolbarButtonFont)
                .foregroundColor(.primary)
                .frame(width: .minimumButtonDimension, height: .minimumButtonDimension)
                .contentShape(Rectangle())
        }
        .disabled(!parentViewModel.canChangeVisibility)
        .accessibilityIdentifier("compose.visibility")
    }

    var contentWarningButton: some View {
        Button {
            viewModel.displayContentWarning.toggle()
        } label: {
            Text("status.content-warning-abbreviation")
                .font(.body.bold())
                .foregroundColor(.primary)
                .frame(width: .minimumButtonDimension, height: .minimumButtonDimension)
                .contentShape(Rectangle())
        }
        .accessibilityIdentifier("compose.content-warning")
        .accessibilityHint(Text(viewModel.displayContentWarning
            ? "compose.content-warning-button.remove"
            : "compose.content-warning-button.add"))
    }

    var emojiButton: some View {
        toolbarButton(systemImage: "face.smiling") {
            parentViewModel.presentEmojiPicker(tag: 0)
        }
        .accessibilityIdentifier("compose.emoji")
        .accessibilityLabel(Text("compose.emoji-button"))
    }

    var addButton: some View {
        toolbarButton(systemImage: "plus.circle.fill") {
            parentViewModel.insert(after: viewModel)
        }
        .disabled(!viewModel.isPostable)
        .accessibilityIdentifier("compose.add")
    }
}
