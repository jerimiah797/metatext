// Copyright © 2024 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum FiltersV2Endpoint {
    case filters
}

extension FiltersV2Endpoint: Endpoint {
    public typealias ResultType = [FilterV2]

    public var APIVersion: String { "v2" }

    public var context: [String] {
        defaultContext + ["filters"]
    }

    public var pathComponentsInContext: [String] {
        switch self {
        case .filters:
            return []
        }
    }

    public var method: HTTPMethod {
        .get
    }
}
