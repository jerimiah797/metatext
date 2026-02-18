// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Foundation
import Mastodon
import ServiceLayer

public final class FiltersViewModel: ObservableObject {
    @Published public var activeFilters = [Filter]()
    @Published public var expiredFilters = [Filter]()
    @Published public var activeFiltersV2 = [FilterV2]()
    @Published public var expiredFiltersV2 = [FilterV2]()
    @Published public var alertItem: AlertItem?
    @Published public var useFiltersV2: Bool
    public let identityContext: IdentityContext

    private var cancellables = Set<AnyCancellable>()

    public init(identityContext: IdentityContext) {
        self.identityContext = identityContext
        useFiltersV2 = identityContext.identity.preferences.useFiltersV2

        if useFiltersV2 {
            identityContext.service.activeFiltersV2Publisher()
                .assignErrorsToAlertItem(to: \.alertItem, on: self)
                .assign(to: &$activeFiltersV2)

            identityContext.service.expiredFiltersV2Publisher()
                .assignErrorsToAlertItem(to: \.alertItem, on: self)
                .assign(to: &$expiredFiltersV2)
        } else {
            identityContext.service.activeFiltersPublisher()
                .assignErrorsToAlertItem(to: \.alertItem, on: self)
                .assign(to: &$activeFilters)

            identityContext.service.expiredFiltersPublisher()
                .assignErrorsToAlertItem(to: \.alertItem, on: self)
                .assign(to: &$expiredFilters)
        }
    }
}

public extension FiltersViewModel {
    func refreshFilters() {
        identityContext.service.refreshFilters(useFiltersV2: useFiltersV2)
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .sink { _ in }
            .store(in: &cancellables)
    }

    func delete(filter: Filter) {
        identityContext.service.deleteFilter(id: filter.id)
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .sink { _ in }
            .store(in: &cancellables)
    }

    func deleteV2(filter: FilterV2) {
        identityContext.service.deleteFilterV2(id: filter.id)
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .sink { _ in }
            .store(in: &cancellables)
    }

    func toggleUseFiltersV2() {
        var preferences = identityContext.identity.preferences

        preferences.useFiltersV2.toggle()
        useFiltersV2 = preferences.useFiltersV2

        identityContext.service.updatePreferences(preferences,
                                                  authenticated: identityContext.identity.authenticated)
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .sink { _ in }
            .store(in: &cancellables)
    }
}
