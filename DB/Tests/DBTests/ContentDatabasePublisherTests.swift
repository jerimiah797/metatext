// Copyright © 2024 Metatext contributors. All rights reserved.

import Combine
@testable import DB
import Mastodon
import MockKeychain
import XCTest

final class ContentDatabasePublisherTests: XCTestCase {
    var db: ContentDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        db = try makeContentDatabase()
    }

    // MARK: - Timeline Publisher

    func testTimelinePublisherEmitsOnInsert() throws {
        let statuses = (1...3).map { TestData.makeStatus(id: "tp\($0)", accountId: "tpa\($0)") }
        try wait(for: db.insert(statuses: statuses, timeline: .home))

        let sections = try firstValue(from: db.timelinePublisher(.home))
        XCTAssertFalse(sections.flatMap(\.items).isEmpty)
    }

    // MARK: - Profile Publisher

    func testProfilePublisher() throws {
        let status = TestData.makeStatus(id: "pp_s1", accountId: "pp_a1")
        try wait(for: db.insert(status: status))

        let profile = try firstValue(from: db.profilePublisher(id: "pp_a1"))
        XCTAssertEqual(profile.account.id, "pp_a1")
    }

    // MARK: - Relationship Publisher

    func testRelationshipPublisher() throws {
        let status = TestData.makeStatus(id: "rp_s1", accountId: "rp_a1")
        try wait(for: db.insert(status: status))

        let relationship = TestData.makeRelationship(id: "rp_a1", following: true)
        try wait(for: db.insert(relationships: [relationship]))

        let fetched = try firstValue(from: db.relationshipPublisher(id: "rp_a1"))
        XCTAssertTrue(fetched.following)
    }

    // MARK: - Lists Publisher

    func testListsPublisher() throws {
        let list1 = TestData.makeList(id: "l1", title: "Alpha")
        let list2 = TestData.makeList(id: "l2", title: "Beta")
        try wait(for: db.setLists([list1, list2]))

        let lists = try firstValue(from: db.listsPublisher())
        XCTAssertEqual(lists.count, 2)
        // Should be ordered by title
        XCTAssertEqual(lists[0].id, "list-l1")
        XCTAssertEqual(lists[1].id, "list-l2")
    }

    // MARK: - Picker Emojis Publisher

    func testPickerEmojisPublisher() throws {
        let emoji1 = TestData.makeEmoji(shortcode: "aardvark")
        let emoji2 = TestData.makeEmoji(shortcode: "zebra")
        try wait(for: db.update(emojis: [emoji1, emoji2]))

        let emojis = try firstValue(from: db.pickerEmojisPublisher())
        XCTAssertEqual(emojis.count, 2)
        // Should be ordered by shortcode
        XCTAssertEqual(emojis[0].shortcode, "aardvark")
        XCTAssertEqual(emojis[1].shortcode, "zebra")
    }

    // MARK: - Instance Publisher

    func testInstancePublisher() throws {
        let instance = TestData.makeInstance(uri: "pub.test", title: "Publisher Test")
        try wait(for: db.insert(instance: instance))

        let fetched = try firstValue(from: db.instancePublisher(uri: "pub.test"))
        XCTAssertEqual(fetched.title, "Publisher Test")
        XCTAssertEqual(fetched.uri, "pub.test")
    }

    // MARK: - Notifications Publisher

    func testNotificationsPublisher() throws {
        let status = TestData.makeStatus(id: "np_s1", accountId: "np_a1")
        let notification = TestData.makeNotification(
            id: "np_n1",
            type: .favourite,
            accountId: "np_a1",
            status: status)
        try wait(for: db.insert(notifications: [notification]))

        let sections = try firstValue(
            from: db.notificationsPublisher(excludeTypes: []))
        let items = sections.flatMap(\.items)
        XCTAssertEqual(items.count, 1)
    }

    // MARK: - Active Filters Publisher

    func testActiveFiltersPublisher() throws {
        let filter = TestData.makeFilter(id: "afp1", phrase: "test_filter")
        try wait(for: db.setFilters([filter]))

        let filters = try firstValue(from: db.activeFiltersPublisher)
        XCTAssertEqual(filters.count, 1)
        XCTAssertEqual(filters.first?.phrase, "test_filter")
    }
}
