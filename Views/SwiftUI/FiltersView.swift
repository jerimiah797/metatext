// Copyright © 2020 Metabolist. All rights reserved.

import Mastodon
import SwiftUI
import ViewModels

struct FiltersView: View {
    @StateObject var viewModel: FiltersViewModel

    var body: some View {
        Form {
            Section {
                Toggle(isOn: .init(
                    get: { viewModel.useFiltersV2 },
                    set: { _ in viewModel.toggleUseFiltersV2() }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("filter.use-v2")
                        Text("filter.use-v2.subtitle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityIdentifier("filters.use-v2")
            }

            if viewModel.useFiltersV2 {
                Section {
                    NavigationLink(destination: EditFilterV2View(
                                    viewModel: .init(filter: .new,
                                                     identityContext: viewModel.identityContext))) {
                        Label("add", systemImage: "plus.circle")
                    }
                    .accessibilityIdentifier("filters.add")
                }
                v2Section(title: "filters.active", filters: viewModel.activeFiltersV2)
                v2Section(title: "filters.expired", filters: viewModel.expiredFiltersV2)
            } else {
                Section {
                    NavigationLink(destination: EditFilterView(
                                    viewModel: .init(filter: .new,
                                                     identityContext: viewModel.identityContext))) {
                        Label("add", systemImage: "plus.circle")
                    }
                    .accessibilityIdentifier("filters.add")
                }
                section(title: "filters.active", filters: viewModel.activeFilters)
                section(title: "filters.expired", filters: viewModel.expiredFilters)
            }
        }
        .navigationTitle("preferences.filters")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                EditButton()
                    .accessibilityIdentifier("filters.edit")
            }
        }
        .alertItem($viewModel.alertItem)
        .onAppear(perform: viewModel.refreshFilters)
    }
}

private extension FiltersView {
    @ViewBuilder
    func section(title: LocalizedStringKey, filters: [Filter]) -> some View {
        if !filters.isEmpty {
            Section(header: Text(title)) {
                ForEach(filters) { filter in
                    NavigationLink(destination: EditFilterView(
                                    viewModel: .init(filter: filter, identityContext: viewModel.identityContext))) {
                        HStack {
                            Text(filter.phrase)
                            Spacer()
                            Text(ListFormatter.localizedString(byJoining: filter.context.map(\.localized)))
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityIdentifier("filters.filter.\(filter.id)")
                }
                .onDelete {
                    guard let index = $0.first else { return }

                    viewModel.delete(filter: filters[index])
                }
            }
        }
    }

    @ViewBuilder
    func v2Section(title: LocalizedStringKey, filters: [FilterV2]) -> some View {
        if !filters.isEmpty {
            Section(header: Text(title)) {
                ForEach(filters) { filter in
                    NavigationLink(destination: EditFilterV2View(
                                    viewModel: .init(filter: filter,
                                                     identityContext: viewModel.identityContext))) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(filter.title)
                                Text(filter.keywords.map(\.keyword).joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(filter.filterAction == .warn
                                 ? NSLocalizedString("filter.action.warn", comment: "")
                                 : NSLocalizedString("filter.action.hide", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityIdentifier("filters.filter-v2.\(filter.id)")
                }
                .onDelete {
                    guard let index = $0.first else { return }

                    viewModel.deleteV2(filter: filters[index])
                }
            }
        }
    }
}

#if DEBUG
import PreviewViewModels

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView(viewModel: .init(identityContext: .preview))
    }
}
#endif
