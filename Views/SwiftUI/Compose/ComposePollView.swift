// Copyright © 2024 Metabolist. All rights reserved.

import SwiftUI
import ViewModels

struct ComposePollView: View {
    @ObservedObject var viewModel: CompositionViewModel

    var body: some View {
        VStack(spacing: .defaultSpacing) {
            ForEach(Array(viewModel.pollOptions.enumerated()), id: \.element.id) { index, option in
                pollOptionRow(option: option, index: index)
            }

            HStack {
                Button {
                    viewModel.addPollOption()
                } label: {
                    Label("compose.poll.add-choice", systemImage: "plus")
                }
                .disabled(viewModel.pollOptions.count >= CompositionViewModel.maxPollOptionCount)

                Spacer()

                expiryMenu
            }

            Toggle("compose.poll.allow-multiple-choices", isOn: $viewModel.pollMultipleChoice)
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(.defaultCornerRadius)
        .padding(.horizontal)
    }
}

private extension ComposePollView {
    func pollOptionRow(option: CompositionViewModel.PollOption, index: Int) -> some View {
        HStack(spacing: .defaultSpacing) {
            TextField(
                String.localizedStringWithFormat(
                    NSLocalizedString("status.poll.option-%ld", comment: ""),
                    index + 1),
                text: Binding(
                    get: { option.text },
                    set: { option.text = $0 }))
                .textFieldStyle(.roundedBorder)

            Text("\(option.remainingCharacters)")
                .foregroundColor(option.remainingCharacters < 0 ? .red : .secondary)
                .font(.callout.monospacedDigit())

            if index >= CompositionViewModel.minPollOptionCount {
                Button(role: .destructive) {
                    viewModel.remove(pollOption: option)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }

    var expiryMenu: some View {
        Menu {
            ForEach(CompositionViewModel.PollExpiry.allCases, id: \.self) { expiry in
                Button(Self.format(expiry: expiry)) {
                    viewModel.pollExpiresIn = expiry
                }
            }
        } label: {
            Label(Self.format(expiry: viewModel.pollExpiresIn), systemImage: "clock")
                .font(.callout)
        }
    }

    static let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    static func format(expiry: CompositionViewModel.PollExpiry) -> String {
        dateComponentsFormatter.string(from: TimeInterval(expiry.rawValue)) ?? ""
    }
}
