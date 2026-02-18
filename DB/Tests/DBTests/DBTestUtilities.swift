// Copyright © 2024 Metatext contributors. All rights reserved.

// swiftlint:disable force_try type_body_length function_body_length

import Combine
@testable import DB
import Mastodon
import MockKeychain
import XCTest

// MARK: - Database Factories

func makeContentDatabase(id: UUID = UUID()) throws -> ContentDatabase {
    try ContentDatabase(id: id,
                        useHomeTimelineLastReadId: false,
                        inMemory: true,
                        appGroup: "group.test",
                        keychain: MockKeychain.self)
}

func makeIdentityDatabase() throws -> IdentityDatabase {
    try IdentityDatabase(inMemory: true,
                         appGroup: "group.test",
                         keychain: MockKeychain.self)
}

// MARK: - Test Data Factories

enum TestData {
    static func makeAccount(id: String = "account1",
                            username: String = "user") -> Account {
        let decoder = MastodonDecoder()
        let json = Data("""
        {
            "id": "\(id)",
            "username": "\(username)",
            "acct": "\(username)@instance.test",
            "display_name": "\(username)",
            "locked": false,
            "created_at": "2020-01-01T00:00:00.000Z",
            "followers_count": 0,
            "following_count": 0,
            "statuses_count": 0,
            "note": "",
            "url": "https://instance.test/@\(username)",
            "avatar": "https://instance.test/avatar.png",
            "avatar_static": "https://instance.test/avatar.png",
            "header": "https://instance.test/header.png",
            "header_static": "https://instance.test/header.png",
            "fields": [],
            "emojis": [],
            "bot": false,
            "discoverable": false
        }
        """.utf8)
        return try! decoder.decode(Account.self, from: json)
    }

    static func makeStatus(id: String = "status1",
                           accountId: String = "account1",
                           content: String = "Hello, world!",
                           reblog: Status? = nil) -> Status {
        let account = makeAccount(id: accountId, username: "user\(accountId)")

        return Status(
            id: id,
            uri: "https://instance.test/statuses/\(id)",
            createdAt: Date(),
            account: account,
            content: makeHTML(content),
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
            url: "https://instance.test/statuses/\(id)",
            inReplyToId: nil,
            inReplyToAccountId: nil,
            reblog: reblog,
            poll: nil,
            card: nil,
            language: "en",
            text: nil,
            favourited: false,
            reblogged: false,
            muted: false,
            bookmarked: false,
            pinned: nil)
    }

    static func makeRelationship(id: String, following: Bool = false) -> Relationship {
        let decoder = MastodonDecoder()
        let json = Data("""
        {
            "id": "\(id)",
            "following": \(following),
            "requested": false,
            "endorsed": false,
            "followed_by": false,
            "muting": false,
            "muting_notifications": false,
            "showing_reblogs": true,
            "notifying": false,
            "blocking": false,
            "domain_blocking": false,
            "blocked_by": false,
            "note": ""
        }
        """.utf8)
        return try! decoder.decode(Relationship.self, from: json)
    }

    static func makeInstance(uri: String = "instance.test",
                             title: String = "Test Instance") -> Instance {
        let account = makeAccount(id: "admin1", username: "admin")

        return Instance(
            uri: uri,
            title: title,
            description: "A test instance",
            shortDescription: "Test",
            email: "admin@\(uri)",
            version: "3.4.0",
            urls: makeInstanceURLs(),
            stats: makeInstanceStats(),
            thumbnail: nil,
            contactAccount: account,
            maxTootChars: 500)
    }

    static func makeFilter(id: String = "filter1",
                           phrase: String = "filtered") -> Filter {
        let decoder = MastodonDecoder()
        let json = Data("""
        {
            "id": "\(id)",
            "phrase": "\(phrase)",
            "context": ["home", "public"],
            "expires_at": null,
            "irreversible": false,
            "whole_word": false
        }
        """.utf8)
        return try! decoder.decode(Filter.self, from: json)
    }

    static func makeEmoji(shortcode: String = "blobcat") -> Emoji {
        let decoder = MastodonDecoder()
        let json = Data("""
        {
            "shortcode": "\(shortcode)",
            "static_url": "https://instance.test/emoji/\(shortcode).png",
            "url": "https://instance.test/emoji/\(shortcode).gif",
            "visible_in_picker": true,
            "category": "Custom"
        }
        """.utf8)
        return try! decoder.decode(Emoji.self, from: json)
    }

    static func makeNotification(id: String = "notif1",
                                 type: MastodonNotification.NotificationType = .favourite,
                                 accountId: String = "account1",
                                 status: Status? = nil) -> MastodonNotification {
        let account = makeAccount(id: accountId, username: "notifier\(accountId)")
        return MastodonNotification(
            id: id,
            type: type,
            account: account,
            createdAt: Date(),
            status: status)
    }

    static func makeConversation(id: String = "conv1",
                                 accountIds: [String] = ["account1"],
                                 lastStatus: Status? = nil) -> Conversation {
        let accounts = accountIds.map { makeAccount(id: $0, username: "user\($0)") }
        return Conversation(
            id: id,
            accounts: accounts,
            unread: false,
            lastStatus: lastStatus)
    }

    static func makeAnnouncement(id: String = "announcement1") -> Announcement {
        let decoder = MastodonDecoder()
        let json = Data("""
        {
            "id": "\(id)",
            "content": "<p>Test announcement</p>",
            "starts_at": null,
            "ends_at": null,
            "all_day": false,
            "published_at": "2020-01-01T00:00:00.000Z",
            "updated_at": "2020-01-01T00:00:00.000Z",
            "read": false,
            "mentions": [],
            "tags": [],
            "emojis": [],
            "reactions": []
        }
        """.utf8)
        return try! decoder.decode(Announcement.self, from: json)
    }

    static func makeFilterV2(id: String = "filter1",
                              title: String = "Test Filter",
                              context: [Filter.Context] = [.home, .public],
                              expiresAt: Date? = nil,
                              filterAction: FilterV2.Action = .warn,
                              keywords: [FilterKeyword] = []) -> FilterV2 {
        FilterV2(id: id, title: title, context: context,
                 expiresAt: expiresAt, filterAction: filterAction,
                 keywords: keywords, statuses: [])
    }

    static func makeFilterKeyword(id: String = "kw1",
                                  keyword: String = "filtered",
                                  wholeWord: Bool = true) -> FilterKeyword {
        FilterKeyword(id: id, keyword: keyword, wholeWord: wholeWord)
    }

    static func makeFilterResult(filter: FilterV2,
                                 keywordMatches: [String]? = nil) -> FilterResult {
        FilterResult(filter: filter, keywordMatches: keywordMatches)
    }

    static func makeHTML(_ string: String = "") -> HTML {
        let decoder = MastodonDecoder()
        let jsonString = string.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let json = Data("\"\(jsonString)\"".utf8)
        return try! decoder.decode(HTML.self, from: json)
    }

    static func makeInstanceURLs() -> Instance.URLs {
        let decoder = MastodonDecoder()
        let json = Data("""
        {"streaming_api": "wss://instance.test"}
        """.utf8)
        return try! decoder.decode(Instance.URLs.self, from: json)
    }

    static func makeInstanceStats() -> Instance.Stats {
        let decoder = MastodonDecoder()
        let json = Data("""
        {"user_count": 100, "status_count": 1000, "domain_count": 50}
        """.utf8)
        return try! decoder.decode(Instance.Stats.self, from: json)
    }

    static func makeList(id: String = "list1", title: String = "Test List") -> List {
        let decoder = MastodonDecoder()
        let json = Data("""
        {"id": "\(id)", "title": "\(title)"}
        """.utf8)
        return try! decoder.decode(List.self, from: json)
    }

    static func makeContext(parentId: String,
                            ancestors: [Status] = [],
                            descendants: [Status] = []) -> Context {
        let decoder = MastodonDecoder()

        func statusJSON(_ s: Status) -> String {
            """
            {
                "id": "\(s.id)",
                "uri": "\(s.uri)",
                "created_at": "2020-01-01T00:00:00.000Z",
                "account": {
                    "id": "\(s.account.id)",
                    "username": "\(s.account.username)",
                    "acct": "\(s.account.acct)",
                    "display_name": "\(s.account.displayName)",
                    "locked": false,
                    "created_at": "2020-01-01T00:00:00.000Z",
                    "followers_count": 0,
                    "following_count": 0,
                    "statuses_count": 0,
                    "note": "",
                    "url": "\(s.account.url)",
                    "avatar": "https://instance.test/avatar.png",
                    "avatar_static": "https://instance.test/avatar.png",
                    "header": "https://instance.test/header.png",
                    "header_static": "https://instance.test/header.png",
                    "fields": [],
                    "emojis": []
                },
                "content": "",
                "visibility": "public",
                "sensitive": false,
                "spoiler_text": "",
                "media_attachments": [],
                "mentions": [],
                "tags": [],
                "emojis": [],
                "reblogs_count": 0,
                "favourites_count": 0,
                "replies_count": 0,
                "url": null,
                "in_reply_to_id": null,
                "in_reply_to_account_id": null,
                "reblog": null,
                "poll": null,
                "card": null,
                "language": null,
                "text": null
            }
            """
        }

        let ancestorsJSON = ancestors.map { statusJSON($0) }.joined(separator: ",")
        let descendantsJSON = descendants.map { statusJSON($0) }.joined(separator: ",")
        let json = Data("""
        {"ancestors": [\(ancestorsJSON)], "descendants": [\(descendantsJSON)]}
        """.utf8)
        return try! decoder.decode(Context.self, from: json)
    }
}

// MARK: - Combine Helpers

extension XCTestCase {
    func wait(for publisher: AnyPublisher<Never, Error>, timeout seconds: TimeInterval = 5) throws {
        let expectation = self.expectation(description: "Publisher completes")
        var receivedError: Error?

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            },
            receiveValue: { _ in })

        wait(for: [expectation], timeout: seconds)
        cancellable.cancel()

        if let error = receivedError {
            throw error
        }
    }

    func firstValue<T>(from publisher: AnyPublisher<T, Error>,
                       timeout seconds: TimeInterval = 5) throws -> T {
        let expectation = self.expectation(description: "Publisher emits value")
        var receivedValue: T?
        var receivedError: Error?

        let cancellable = publisher.first().sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                    expectation.fulfill()
                }
            },
            receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: seconds)
        cancellable.cancel()

        if let error = receivedError {
            throw error
        }

        return try XCTUnwrap(receivedValue)
    }
}
