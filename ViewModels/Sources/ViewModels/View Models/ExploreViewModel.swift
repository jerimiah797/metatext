// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Foundation
import Mastodon
import ServiceLayer
import os

private let exploreLogger = Logger(subsystem: "org.arctian.metatext", category: "ExploreViewModel")

public final class ExploreViewModel: ObservableObject {
    public let searchViewModel: SearchViewModel
    public let events: AnyPublisher<Event, Never>
    @Published public var instanceViewModel: InstanceViewModel?
    @Published public var trends = [Tag]()
    @Published public private(set) var loading = false
    @Published public var alertItem: AlertItem?
    public let identityContext: IdentityContext

    private let exploreService: ExploreService
    private let eventsSubject = PassthroughSubject<Event, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(service: ExploreService, identityContext: IdentityContext) {
        exploreService = service
        self.identityContext = identityContext
        searchViewModel = SearchViewModel(identityContext: identityContext)
        events = eventsSubject.eraseToAnyPublisher()

        identityContext.$identity
            .handleEvents(receiveOutput: { identity in
                exploreLogger.debug("identity changed (instance: \(identity.instance?.uri ?? "nil", privacy: .public))")
            })
            .compactMap { $0.instance?.uri }
            .removeDuplicates()
            .handleEvents(receiveOutput: { uri in
                exploreLogger.debug("URI emitted: \(uri, privacy: .public)")
            })
            .flatMap { service.instanceServicePublisher(uri: $0) }
            .handleEvents(receiveOutput: { instanceService in
                exploreLogger.debug("instanceService emitted (version: \(instanceService.instance.version, privacy: .public))")
            })
            .map { InstanceViewModel(instanceService: $0) }
            .handleEvents(receiveOutput: { viewModel in
                let version = (viewModel as? InstanceViewModel)?.instance.version ?? "unknown"
                exploreLogger.debug("instanceViewModel created (version: \(version, privacy: .public))")
            })
            .receive(on: DispatchQueue.main)
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .assign(to: &$instanceViewModel)
    }
}

public extension ExploreViewModel {
    enum Event {
        case navigation(Navigation)
    }

    enum Section: Hashable {
        case trending
        case instance
    }

    enum Item: Hashable {
        case tag(Tag)
        case instance
        case profileDirectory
    }

    func refresh() {
        let version = identityContext.identity.instance?.version
        exploreLogger.debug("refresh() - version: \(version ?? "nil", privacy: .public), isGoToSocial: \(self.isGoToSocial(version: version))")

        // GoToSocial doesn't support /api/v1/trends, so skip the call
        if isGoToSocial(version: version) {
            // Just refresh instance, skip trends
            DispatchQueue.main.async { [weak self] in
                self?.trends = [] // Clear trends for GoToSocial instances
            }

            identityContext.service.refreshInstance()
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.loading = true },
                              receiveCompletion: { [weak self] _ in self?.loading = false })
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
        } else {
            // Mastodon: fetch trends + refresh instance
            exploreService.fetchTrends()
                .handleEvents(receiveOutput: { [weak self] trends in
                    DispatchQueue.main.async {
                        self?.trends = trends
                    }
                })
                .ignoreOutput()
                .merge(with: identityContext.service.refreshInstance())
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.loading = true },
                              receiveCompletion: { [weak self] _ in self?.loading = false })
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }

    func viewModel(tag: Tag) -> TagViewModel {
        .init(tag: tag, identityContext: identityContext)
    }

    func select(item: ExploreViewModel.Item) {
        switch item {
        case let .tag(tag):
            eventsSubject.send(
                .navigation(.collection(exploreService
                                            .navigationService
                                            .timelineService(timeline: .tag(tag.name)))))
        case .instance:
            break
        case .profileDirectory:
            eventsSubject.send(
                .navigation(.collection(identityContext
                                            .service
                                            .service(accountList: .directory(local: true),
                                                     titleComponents: ["explore.profile-directory"]))))
        }
    }
}

private extension ExploreViewModel {
    func isGoToSocial(version: String?) -> Bool {
        guard let version = version else { return false }

        // GoToSocial versions contain "gotosocial" (case-insensitive)
        // or have the format "x.y.z+git-hash" which is GoToSocial-specific
        return version.localizedCaseInsensitiveContains("GoToSocial") ||
               version.contains("+git-")
    }
}
