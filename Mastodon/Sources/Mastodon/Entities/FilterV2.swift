// Copyright © 2024 Metabolist. All rights reserved.

import Foundation

public struct FilterV2: Codable, Hashable, Identifiable {
    public enum Action: String, Codable, Unknowable {
        case warn
        case hide
        case unknown

        public static var unknownCase: Self { .unknown }
    }

    public let id: Id
    public var title: String
    public var context: [Filter.Context]
    public var expiresAt: Date?
    public var filterAction: Action
    @DecodableDefault.EmptyList public private(set) var keywords: [FilterKeyword]
    @DecodableDefault.EmptyList public private(set) var statuses: [FilterStatus]
}

public extension FilterV2 {
    typealias Id = String

    static let newFilterId: Id = "com.metabolist.metatext.new-filter-v2-id"
    static let new = Self(id: newFilterId,
                          title: "",
                          context: [],
                          expiresAt: nil,
                          filterAction: .warn,
                          keywords: [],
                          statuses: [])

    init(id: Id, title: String, context: [Filter.Context],
         expiresAt: Date?, filterAction: Action,
         keywords: [FilterKeyword], statuses: [FilterStatus]) {
        self.id = id
        self.title = title
        self.context = context
        self.expiresAt = expiresAt
        self.filterAction = filterAction
        self.keywords = keywords
        self.statuses = statuses
    }
}

public struct FilterKeyword: Codable, Hashable, Identifiable {
    public let id: Id
    public var keyword: String
    public var wholeWord: Bool

    public init(id: Id, keyword: String, wholeWord: Bool) {
        self.id = id
        self.keyword = keyword
        self.wholeWord = wholeWord
    }
}

public extension FilterKeyword {
    typealias Id = String

    static let newKeywordId: Id = "com.metabolist.metatext.new-filter-keyword-id"
    static let new = Self(id: newKeywordId, keyword: "", wholeWord: true)
}

public struct FilterStatus: Codable, Hashable, Identifiable {
    public let id: Id
    public var statusId: Status.Id
}

public extension FilterStatus {
    typealias Id = String
}

public struct FilterResult: Codable, Hashable {
    public let filter: FilterV2
    public let keywordMatches: [String]?
    public let statusMatches: [String]?

    public init(filter: FilterV2, keywordMatches: [String]? = nil, statusMatches: [String]? = nil) {
        self.filter = filter
        self.keywordMatches = keywordMatches
        self.statusMatches = statusMatches
    }
}
