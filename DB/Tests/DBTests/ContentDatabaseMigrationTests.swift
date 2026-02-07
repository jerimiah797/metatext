// Copyright © 2024 Metatext contributors. All rights reserved.

import Combine
@testable import DB
import Mastodon
import MockKeychain
import XCTest

final class ContentDatabaseMigrationTests: XCTestCase {
    func testCreationSucceeds() throws {
        _ = try makeContentDatabase()
    }

    func testCreationIsIdempotent() throws {
        _ = try makeContentDatabase(id: UUID())
        _ = try makeContentDatabase(id: UUID())
    }

    func testCanInsertAndReadAllRecordTypes() throws {
        let db = try makeContentDatabase()

        // Account & Status
        let status = TestData.makeStatus()
        try wait(for: db.insert(status: status))

        // Relationship
        let relationship = TestData.makeRelationship(id: status.account.id, following: true)
        try wait(for: db.insert(relationships: [relationship]))

        // Timeline
        try wait(for: db.insert(statuses: [status], timeline: .home))

        // Filter
        let filter = TestData.makeFilter()
        try wait(for: db.setFilters([filter]))

        // Emoji
        let emoji = TestData.makeEmoji()
        try wait(for: db.update(emojis: [emoji]))

        // Notification
        let notification = TestData.makeNotification(
            accountId: "notif_account",
            status: status)
        try wait(for: db.insert(notifications: [notification]))

        // Conversation
        let convStatus = TestData.makeStatus(id: "conv_status1", accountId: "conv_account1")
        let conversation = TestData.makeConversation(
            accountIds: ["conv_account1"],
            lastStatus: convStatus)
        try wait(for: db.insert(conversations: [conversation]))

        // Instance
        let instance = TestData.makeInstance()
        try wait(for: db.insert(instance: instance))

        // Announcement
        let announcement = TestData.makeAnnouncement()
        try wait(for: db.update(announcements: [announcement]))

        // Context (ancestors/descendants)
        let ancestor = TestData.makeStatus(id: "ancestor1", accountId: "account1")
        let descendant = TestData.makeStatus(id: "descendant1", accountId: "account1")
        let context = TestData.makeContext(
            parentId: status.id,
            ancestors: [ancestor],
            descendants: [descendant])
        try wait(for: db.insert(context: context, parentId: status.id))

        // Pinned statuses
        let pinnedStatus = TestData.makeStatus(id: "pinned1", accountId: "account1")
        try wait(for: db.insert(pinnedStatuses: [pinnedStatus], accountId: "account1"))
    }
}
