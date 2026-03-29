// Copyright © 2024 Metabolist. All rights reserved.

import SwiftUI
import UIKit

struct ComposeTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var textToSelectedRange: String
    var isInitialFirstResponder: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = context.coordinator

        if isInitialFirstResponder {
            DispatchQueue.main.async {
                textView.becomeFirstResponder()
            }
        }

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: ComposeTextEditor

        init(_ parent: ComposeTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            updateTextToSelectedRange(textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            updateTextToSelectedRange(textView)
        }

        private func updateTextToSelectedRange(_ textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange,
                  let textRange = textView.textRange(from: textView.beginningOfDocument, to: selectedRange.end)
            else { return }

            parent.textToSelectedRange = textView.text(in: textRange) ?? ""
        }
    }
}
