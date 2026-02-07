// Copyright © 2024 Metatext contributors. All rights reserved.

// swiftlint:disable function_body_length

import Combine
@testable import DB
import GRDB
import Mastodon
import MockKeychain
import XCTest

final class ContentDatabaseAssociationTests: XCTestCase {
    var db: ContentDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        db = try makeContentDatabase()
    }

    // MARK: - StatusInfo Associations

    func testStatusInfoIncludesAccount() throws {
        let status = TestData.makeStatus(id: "assoc_s1", accountId: "assoc_a1")
        try wait(for: db.insert(statuses: [status], timeline: .home))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let items = sections.flatMap(\.items)
        guard case let .status(statusEntity, _, _) = items.first else {
            return XCTFail("Expected status item")
        }
        XCTAssertEqual(statusEntity.account.id, "assoc_a1")
    }

    func testStatusInfoIncludesReblogChain() throws {
        let original = TestData.makeStatus(id: "orig1", accountId: "orig_author")
        let reblog = TestData.makeStatus(id: "reb1", accountId: "reblogger", reblog: original)
        try wait(for: db.insert(statuses: [reblog], timeline: .home))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let items = sections.flatMap(\.items)
        guard case let .status(statusEntity, _, _) = items.first else {
            return XCTFail("Expected status item")
        }
        XCTAssertNotNil(statusEntity.reblog)
        XCTAssertEqual(statusEntity.reblog?.account.id, "orig_author")
    }

    func testStatusInfoIncludesRelationship() throws {
        let status = TestData.makeStatus(id: "rel_s1", accountId: "rel_a1")
        try wait(for: db.insert(statuses: [status], timeline: .home))

        let relationship = TestData.makeRelationship(id: "rel_a1", following: true)
        try wait(for: db.insert(relationships: [relationship]))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let items = sections.flatMap(\.items)
        guard case let .status(_, _, rel) = items.first else {
            return XCTFail("Expected status item")
        }
        XCTAssertEqual(rel?.following, true)
    }

    func testStatusInfoIncludesShowContentToggle() throws {
        let status = TestData.makeStatus(id: "sct1", accountId: "sct_a1")
        try wait(for: db.insert(statuses: [status], timeline: .home))
        try wait(for: db.toggleShowContent(id: "sct1"))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let items = sections.flatMap(\.items)
        guard case let .status(_, config, _) = items.first else {
            return XCTFail("Expected status item")
        }
        XCTAssertTrue(config.showContentToggled)
    }

    // MARK: - AccountInfo Associations

    func testAccountInfoIncludesMovedRecord() throws {
        let decoder = MastodonDecoder()
        let json = Data("""
        {
            "id": "moved_from",
            "username": "old_user",
            "acct": "old_user@instance.test",
            "display_name": "Old User",
            "locked": false,
            "created_at": "2020-01-01T00:00:00.000Z",
            "followers_count": 0,
            "following_count": 0,
            "statuses_count": 0,
            "note": "",
            "url": "https://instance.test/@old_user",
            "avatar": "https://instance.test/avatar.png",
            "avatar_static": "https://instance.test/avatar.png",
            "header": "https://instance.test/header.png",
            "header_static": "https://instance.test/header.png",
            "fields": [],
            "emojis": [],
            "moved": {
                "id": "moved_to",
                "username": "new_user",
                "acct": "new_user@other.test",
                "display_name": "New User",
                "locked": false,
                "created_at": "2020-01-01T00:00:00.000Z",
                "followers_count": 0,
                "following_count": 0,
                "statuses_count": 0,
                "note": "",
                "url": "https://other.test/@new_user",
                "avatar": "https://other.test/avatar.png",
                "avatar_static": "https://other.test/avatar.png",
                "header": "https://other.test/header.png",
                "header_static": "https://other.test/header.png",
                "fields": [],
                "emojis": []
            }
        }
        """.utf8)
        let account = try decoder.decode(Account.self, from: json)

        let status = Status(
            id: "moved_s1",
            uri: "https://instance.test/statuses/moved_s1",
            createdAt: Date(),
            account: account,
            content: TestData.makeHTML("test"),
            visibility: .public,
            sensitive: false,
            spoilerText: "",
            mediaAttachments: [],
            mentions: [],
            tags: [],
            emojis: [],
            reblogsCount: 0,
            favouritesCount: 0,
            repliesCount: 0,
            application: nil,
            url: nil,
            inReplyToId: nil,
            inReplyToAccountId: nil,
            reblog: nil,
            poll: nil,
            card: nil,
            language: nil,
            text: nil,
            favourited: false,
            reblogged: false,
            muted: false,
            bookmarked: false,
            pinned: nil)
        try wait(for: db.insert(status: status))

        let profile = try firstValue(from: db.profilePublisher(id: "moved_from"))
        XCTAssertNotNil(profile.account.moved)
        XCTAssertEqual(profile.account.moved?.id, "moved_to")
    }

    // MARK: - TimelineItemsInfo Associations

    func testTimelineItemsInfoIncludesStatuses() throws {
        let statuses = (1...5).map { TestData.makeStatus(id: "ti\($0)", accountId: "tia\($0)") }
        try wait(for: db.insert(statuses: statuses, timeline: .home))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let items = sections.flatMap(\.items)
        XCTAssertEqual(items.count, 5)
    }

    // MARK: - ProfileInfo Associations

    func testProfileInfoIncludesAllAssociations() throws {
        let status = TestData.makeStatus(id: "prof_s1", accountId: "prof_a1")
        try wait(for: db.insert(status: status))

        let relationship = TestData.makeRelationship(id: "prof_a1", following: true)
        try wait(for: db.insert(relationships: [relationship]))

        let profile = try firstValue(from: db.profilePublisher(id: "prof_a1"))
        XCTAssertEqual(profile.account.id, "prof_a1")
        XCTAssertEqual(profile.relationship?.following, true)
    }

    // MARK: - NotificationInfo Associations

    func testNotificationInfoIncludesAccountAndStatus() throws {
        let status = TestData.makeStatus(id: "notif_s1", accountId: "notif_a1")
        let notification = TestData.makeNotification(
            id: "notif1",
            type: .mention,
            accountId: "notif_a1",
            status: status)
        try wait(for: db.insert(notifications: [notification]))

        let sections = try firstValue(
            from: db.notificationsPublisher(excludeTypes: []))
        let items = sections.flatMap(\.items)
        guard case let .notification(notif, config) = items.first else {
            return XCTFail("Expected notification item")
        }
        XCTAssertEqual(notif.account.id, "notif_a1")
        XCTAssertNotNil(notif.status)
        XCTAssertNotNil(config) // mention type includes status config
    }

    // MARK: - ContextItemsInfo Associations

    func testContextItemsInfoIncludesAncestorsAndDescendants() throws {
        let parent = TestData.makeStatus(id: "ctx_p1", accountId: "ctx_a1")
        try wait(for: db.insert(status: parent))

        let ancestor1 = TestData.makeStatus(id: "ctx_anc1", accountId: "ctx_a1")
        let ancestor2 = TestData.makeStatus(id: "ctx_anc2", accountId: "ctx_a1")
        let descendant1 = TestData.makeStatus(id: "ctx_desc1", accountId: "ctx_a1")

        let context = TestData.makeContext(
            parentId: parent.id,
            ancestors: [ancestor1, ancestor2],
            descendants: [descendant1])
        try wait(for: db.insert(context: context, parentId: parent.id))

        let sections = try firstValue(from: db.contextPublisher(id: parent.id))
        XCTAssertEqual(sections.count, 3) // ancestors, parent, descendants

        // Ancestors section
        let ancestorItems = sections[0].items
        XCTAssertEqual(ancestorItems.count, 2)

        // Parent section
        let parentItems = sections[1].items
        XCTAssertEqual(parentItems.count, 1)

        // Descendants section
        let descendantItems = sections[2].items
        XCTAssertEqual(descendantItems.count, 1)
    }

    // MARK: - Cascade Deletion

    func testCascadeDeletionAccountToStatuses() throws {
        let status = TestData.makeStatus(id: "cascade_s1", accountId: "cascade_a1")
        try wait(for: db.insert(statuses: [status], timeline: .home))

        // Blocking deletes the account record, which cascades to statuses
        try wait(for: db.block(id: "cascade_a1"))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let statusItems = sections.flatMap(\.items).filter {
            if case .status = $0 { return true }
            return false
        }
        XCTAssertTrue(statusItems.isEmpty)
    }
}
