// Copyright © 2024 Metatext contributors. All rights reserved.

import Combine
@testable import DB
import Mastodon
import MockKeychain
import XCTest

final class IdentityDatabaseTests: XCTestCase {
    var db: IdentityDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        db = try makeIdentityDatabase()
    }

    // MARK: - Migration Tests

    func testCreationSucceeds() throws {
        _ = try makeIdentityDatabase()
    }

    func testCanInsertAndReadIdentity() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let identity = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertEqual(identity.id, id)
        XCTAssertTrue(identity.authenticated)
        XCTAssertFalse(identity.pending)
    }

    // MARK: - Write/Read Tests

    func testCreateIdentity() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let identity = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertEqual(identity.id, id)
        XCTAssertEqual(identity.url.absoluteString, "https://instance.test")
    }

    func testDeleteIdentity() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        try wait(for: db.deleteIdentity(id: id))

        // After deletion, the publisher should error
        let expectation = self.expectation(description: "Identity not found")
        var receivedError: Error?

        let cancellable = db.identityPublisher(id: id, immediate: true)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedError = error
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in })

        wait(for: [expectation], timeout: 5)
        cancellable.cancel()

        XCTAssertTrue(receivedError is IdentityDatabaseError)
    }

    func testUpdateLastUsedAt() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let before = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        let beforeDate = before.lastUsedAt

        // Small delay to ensure different timestamp
        Thread.sleep(forTimeInterval: 0.1)

        try wait(for: db.updateLastUsedAt(id: id))

        let after = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertGreaterThan(after.lastUsedAt, beforeDate)
    }

    func testUpdateInstance() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let instance = TestData.makeInstance(uri: "instance.test", title: "Updated Instance")
        try wait(for: db.updateInstance(instance, id: id))

        let identity = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertEqual(identity.instance?.title, "Updated Instance")
        XCTAssertEqual(identity.instance?.uri, "instance.test")
    }

    func testUpdateAccount() throws {
        let identityId = UUID()
        try wait(for: db.createIdentity(
            id: identityId,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let account = TestData.makeAccount(id: "identity_account", username: "testuser")
        try wait(for: db.updateAccount(account, id: identityId))

        let identity = try firstValue(from: db.identityPublisher(id: identityId, immediate: true))
        XCTAssertEqual(identity.account?.username, "testuser")
    }

    func testConfirmIdentity() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: true))

        let before = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertTrue(before.pending)

        try wait(for: db.confirmIdentity(id: id))

        let after = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertFalse(after.pending)
    }

    // MARK: - Publisher Tests

    func testIdentityPublisher() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let identity = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertEqual(identity.id, id)
    }

    func testIdentitiesPublisherOrderedByLastUsed() throws {
        let id1 = UUID()
        let id2 = UUID()

        try wait(for: db.createIdentity(
            id: id1,
            url: URL(string: "https://instance1.test")!,
            authenticated: true,
            pending: false))

        // Small delay so timestamps differ
        Thread.sleep(forTimeInterval: 0.1)

        try wait(for: db.createIdentity(
            id: id2,
            url: URL(string: "https://instance2.test")!,
            authenticated: true,
            pending: false))

        let identities = try firstValue(from: db.identitiesPublisher())
        XCTAssertEqual(identities.count, 2)
        // Most recently used first
        XCTAssertEqual(identities[0].id, id2)
        XCTAssertEqual(identities[1].id, id1)
    }

    func testIdentityPublisherUpdatesOnAccountChange() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let before = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertNil(before.account)

        let account = TestData.makeAccount(id: "update_account", username: "updated_user")
        try wait(for: db.updateAccount(account, id: id))

        let after = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertNotNil(after.account)
        XCTAssertEqual(after.account?.username, "updated_user")
    }

    // MARK: - Association Tests

    func testIdentityInfoIncludesInstanceAndAccount() throws {
        let id = UUID()
        try wait(for: db.createIdentity(
            id: id,
            url: URL(string: "https://instance.test")!,
            authenticated: true,
            pending: false))

        let instance = TestData.makeInstance(uri: "instance.test", title: "Assoc Instance")
        try wait(for: db.updateInstance(instance, id: id))

        let account = TestData.makeAccount(id: "assoc_account", username: "assoc_user")
        try wait(for: db.updateAccount(account, id: id))

        let identity = try firstValue(from: db.identityPublisher(id: id, immediate: true))
        XCTAssertNotNil(identity.instance)
        XCTAssertEqual(identity.instance?.title, "Assoc Instance")
        XCTAssertNotNil(identity.account)
        XCTAssertEqual(identity.account?.username, "assoc_user")
    }
}
