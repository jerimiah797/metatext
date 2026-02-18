// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import DB
import Foundation
import Mastodon
import MastodonAPI

public struct ContextService {
    public let sections: AnyPublisher<[CollectionSection], Error>
    public let navigationService: NavigationService

    private let id: Status.Id
    private let mastodonAPIClient: MastodonAPIClient
    private let contentDatabase: ContentDatabase

    init(id: Status.Id,
         environment: AppEnvironment,
         mastodonAPIClient: MastodonAPIClient,
         contentDatabase: ContentDatabase,
         useFiltersV2: Bool = false) {
        self.id = id
        self.mastodonAPIClient = mastodonAPIClient
        self.contentDatabase = contentDatabase
        sections = contentDatabase.contextPublisher(id: id, useFiltersV2: useFiltersV2)
        navigationService = NavigationService(environment: environment,
                                              mastodonAPIClient: mastodonAPIClient,
                                              contentDatabase: contentDatabase)
    }
}

extension ContextService: CollectionService {
    public func request(maxId: String?, minId: String?, search: Search?) -> AnyPublisher<Never, Error> {
        mastodonAPIClient.request(StatusEndpoint.status(id: id))
            .flatMap(contentDatabase.insert(status:))
            .merge(with: mastodonAPIClient.request(ContextEndpoint.context(id: id))
                    .flatMap { contentDatabase.insert(context: $0, parentId: id) })
            .eraseToAnyPublisher()
    }

    public func expand(ids: Set<Status.Id>) -> AnyPublisher<Never, Error> {
        contentDatabase.expand(ids: ids)
    }

    public func collapse(ids: Set<Status.Id>) -> AnyPublisher<Never, Error> {
        contentDatabase.collapse(ids: ids)
    }
}
