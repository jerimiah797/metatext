// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Foundation
import ServiceLayer
import os.log

public final class SearchViewModel: CollectionItemsViewModel {
    @Published public var query = ""
    @Published public var scope = SearchScope.all
    @Published public var isFederatedSearchInProgress = false

    private let searchService: SearchService
    private var cancellables = Set<AnyCancellable>()
    private var lastSearchWasFederated = false
    private static let log = OSLog(subsystem: "org.arctian.metatext", category: "SearchViewModel")

    public init(identityContext: IdentityContext) {
        self.searchService = identityContext.service.searchService()

        super.init(collectionService: searchService, identityContext: identityContext)

        // Shared base publisher for query + scope changes
        let queryChanges = $query.dropFirst()
            .removeDuplicates()
            .combineLatest($scope.removeDuplicates())
            .share()

        // Stage 1: Local search (0.3s debounce, resolve: false)
        let localSearch = queryChanges
            .debounce(for: .seconds(Self.localDebounceInterval), scheduler: DispatchQueue.global())
            .handleEvents(receiveOutput: { [weak self] queryScope in
                os_log("🔍 Local search triggering for: %{public}@ (scope: %{public}@)", log: SearchViewModel.log, type: .info, queryScope.0, String(describing: queryScope.1))
                self?.cancelRequests()
            })
            .map { (query: $0.0, scope: $0.1, resolve: false) }

        // Stage 2: Federated search (2.5s debounce, resolve: true)
        let federatedSearch = queryChanges
            .debounce(for: .seconds(Self.federatedDebounceInterval), scheduler: DispatchQueue.global())
            .handleEvents(receiveOutput: { queryScope in
                os_log("🌐 Federated search triggering for: %{public}@ (scope: %{public}@)", log: SearchViewModel.log, type: .info, queryScope.0, String(describing: queryScope.1))
                // Note: Don't cancel here - let local search complete while federated runs
            })
            .map { (query: $0.0, scope: $0.1, resolve: true) }

        // Merge both search stages into single pipeline
        localSearch
            .merge(with: federatedSearch)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] params in
                guard let self = self else { return }

                let search = Search(
                    query: params.query,
                    type: params.scope.type,
                    resolve: params.resolve,
                    limit: params.scope.limit
                )

                // Track search type and update loading state
                self.lastSearchWasFederated = params.resolve
                if params.resolve {
                    self.isFederatedSearchInProgress = true
                }

                let searchType = params.resolve ? "FEDERATED" : "LOCAL"
                let typeStr = params.scope.type?.rawValue ?? "all"
                os_log("📡 Requesting %{public}@ search: query=%{public}@, resolve=%{public}@, type=%{public}@",
                       log: SearchViewModel.log, type: .info, searchType, params.query, String(params.resolve), typeStr)

                self.request(maxId: nil, minId: nil, search: search)
            }
            .store(in: &cancellables)

        // Clear federated loading state when loading completes
        loading
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if !isLoading && self.lastSearchWasFederated {
                    os_log("✅ Federated search completed, clearing progress indicator", log: SearchViewModel.log, type: .info)
                    self.isFederatedSearchInProgress = false
                }
            }
            .store(in: &cancellables)
    }

    public override func requestNextPage(fromIndexPath indexPath: IndexPath) {
        guard scope != .all else { return }

        os_log("📄 Pagination request: query=%{public}@, offset=%d, resolve=false (local only)",
               log: SearchViewModel.log, type: .info, query, indexPath.item + 1)

        request(
            maxId: nil,
            minId: nil,
            search: .init(
                query: query,
                type: scope.type,
                resolve: false,  // Pagination should be local only
                limit: nil,
                offset: indexPath.item + 1
            )
        )
    }
}

private extension SearchViewModel {
    static let localDebounceInterval: TimeInterval = 0.3
    static let federatedDebounceInterval: TimeInterval = 2.5
}

private extension SearchScope {
    var type: Search.SearchType? {
        switch self {
        case .all:
            return nil
        case .accounts:
            return .accounts
        case .statuses:
            return .statuses
        case .tags:
            return .hashtags
        }
    }

    var limit: Int? {
        switch self {
        case .all:
            return 5
        default:
            return nil
        }
    }
}
