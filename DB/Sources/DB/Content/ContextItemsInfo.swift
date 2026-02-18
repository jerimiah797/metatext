// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import GRDB
import Mastodon

struct ContextItemsInfo: Codable, Hashable, FetchableRecord {
    let parent: StatusInfo
    let ancestors: [StatusInfo]
    let descendants: [StatusInfo]
}

extension ContextItemsInfo {
    static func addingIncludes<T: DerivableRequest>(_ request: T) -> T where T.RowDecoder == StatusRecord {
        StatusInfo.addingIncludes(request)
            .including(all: StatusInfo.addingIncludes(StatusRecord.ancestors).forKey(CodingKeys.ancestors))
            .including(all: StatusInfo.addingIncludes(StatusRecord.descendants).forKey(CodingKeys.descendants))
    }

    static func request(_ request: QueryInterfaceRequest<StatusRecord>) -> QueryInterfaceRequest<Self> {
        addingIncludes(request).asRequest(of: self)
    }

    func items(filters: [Filter]) -> [CollectionSection] {
        items(useFiltersV2: false, v1Filters: filters, v2Filters: [])
    }

    func items(useFiltersV2: Bool, v1Filters: [Filter], v2Filters: [FilterV2] = []) -> [CollectionSection] {
        let regularExpression = useFiltersV2 ? nil : v1Filters.regularExpression(context: .thread)

        return [ancestors, [parent], descendants].map { section in
            section.filtered(regularExpression: regularExpression)
                .enumerated()
                .compactMap { index, statusInfo -> CollectionItem? in
                    let isContextParent = statusInfo.record.id == parent.record.id

                    var filterWarning: String?

                    if useFiltersV2 {
                        let status = Status(info: statusInfo)
                        let effectiveFiltered = status.filtered.isEmpty
                            ? status.displayStatus.filtered
                            : status.filtered

                        if !effectiveFiltered.isEmpty {
                            if effectiveFiltered.contains(where: { $0.filter.filterAction == .hide }) {
                                return nil
                            }

                            filterWarning = effectiveFiltered
                                .first(where: { $0.filter.filterAction == .warn })?.filter.title
                        } else if !v2Filters.isEmpty {
                            // Client-side fallback for cached statuses without server-side annotations
                            let content = statusInfo.filterableContent
                            for filter in v2Filters {
                                guard filter.context.contains(.thread) else { continue }
                                if let exp = filter.expiresAt, exp < Date() { continue }
                                if Self.filterMatches(filter, content: content) {
                                    if filter.filterAction == .hide { return nil }
                                    if filter.filterAction == .warn { filterWarning = filter.title; break }
                                }
                            }
                        }
                    }

                    let isReplyInContext: Bool

                    if isContextParent {
                        isReplyInContext = !ancestors.isEmpty
                            && statusInfo.record.inReplyToId == ancestors.last?.record.id
                    } else {
                        isReplyInContext = index > 0
                            && section[index - 1].record.id == statusInfo.record.inReplyToId
                    }

                    let hasReplyFollowing = (section.count > index + 1
                                                && section[index + 1].record.inReplyToId == statusInfo.record.id)
                        || (statusInfo == ancestors.last && parent.record.inReplyToId == statusInfo.record.id)

                    return .status(
                        .init(info: statusInfo),
                        .init(showContentToggled: statusInfo.showContentToggled,
                              showAttachmentsToggled: statusInfo.showAttachmentsToggled,
                              isContextParent: isContextParent,
                              isReplyInContext: isReplyInContext,
                              hasReplyFollowing: hasReplyFollowing,
                              filterWarning: filterWarning),
                        statusInfo.reblogRelationship ?? statusInfo.relationship)
                }
        }
        .map { CollectionSection(items: $0) }
    }

    private static func filterMatches(_ filter: FilterV2, content: String) -> Bool {
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
