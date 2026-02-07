// Copyright © 2024 Metatext contributors. All rights reserved.

import Combine
@testable import DB
import Mastodon
import MockKeychain
import XCTest

final class ContentDatabaseWriteReadTests: XCTestCase {
    var db: ContentDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        db = try makeContentDatabase()
    }

    // MARK: - Status Insert

    func testInsertStatusSavesAccountAndStatus() throws {
        let status = TestData.makeStatus(id: "s1", accountId: "a1")
        try wait(for: db.insert(status: status))

        let profile = try firstValue(from: db.profilePublisher(id: "a1"))
        XCTAssertEqual(profile.account.id, "a1")
    }

    func testInsertStatusWithReblog() throws {
        let original = TestData.makeStatus(id: "original1", accountId: "author1")
        let reblog = TestData.makeStatus(id: "reblog1", accountId: "reblogger1", reblog: original)
        try wait(for: db.insert(status: reblog))

        // Both the reblogger and original author accounts should be saved
        let rebloggerProfile = try firstValue(from: db.profilePublisher(id: "reblogger1"))
        XCTAssertEqual(rebloggerProfile.account.id, "reblogger1")

        let authorProfile = try firstValue(from: db.profilePublisher(id: "author1"))
        XCTAssertEqual(authorProfile.account.id, "author1")
    }

    // MARK: - Timeline Insert

    func testInsertStatusesIntoTimeline() throws {
        let statuses = (1...3).map { TestData.makeStatus(id: "ts\($0)", accountId: "ta\($0)") }
        try wait(for: db.insert(statuses: statuses, timeline: .home))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let items = sections.flatMap(\.items)
        XCTAssertEqual(items.count, 3)
    }

    // MARK: - Relationships

    func testInsertRelationships() throws {
        let account = TestData.makeAccount(id: "rel_account")
        let status = TestData.makeStatus(id: "rel_status", accountId: "rel_account")
        try wait(for: db.insert(status: status))

        let relationship = TestData.makeRelationship(id: account.id, following: true)
        try wait(for: db.insert(relationships: [relationship]))

        let fetched = try firstValue(from: db.relationshipPublisher(id: account.id))
        XCTAssertTrue(fetched.following)
    }

    // MARK: - Instance

    func testInsertInstance() throws {
        let instance = TestData.makeInstance(uri: "test.instance", title: "Test")
        try wait(for: db.insert(instance: instance))

        let fetched = try firstValue(from: db.instancePublisher(uri: "test.instance"))
        XCTAssertEqual(fetched.title, "Test")
        XCTAssertEqual(fetched.uri, "test.instance")
    }

    // MARK: - Delete

    func testDeleteStatus() throws {
        let status = TestData.makeStatus(id: "del1", accountId: "del_account")
        try wait(for: db.insert(statuses: [status], timeline: .home))
        try wait(for: db.delete(id: "del1"))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let statusItems = sections.flatMap(\.items).filter {
            if case .status = $0 { return true }
            return false
        }
        XCTAssertTrue(statusItems.isEmpty)
    }

    // MARK: - Mute & Block

    func testMuteRemovesStatusesAndNotifications() throws {
        let status = TestData.makeStatus(id: "mute_s1", accountId: "mute_a1")
        try wait(for: db.insert(statuses: [status], timeline: .home))

        let notification = TestData.makeNotification(
            id: "mute_n1",
            type: .favourite,
            accountId: "mute_a1",
            status: status)
        try wait(for: db.insert(notifications: [notification]))

        try wait(for: db.mute(id: "mute_a1"))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let statusItems = sections.flatMap(\.items).filter {
            if case .status = $0 { return true }
            return false
        }
        XCTAssertTrue(statusItems.isEmpty)
    }

    func testBlockRemovesAccount() throws {
        let status = TestData.makeStatus(id: "block_s1", accountId: "block_a1")
        try wait(for: db.insert(statuses: [status], timeline: .home))

        try wait(for: db.block(id: "block_a1"))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        let statusItems = sections.flatMap(\.items).filter {
            if case .status = $0 { return true }
            return false
        }
        XCTAssertTrue(statusItems.isEmpty)
    }

    // MARK: - Toggle Show Content

    func testToggleShowContent() throws {
        let status = TestData.makeStatus(id: "toggle1", accountId: "toggle_a1")
        try wait(for: db.insert(status: status))

        // Toggle on
        try wait(for: db.toggleShowContent(id: "toggle1"))

        // Toggle off
        try wait(for: db.toggleShowContent(id: "toggle1"))
    }

    // MARK: - Context

    func testInsertContext() throws {
        let parent = TestData.makeStatus(id: "ctx_parent", accountId: "ctx_account")
        try wait(for: db.insert(status: parent))

        let ancestor = TestData.makeStatus(id: "ctx_anc", accountId: "ctx_account")
        let descendant = TestData.makeStatus(id: "ctx_desc", accountId: "ctx_account")
        let context = TestData.makeContext(
            parentId: parent.id,
            ancestors: [ancestor],
            descendants: [descendant])
        try wait(for: db.insert(context: context, parentId: parent.id))

        let sections = try firstValue(from: db.contextPublisher(id: parent.id))
        // Context returns 3 sections: ancestors, parent, descendants
        XCTAssertEqual(sections.count, 3)
    }

    // MARK: - Pinned Statuses

    func testInsertPinnedStatuses() throws {
        let account = TestData.makeAccount(id: "pin_account")
        let status1 = TestData.makeStatus(id: "pin_s1", accountId: "pin_account")
        let status2 = TestData.makeStatus(id: "pin_s2", accountId: "pin_account")
        try wait(for: db.insert(status: status1))
        try wait(for: db.insert(status: status2))

        try wait(for: db.insert(pinnedStatuses: [status1, status2], accountId: account.id))
    }

    // MARK: - Filters

    func testSetFilters() throws {
        let filter1 = TestData.makeFilter(id: "f1", phrase: "spam")
        let filter2 = TestData.makeFilter(id: "f2", phrase: "ads")
        try wait(for: db.setFilters([filter1, filter2]))

        // Replace with only one filter
        let filter3 = TestData.makeFilter(id: "f3", phrase: "noise")
        try wait(for: db.setFilters([filter3]))
    }

    // MARK: - Emojis

    func testUpdateEmojis() throws {
        let emoji1 = TestData.makeEmoji(shortcode: "cat")
        let emoji2 = TestData.makeEmoji(shortcode: "dog")
        try wait(for: db.update(emojis: [emoji1, emoji2]))

        // Replace with different set
        let emoji3 = TestData.makeEmoji(shortcode: "bird")
        try wait(for: db.update(emojis: [emoji3]))

        let emojis = try firstValue(from: db.pickerEmojisPublisher())
        XCTAssertEqual(emojis.count, 1)
        XCTAssertEqual(emojis.first?.shortcode, "bird")
    }
}
