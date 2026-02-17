// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Foundation
import Mastodon
import ServiceLayer

public final class NavigationViewModel: ObservableObject {
    public let identityContext: IdentityContext
    public let navigations: AnyPublisher<Navigation, Never>

    @Published public private(set) var recentIdentities = [Identity]()
    @Published public private(set) var announcementCount: (total: Int, unread: Int) = (0, 0)
    @Published public var presentedNewStatusViewModel: NewStatusViewModel?
    @Published public var presentingSecondaryNavigation = false
    @Published public var alertItem: AlertItem?

    private let navigationsSubject = PassthroughSubject<Navigation, Never>()
    private let environment: AppEnvironment
    private var cancellables = Set<AnyCancellable>()

    public init(identityContext: IdentityContext, environment: AppEnvironment) {
        self.identityContext = identityContext
        self.environment = environment
        navigations = navigationsSubject.eraseToAnyPublisher()

        identityContext.$identity
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        identityContext.service.recentIdentitiesPublisher()
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .assign(to: &$recentIdentities)

        identityContext.service.announcementCountPublisher()
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .assign(to: &$announcementCount)
    }
}

public extension NavigationViewModel {
    enum Tab: Int, CaseIterable {
        case timelines
        case explore
        case notifications
        case messages
    }

    var tabs: [Tab] {
        if identityContext.identity.authenticated {
            return Tab.allCases
        } else {
            return [.timelines, .explore]
        }
    }

    var timelines: [Timeline] {
        if identityContext.identity.authenticated {
            return Timeline.authenticatedDefaults
        } else {
            return Timeline.unauthenticatedDefaults
        }
    }

    func refreshIdentity() {
        if identityContext.identity.pending {
            identityContext.service.verifyCredentials()
                .collect()
                .map { _ in () }
                .flatMap(identityContext.service.confirmIdentity)
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
        } else if identityContext.identity.authenticated {
            identityContext.service.verifyCredentials()
                .assignErrorsToAlertItem(to: \.alertItem, on: self)
                .sink { _ in }
                .store(in: &cancellables)
            identityContext.service.refreshLists()
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
            identityContext.service.refreshFilters()
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
            identityContext.service.refreshEmojis()
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
            identityContext.service.refreshAnnouncements()
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)

            if identityContext.identity.preferences.useServerPostingReadingPreferences {
                identityContext.service.refreshServerPreferences()
                    .sink { _ in } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
        }

        identityContext.service.refreshInstance()
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func navigateToProfile(id: Account.Id) {
        presentingSecondaryNavigation = false
        presentedNewStatusViewModel = nil
        navigationsSubject.send(.profile(identityContext.service.navigationService.profileService(id: id)))
    }

    func navigateToEditProfile(instanceURI: String) {
        let version = identityContext.identity.instance?.version
        guard let editProfileURL = editProfileURL(instanceURI: instanceURI, version: version) else { return }

        if isGoToSocial(version: version) {
            presentingSecondaryNavigation = false
            navigationsSubject.send(.url(editProfileURL))
        } else {
            AuthenticatedWebViewService(environment: environment).authenticatedWebViewPublisher(url: editProfileURL)
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }

    func navigateToAccountSettings(instanceURI: String) {
        let version = identityContext.identity.instance?.version
        guard let accountSettingsURL = accountSettingsURL(instanceURI: instanceURI, version: version) else { return }

        if isGoToSocial(version: version) {
            presentingSecondaryNavigation = false
            navigationsSubject.send(.url(accountSettingsURL))
        } else {
            AuthenticatedWebViewService(environment: environment).authenticatedWebViewPublisher(url: accountSettingsURL)
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }

    func navigate(timeline: Timeline) {
        presentingSecondaryNavigation = false
        presentedNewStatusViewModel = nil
        navigationsSubject.send(
            .collection(identityContext.service.navigationService.timelineService(timeline: timeline)))
    }

    func navigateToFollowerRequests() {
        presentingSecondaryNavigation = false
        presentedNewStatusViewModel = nil
        navigationsSubject.send(.collection(identityContext.service.service(
                                                accountList: .followRequests,
                                                titleComponents: ["follow-requests"])))
    }

    func navigateToMutedUsers() {
        presentingSecondaryNavigation = false
        presentedNewStatusViewModel = nil
        navigationsSubject.send(.collection(identityContext.service.service(
                                                accountList: .mutes,
                                                titleComponents: ["preferences.muted-users"])))
    }

    func navigateToBlockedUsers() {
        presentingSecondaryNavigation = false
        presentedNewStatusViewModel = nil
        navigationsSubject.send(.collection(identityContext.service.service(
                                                accountList: .blocks,
                                                titleComponents: ["preferences.blocked-users"])))
    }

    func navigateToURL(_ url: URL) {
        presentingSecondaryNavigation = false
        presentedNewStatusViewModel = nil
        identityContext.service.navigationService.item(url: url)
            .sink { [weak self] in self?.navigationsSubject.send($0) }
            .store(in: &cancellables)
    }

    func navigate(pushNotification: PushNotification) {
        switch pushNotification.notificationType {
        case .followRequest:
            navigateToFollowerRequests()
        default:
            identityContext.service.notificationService(pushNotification: pushNotification)
                .assignErrorsToAlertItem(to: \.alertItem, on: self)
                .sink { [weak self] in
                    self?.presentingSecondaryNavigation = false
                    self?.presentedNewStatusViewModel = nil
                    self?.navigationsSubject.send(.notification($0))
                }
                .store(in: &cancellables)
        }
    }

    func viewModel(timeline: Timeline) -> CollectionItemsViewModel {
        CollectionItemsViewModel(
            collectionService: identityContext.service.navigationService.timelineService(timeline: timeline),
            identityContext: identityContext)
    }

    func exploreViewModel() -> ExploreViewModel {
        let exploreViewModel = ExploreViewModel(
            service: identityContext.service.exploreService(),
            identityContext: identityContext)

        exploreViewModel.refresh()

        return exploreViewModel
    }

    func notificationsViewModel(excludeTypes: Set<MastodonNotification.NotificationType>) -> CollectionItemsViewModel {
        let viewModel = CollectionItemsViewModel(
            collectionService: identityContext.service.notificationsService(excludeTypes: excludeTypes),
            identityContext: identityContext)

        if excludeTypes.isEmpty {
            viewModel.request(maxId: nil, minId: nil, search: nil)
        }

        return viewModel
    }

    func conversationsViewModel() -> CollectionViewModel {
        let conversationsViewModel = CollectionItemsViewModel(
            collectionService: identityContext.service.conversationsService(),
            identityContext: identityContext)

        conversationsViewModel.request(maxId: nil, minId: nil, search: nil)

        return conversationsViewModel
    }

    func announcementsViewModel() -> CollectionViewModel {
        CollectionItemsViewModel(
            collectionService: identityContext.service.announcementsService(),
            identityContext: identityContext)
    }
}

private extension NavigationViewModel {
    func isGoToSocial(version: String?) -> Bool {
        guard let version = version else { return false }

        // GoToSocial versions contain "gotosocial" (case-insensitive)
        // or have the format "x.y.z+git-hash" which is GoToSocial-specific
        return version.localizedCaseInsensitiveContains("GoToSocial") ||
               version.contains("+git-")
    }

    func accountSettingsURL(instanceURI: String, version: String?) -> URL? {
        let path = isGoToSocial(version: version) ? "/settings" : "/auth/edit"
        if instanceURI.hasPrefix("https://") {
            return URL(string: "\(instanceURI)\(path)")
        } else {
            return URL(string: "https://\(instanceURI)\(path)")
        }
    }

    func editProfileURL(instanceURI: String, version: String?) -> URL? {
        let path = isGoToSocial(version: version) ? "/settings/user/profile" : "/settings/profile"
        if instanceURI.hasPrefix("https://") {
            return URL(string: "\(instanceURI)\(path)")
        } else {
            return URL(string: "https://\(instanceURI)\(path)")
        }
    }
}
