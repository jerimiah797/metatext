// Copyright © 2024 Metatext contributors. All rights reserved.

import Foundation
import Mastodon

enum FilterEvaluation: Equatable {
    case hide
    case warn(title: String)
    case pass
}

enum FilterV2Evaluator {
    static func evaluate(serverAnnotations: [FilterResult],
                         content: String,
                         filterContext: Filter.Context?,
                         v2Filters: [FilterV2]) -> FilterEvaluation {
        if !serverAnnotations.isEmpty {
            if serverAnnotations.contains(where: { $0.filter.filterAction == .hide }) {
                return .hide
            }

            if let warning = serverAnnotations
                .first(where: { $0.filter.filterAction == .warn })?.filter.title {
                return .warn(title: warning)
            }
        } else if !v2Filters.isEmpty {
            for filter in v2Filters {
                guard let ctx = filterContext,
                      filter.context.contains(where: { $0 == ctx }) else { continue }
                if let exp = filter.expiresAt, exp < Date() { continue }
                if filterMatches(filter, content: content) {
                    if filter.filterAction == .hide { return .hide }
                    if filter.filterAction == .warn { return .warn(title: filter.title) }
                }
            }
        }

        return .pass
    }

    static func filterMatches(_ filter: FilterV2, content: String) -> Bool {
        guard !filter.keywords.isEmpty else { return false }

        let pattern = filter.keywords.map { kw in
            var expression = NSRegularExpression.escapedPattern(for: kw.keyword)

            if kw.wholeWord {
                if expression.range(of: #"^[\w]"#, options: .regularExpression) != nil {
                    expression = #"\b"#.appending(expression)
                }
                if expression.range(of: #"[\w]$"#, options: .regularExpression) != nil {
                    expression.append(#"\b"#)
                }
            }

            return expression
        }.joined(separator: "|")

        return content.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
