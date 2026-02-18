// Copyright © 2024 Metabolist. All rights reserved.

import Mastodon
import SwiftUI
import ViewModels

struct EditFilterV2View: View {
    @StateObject var viewModel: EditFilterV2ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("filter.title")) {
                TextField("filter.title", text: $viewModel.title)
                    .accessibilityIdentifier("filter.title.field")
            }

            Section(header: Text("filter.action")) {
                Picker("filter.action", selection: $viewModel.filterAction) {
                    Text("filter.action.warn").tag(FilterV2.Action.warn)
                    Text("filter.action.hide").tag(FilterV2.Action.hide)
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibilityIdentifier("filter.action.picker")
            }

            Section {
                if viewModel.isNew || viewModel.expiresAt == nil {
                    Toggle("filter.never-expires", isOn: .init(
                            get: { viewModel.expiresAt == nil },
                            set: { viewModel.expiresAt = $0 ? nil : viewModel.date }))
                        .accessibilityIdentifier("filter.never-expires.toggle")
                }

                if viewModel.expiresAt != nil {
                    DatePicker(selection: $viewModel.date, in: Date()...) {
                        Text("filter.expire-after")
                    }
                }
            }

            Section(header: Text("filter.contexts")) {
                ForEach(Filter.Context.allCasesExceptUnknown) { context in
                    Toggle(context.localized, isOn: .init(
                            get: { viewModel.context.contains(context) },
                            set: { _ in viewModel.toggleSelection(context: context) }))
                        .accessibilityIdentifier("filter.context.\(context.rawValue)")
                }
            }

            Section(header: Text("filter.keywords")) {
                ForEach(viewModel.keywords.indices, id: \.self) { index in
                    HStack {
                        TextField("filter.keyword-or-phrase",
                                  text: $viewModel.keywords[index].keyword)
                            .autocapitalization(.none)
                            .accessibilityIdentifier("filter.keyword.\(index).field")
                        Toggle("filter.whole-word",
                               isOn: $viewModel.keywords[index].wholeWord)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle())
                            .accessibilityIdentifier("filter.keyword.\(index).whole-word")
                    }
                }
                .onDelete(perform: viewModel.removeKeyword)

                Button {
                    viewModel.addKeyword()
                } label: {
                    Label("filter.keyword.add", systemImage: "plus.circle")
                }
            }
        }
        .alertItem($viewModel.alertItem)
        .onReceive(viewModel.saveCompleted) { presentationMode.wrappedValue.dismiss() }
        .navigationTitle(viewModel.isNew ? "filter.add-new" : "filter.edit")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Group {
                    if viewModel.saving {
                        ProgressView()
                    } else {
                        Button(viewModel.isNew ? "add" : "filter.save-changes",
                            action: viewModel.save)
                            .disabled(viewModel.isSaveDisabled)
                            .accessibilityIdentifier("filter.save")
                    }
                }
            }
        }
    }
}

#if DEBUG
import PreviewViewModels

struct EditFilterV2View_Previews: PreviewProvider {
    static var previews: some View {
        EditFilterV2View(viewModel: .init(filter: .new, identityContext: .preview))
    }
}
#endif
