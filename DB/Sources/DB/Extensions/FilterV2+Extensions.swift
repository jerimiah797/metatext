// Copyright © 2024 Metabolist. All rights reserved.

import Foundation
import GRDB
import Mastodon

struct FilterV2Record: ContentDatabaseRecord, Hashable {
    let id: FilterV2.Id
    let title: String
    let context: [Filter.Context]
    let expiresAt: Date?
    let filterAction: FilterV2.Action
}

extension FilterV2Record {
    enum Columns: String, ColumnExpression {
        case id
        case title
        case context
        case expiresAt
        case filterAction
    }

    static let keywords = hasMany(FilterKeywordRecord.self, using: ForeignKey(["filterId"]))

    init(filter: FilterV2) {
        id = filter.id
        title = filter.title
        context = filter.context
        expiresAt = filter.expiresAt
        filterAction = filter.filterAction
    }
}

struct FilterKeywordRecord: ContentDatabaseRecord, Hashable {
    let id: FilterKeyword.Id
    let filterId: FilterV2.Id
    let keyword: String
    let wholeWord: Bool
}

extension FilterKeywordRecord {
    enum Columns: String, ColumnExpression {
        case id
        case filterId
        case keyword
        case wholeWord
    }

    init(keyword: FilterKeyword, filterId: FilterV2.Id) {
        self.id = keyword.id
        self.filterId = filterId
        self.keyword = keyword.keyword
        self.wholeWord = keyword.wholeWord
    }
}

struct FilterV2Info: Codable, Hashable, FetchableRecord {
    let record: FilterV2Record
    let keywords: [FilterKeywordRecord]
}

extension FilterV2Info {
    static func request(_ request: QueryInterfaceRequest<FilterV2Record>) -> QueryInterfaceRequest<Self> {
        request
            .including(all: FilterV2Record.keywords.forKey(CodingKeys.keywords))
            .asRequest(of: self)
    }

    func toFilterV2() -> FilterV2 {
        FilterV2(
            id: record.id,
            title: record.title,
            context: record.context,
            expiresAt: record.expiresAt,
            filterAction: record.filterAction,
            keywords: keywords.map { FilterKeyword(id: $0.id, keyword: $0.keyword, wholeWord: $0.wholeWord) },
            statuses: [])
    }
}
