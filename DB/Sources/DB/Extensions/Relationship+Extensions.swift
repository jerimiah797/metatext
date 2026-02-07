// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import GRDB
import Mastodon

extension Relationship: ContentDatabaseRecord {}

extension Relationship {
    public enum Columns: String, ColumnExpression {
        case id
        case following
        case requested
        case endorsed
        case followedBy
        case muting
        case mutingNotifications
        case showingReblogs
        case blocking
        case domainBlocking
        case blockedBy
        case note
    }
}
