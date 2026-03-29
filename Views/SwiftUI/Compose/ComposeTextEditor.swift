// Copyright © 2024 Metabolist. All rights reserved.

import SwiftUI
import UIKit

struct ComposeTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var textToSelectedRange: String
    var isInitialFirstResponder: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = context.coordinator.textView

        if isInitialFirstResponder {
            DispatchQueue.main.async {
                textView.becomeFirstResponder()
            }
        }

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        guard !context.coordinator.isUpdatingText else { return }

        if textView.text != text {
            textView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: ComposeTextEditor
        var isUpdatingText = false

        let textView: UITextView = {
            let tv = UITextView()
            tv.font = .preferredFont(forTextStyle: .body)
            tv.adjustsFontForContentSizeCategory = true
            tv.isScrollEnabled = false
            tv.backgroundColor = .clear
            tv.textContainerInset = .zero
            tv.textContainer.lineFragmentPadding = 0
            tv.keyboardType = .twitter
            return tv
        }()

        init(_ parent: ComposeTextEditor) {
            self.parent = parent
            super.init()
            textView.delegate = self
        }

        func textViewDidChange(_ textView: UITextView) {
            isUpdatingText = true
            parent.text = textView.text
            updateTextToSelectedRange(textView)
            isUpdatingText = false
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
