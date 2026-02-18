// Copyright © 2024 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum FilterKeywordEndpoint {
    case create(filterId: FilterV2.Id, keyword: String, wholeWord: Bool)
    case update(id: FilterKeyword.Id, keyword: String, wholeWord: Bool)
}

extension FilterKeywordEndpoint: Endpoint {
    public typealias ResultType = FilterKeyword

    public var APIVersion: String { "v2" }

    public var context: [String] {
        switch self {
        case let .create(filterId, _, _):
            return defaultContext + ["filters", filterId, "keywords"]
        case .update:
            return defaultContext + ["filter_keywords"]
        }
    }

    public var pathComponentsInContext: [String] {
        switch self {
        case .create:
            return []
        case let .update(id, _, _):
            return [id]
        }
    }

    public var jsonBody: [String: Any]? {
        switch self {
        case let .create(_, keyword, wholeWord):
            return ["keyword": keyword, "whole_word": wholeWord]
        case let .update(_, keyword, wholeWord):
            return ["keyword": keyword, "whole_word": wholeWord]
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        }
    }
}
