// Copyright © 2024 Metabolist. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers
import ViewModels

struct DocumentPicker: UIViewControllerRepresentable {
    let onComplete: ([URL]) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .movie, .audio])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onComplete(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onComplete([])
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let mediaTypes: [String]
    let onComplete: ([UIImagePickerController.InfoKey: Any]?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = mediaTypes
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.onComplete(info)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onComplete(nil)
        }
    }
}

struct EditAttachmentSheetView: UIViewControllerRepresentable {
    let attachmentViewModel: AttachmentViewModel
    let compositionViewModel: CompositionViewModel

    func makeUIViewController(context: Context) -> UINavigationController {
        let editVC = EditAttachmentViewController(
            viewModel: attachmentViewModel,
            parentViewModel: compositionViewModel)

        let cancelButton = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { _ in
                editVC.presentingViewController?.dismiss(animated: true)
            })
        let doneButton = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak editVC] _ in
                guard let editVC = editVC else { return }
                compositionViewModel.update(attachmentViewModel: attachmentViewModel)
                editVC.presentingViewController?.dismiss(animated: true)
            })

        editVC.navigationItem.leftBarButtonItem = cancelButton
        editVC.navigationItem.rightBarButtonItem = doneButton
        editVC.navigationItem.title = NSLocalizedString("attachment.edit.title", comment: "")

        return UINavigationController(rootViewController: editVC)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
