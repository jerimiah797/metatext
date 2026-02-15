// Copyright © 2024 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

public struct StatusSource: Decodable {
    public let id: Status.Id
    public let text: String
    public let spoilerText: String
}

public enum StatusSourceEndpoint {
    case source(id: Status.Id)
}

extension StatusSourceEndpoint: Endpoint {
    public typealias ResultType = StatusSource

    public var context: [String] {
        defaultContext + ["statuses"]
    }

    public var pathComponentsInContext: [String] {
        switch self {
        case let .source(id):
            return [id, "source"]
        }
    }

    public var method: HTTPMethod {
        .get
    }
}
