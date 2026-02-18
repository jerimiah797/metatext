// Copyright © 2024 Metatext contributors. All rights reserved.

@testable import DB
import Mastodon
import XCTest

final class FilterV2EvaluationTests: XCTestCase {

    // MARK: - evaluate() tests

    func testServerSideHideReturnsHide() {
        let filter = TestData.makeFilterV2(filterAction: .hide)
        let annotations = [TestData.makeFilterResult(filter: filter)]

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: annotations, content: "", filterContext: .home, v2Filters: [])

        XCTAssertEqual(result, .hide)
    }

    func testServerSideWarnReturnsWarnWithTitle() {
        let filter = TestData.makeFilterV2(title: "Politics", filterAction: .warn)
        let annotations = [TestData.makeFilterResult(filter: filter)]

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: annotations, content: "", filterContext: .home, v2Filters: [])

        XCTAssertEqual(result, .warn(title: "Politics"))
    }

    func testServerSideHideTakesPrecedenceOverWarn() {
        let warnFilter = TestData.makeFilterV2(id: "f1", title: "Warn", filterAction: .warn)
        let hideFilter = TestData.makeFilterV2(id: "f2", title: "Hide", filterAction: .hide)
        let annotations = [
            TestData.makeFilterResult(filter: warnFilter),
            TestData.makeFilterResult(filter: hideFilter)
        ]

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: annotations, content: "", filterContext: .home, v2Filters: [])

        XCTAssertEqual(result, .hide)
    }

    func testEmptyAnnotationsNoFiltersReturnsPass() {
        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: [], content: "hello", filterContext: .home, v2Filters: [])

        XCTAssertEqual(result, .pass)
    }

    func testClientSideKeywordMatchHide() {
        let kw = TestData.makeFilterKeyword(keyword: "spoiler")
        let filter = TestData.makeFilterV2(context: [.home], filterAction: .hide, keywords: [kw])

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: [], content: "This is a spoiler post",
            filterContext: .home, v2Filters: [filter])

        XCTAssertEqual(result, .hide)
    }

    func testClientSideKeywordMatchWarn() {
        let kw = TestData.makeFilterKeyword(keyword: "spoiler")
        let filter = TestData.makeFilterV2(title: "Spoilers", context: [.home],
                                           filterAction: .warn, keywords: [kw])

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: [], content: "This is a spoiler post",
            filterContext: .home, v2Filters: [filter])

        XCTAssertEqual(result, .warn(title: "Spoilers"))
    }

    func testWrongFilterContextReturnsPass() {
        let kw = TestData.makeFilterKeyword(keyword: "spoiler")
        let filter = TestData.makeFilterV2(context: [.home], filterAction: .hide, keywords: [kw])

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: [], content: "This is a spoiler post",
            filterContext: .thread, v2Filters: [filter])

        XCTAssertEqual(result, .pass)
    }

    func testExpiredFilterReturnsPass() {
        let kw = TestData.makeFilterKeyword(keyword: "spoiler")
        let expired = Date().addingTimeInterval(-3600)
        let filter = TestData.makeFilterV2(context: [.home], expiresAt: expired,
                                           filterAction: .hide, keywords: [kw])

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: [], content: "This is a spoiler post",
            filterContext: .home, v2Filters: [filter])

        XCTAssertEqual(result, .pass)
    }

    func testNoKeywordMatchReturnsPass() {
        let kw = TestData.makeFilterKeyword(keyword: "spoiler")
        let filter = TestData.makeFilterV2(context: [.home], filterAction: .hide, keywords: [kw])

        let result = FilterV2Evaluator.evaluate(
            serverAnnotations: [], content: "This is a nice post",
            filterContext: .home, v2Filters: [filter])

        XCTAssertEqual(result, .pass)
    }

    // MARK: - filterMatches() tests

    func testBasicMatchCaseInsensitive() {
        let kw = TestData.makeFilterKeyword(keyword: "hello", wholeWord: false)
        let filter = TestData.makeFilterV2(keywords: [kw])

        XCTAssertTrue(FilterV2Evaluator.filterMatches(filter, content: "Say HELLO world"))
    }

    func testWholeWordBoundary() {
        let kw = TestData.makeFilterKeyword(keyword: "cat", wholeWord: true)
        let filter = TestData.makeFilterV2(keywords: [kw])

        XCTAssertFalse(FilterV2Evaluator.filterMatches(filter, content: "concatenate"))
        XCTAssertTrue(FilterV2Evaluator.filterMatches(filter, content: "I love my cat"))
    }

    func testNonWholeWordMatchesSubstring() {
        let kw = TestData.makeFilterKeyword(keyword: "cat", wholeWord: false)
        let filter = TestData.makeFilterV2(keywords: [kw])

        XCTAssertTrue(FilterV2Evaluator.filterMatches(filter, content: "concatenate"))
    }

    func testMultipleKeywordsOneMatches() {
        let kw1 = TestData.makeFilterKeyword(id: "kw1", keyword: "apple", wholeWord: false)
        let kw2 = TestData.makeFilterKeyword(id: "kw2", keyword: "banana", wholeWord: false)
        let filter = TestData.makeFilterV2(keywords: [kw1, kw2])

        XCTAssertTrue(FilterV2Evaluator.filterMatches(filter, content: "I like banana"))
        XCTAssertFalse(FilterV2Evaluator.filterMatches(filter, content: "I like grapes"))
    }

    func testEmptyKeywordsReturnsFalse() {
        let filter = TestData.makeFilterV2(keywords: [])

        XCTAssertFalse(FilterV2Evaluator.filterMatches(filter, content: "anything"))
    }

    func testRegexSpecialCharactersEscaped() {
        let kw = TestData.makeFilterKeyword(keyword: "test.com", wholeWord: false)
        let filter = TestData.makeFilterV2(keywords: [kw])

        XCTAssertTrue(FilterV2Evaluator.filterMatches(filter, content: "visit test.com"))
        XCTAssertFalse(FilterV2Evaluator.filterMatches(filter, content: "visit testXcom"))
    }
}
