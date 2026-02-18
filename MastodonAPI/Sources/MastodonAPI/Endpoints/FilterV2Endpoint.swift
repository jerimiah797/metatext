// Copyright © 2024 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum FilterV2Endpoint {
    case create(title: String, context: [Filter.Context], filterAction: FilterV2.Action,
                expiresIn: Date?, keywords: [FilterKeyword])
    case update(id: FilterV2.Id, title: String, context: [Filter.Context],
                filterAction: FilterV2.Action, expiresIn: Date?,
                keywords: [FilterKeyword], deletedKeywordIds: [FilterKeyword.Id])
}

extension FilterV2Endpoint: Endpoint {
    public typealias ResultType = FilterV2

    public var APIVersion: String { "v2" }

    public var context: [String] {
        defaultContext + ["filters"]
    }

    public var pathComponentsInContext: [String] {
        switch self {
        case .create:
            return []
        case let .update(id, _, _, _, _, _, _):
            return [id]
        }
    }

    public var jsonBody: [String: Any]? {
        switch self {
        case let .create(title, context, filterAction, expiresIn, keywords):
            var body = params(title: title, context: context, filterAction: filterAction, expiresIn: expiresIn)
            body["keywords_attributes"] = keywords.map { keyword -> [String: Any] in
                ["keyword": keyword.keyword, "whole_word": keyword.wholeWord]
            }
            return body
        case let .update(_, title, context, filterAction, expiresIn, keywords, deletedKeywordIds):
            var body = params(title: title, context: context, filterAction: filterAction, expiresIn: expiresIn)
            var attrs = keywords.map { keyword -> [String: Any] in
                var attr: [String: Any] = ["keyword": keyword.keyword, "whole_word": keyword.wholeWord]
                if keyword.id != FilterKeyword.newKeywordId {
                    attr["id"] = keyword.id
                }
                return attr
            }
            for deletedId in deletedKeywordIds {
                attrs.append(["id": deletedId, "_destroy": true])
            }
            body["keywords_attributes"] = attrs
            return body
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

private extension FilterV2Endpoint {
    func params(title: String, context: [Filter.Context],
                filterAction: FilterV2.Action, expiresIn: Date?) -> [String: Any] {
        var params: [String: Any] = [
            "title": title,
            "context": context.map(\.rawValue),
            "filter_action": filterAction.rawValue]

        if let expiresIn = expiresIn {
            params["expires_in"] = Int(expiresIn.timeIntervalSinceNow)
        }

        return params
    }
}
