// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import ViewModels

struct ComposeView: View {
    @ObservedObject var viewModel: NewStatusViewModel
    @EnvironmentObject var rootViewModel: RootViewModel
    @State private var activeCompositionId: CompositionViewModel.Id?
    @State private var presentedPicker: PickerPresentation?

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
            .scrollDismissesKeyboard(.never)

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
        .onReceive(viewModel.events) { event in
            handle(event: event)
        }
        .onAppear {
            activeCompositionId = viewModel.compositionViewModels.first?.id
        }
        .sheet(item: $presentedPicker) { picker in
            pickerContent(for: picker)
        }
    }
}

private extension ComposeView {
    enum PickerPresentation: Identifiable {
        case mediaPicker(CompositionViewModel)
        case camera(CompositionViewModel)
        case documentPicker(CompositionViewModel)
        case editAttachment(AttachmentViewModel, CompositionViewModel)

        var id: String {
            switch self {
            case .mediaPicker: return "mediaPicker"
            case .camera: return "camera"
            case .documentPicker: return "documentPicker"
            case let .editAttachment(vm, _): return "editAttachment-\(vm.attachment.id)"
            }
        }
    }

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

    @ViewBuilder
    func pickerContent(for picker: PickerPresentation) -> some View {
        switch picker {
        case let .mediaPicker(composition):
            PhotoPicker(
                selectionLimit: composition.canAddNonImageAttachment
                    ? CompositionViewModel.maxAttachmentCount
                    : CompositionViewModel.maxAttachmentCount
                        - composition.attachmentViewModels.count
                        - composition.attachmentUploadViewModels.count,
                filter: composition.canAddNonImageAttachment ? nil : .images
            ) { results in
                presentedPicker = nil
                if !results.isEmpty {
                    viewModel.attach(
                        itemProviders: results.map(\.itemProvider),
                        to: composition)
                }
            }
        case let .camera(composition):
            CameraPicker(
                mediaTypes: composition.canAddNonImageAttachment
                    ? [UTType.image.identifier, UTType.movie.identifier]
                    : [UTType.image.identifier]
            ) { info in
                presentedPicker = nil
                guard let info = info else { return }

                if let url = info[.mediaURL] as? URL,
                   let itemProvider = NSItemProvider(contentsOf: url) {
                    viewModel.attach(itemProviders: [itemProvider], to: composition)
                } else if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    viewModel.attach(itemProviders: [NSItemProvider(object: image)], to: composition)
                }
            }
            .ignoresSafeArea()
        case let .documentPicker(composition):
            DocumentPicker { urls in
                presentedPicker = nil
                let itemProviders = urls.compactMap { url -> NSItemProvider? in
                    guard url.startAccessingSecurityScopedResource() else { return nil }
                    return NSItemProvider(contentsOf: url)
                }
                if !itemProviders.isEmpty {
                    viewModel.attach(itemProviders: itemProviders, to: composition)
                }
                urls.forEach { $0.stopAccessingSecurityScopedResource() }
            }
        case let .editAttachment(attachmentVM, compositionVM):
            NavigationView {
                EditAttachmentView { (attachmentVM, compositionVM) }
            }
        }
    }

    func dismiss() {
        rootViewModel.navigationViewModel?.presentedNewStatusViewModel = nil
    }

    func handleAutocompleteSelection(_ replacement: String) {
        guard let composition = activeComposition else { return }

        guard let query = composition.autocompleteQuery,
              let range = composition.text.range(
                of: query,
                options: .backwards)
        else { return }

        composition.text.replaceSubrange(range, with: replacement.appending(" "))
    }

    func handle(event: NewStatusViewModel.Event) {
        switch event {
        case let .presentMediaPicker(composition):
            presentedPicker = .mediaPicker(composition)
        case let .presentCamera(composition):
            presentedPicker = .camera(composition)
        case let .presentDocumentPicker(composition):
            presentedPicker = .documentPicker(composition)
        case .presentEmojiPicker:
            break
        case let .editAttachment(attachmentVM, compositionVM):
            presentedPicker = .editAttachment(attachmentVM, compositionVM)
        case let .changeIdentity(identity):
            viewModel.setIdentity(identity)
        }
    }
}
