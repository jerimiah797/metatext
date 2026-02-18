// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import GRDB
import Mastodon

struct TimelineItemsInfo: Codable, Hashable, FetchableRecord {
    let timelineRecord: TimelineRecord
    let statusInfos: [StatusInfo]
    let pinnedStatusesInfo: PinnedStatusesInfo?
    let loadMoreRecords: [LoadMoreRecord]
}

extension TimelineItemsInfo {
    struct PinnedStatusesInfo: Codable, Hashable, FetchableRecord {
        let accountRecord: AccountRecord
        let pinnedStatusInfos: [StatusInfo]
    }

    static func addingIncludes<T: DerivableRequest>( _ request: T,
                                                     ordered: Bool) -> T where T.RowDecoder == TimelineRecord {
        let statusesAssociation = ordered ? TimelineRecord.orderedStatuses : TimelineRecord.statuses

        return request.including(all: StatusInfo.addingIncludes(statusesAssociation).forKey(CodingKeys.statusInfos))
            .including(all: TimelineRecord.loadMores.forKey(CodingKeys.loadMoreRecords))
            .including(optional: PinnedStatusesInfo.addingIncludes(TimelineRecord.account)
                        .forKey(CodingKeys.pinnedStatusesInfo))
    }

    static func request(_ request: QueryInterfaceRequest<TimelineRecord>,
                        ordered: Bool) -> QueryInterfaceRequest<Self> {
        addingIncludes(request, ordered: ordered).asRequest(of: self)
    }

    func items(filters: [Filter]) -> [CollectionSection] {
        items(useFiltersV2: false, v1Filters: filters, v2Filters: [])
    }

    func items(useFiltersV2: Bool, v1Filters: [Filter], v2Filters: [FilterV2] = []) -> [CollectionSection] {
        let timeline = Timeline(record: timelineRecord)!
        let filterRegularExpression = useFiltersV2 ? nil : v1Filters.regularExpression(context: timeline.filterContext)
        var timelineItems = statusInfos.filtered(regularExpression: filterRegularExpression)
            .compactMap { statusInfo -> CollectionItem? in
                if useFiltersV2 {
                    let status = Status(info: statusInfo)
                    let effectiveFiltered = status.filtered.isEmpty
                        ? status.displayStatus.filtered
                        : status.filtered

                    var filterWarning: String?

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
                            guard filter.context.contains(where: { $0 == timeline.filterContext }) else { continue }
                            if let exp = filter.expiresAt, exp < Date() { continue }
                            if Self.filterMatches(filter, content: content) {
                                if filter.filterAction == .hide { return nil }
                                if filter.filterAction == .warn { filterWarning = filter.title; break }
                            }
                        }
                    }

                    if filterWarning != nil {
                        return .status(
                            status,
                            .init(showContentToggled: statusInfo.showContentToggled,
                                  showAttachmentsToggled: statusInfo.showAttachmentsToggled,
                                  isReplyOutOfContext: (statusInfo.reblogRecord ?? statusInfo.record)
                                    .inReplyToId != nil,
                                  filterWarning: filterWarning),
                            statusInfo.reblogRelationship ?? statusInfo.relationship)
                    }
                }

                return .status(
                    .init(info: statusInfo),
                    .init(showContentToggled: statusInfo.showContentToggled,
                          showAttachmentsToggled: statusInfo.showAttachmentsToggled,
                          isReplyOutOfContext: (statusInfo.reblogRecord ?? statusInfo.record).inReplyToId != nil),
                    statusInfo.reblogRelationship ?? statusInfo.relationship)
            }

        for loadMoreRecord in loadMoreRecords {
            guard let index = timelineItems.firstIndex(where: {
                guard case let .status(status, _, _) = $0 else { return false }

                return loadMoreRecord.afterStatusId > status.id
            }) else { continue }

            timelineItems.insert(
                .loadMore(LoadMore(
                            timeline: timeline,
                            afterStatusId: loadMoreRecord.afterStatusId,
                            beforeStatusId: loadMoreRecord.beforeStatusId)),
                at: index)
        }

        if timelineRecord.profileCollection == .statuses,
           let pinnedStatusInfos = pinnedStatusesInfo?.pinnedStatusInfos {
            return [.init(items: pinnedStatusInfos.filtered(regularExpression: filterRegularExpression)
                        .map {
                            CollectionItem.status(
                                .init(info: $0),
                                .init(showContentToggled: $0.showContentToggled,
                                      showAttachmentsToggled: $0.showAttachmentsToggled,
                                      isPinned: true,
                                      isReplyOutOfContext: ($0.reblogRecord ?? $0.record).inReplyToId != nil),
                                $0.reblogRelationship ?? $0.relationship)
                        }),
                    .init(items: timelineItems)]
        } else {
            return [.init(items: timelineItems)]
        }
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

extension TimelineItemsInfo.PinnedStatusesInfo {
    static func addingIncludes<T: DerivableRequest>(_ request: T) -> T where T.RowDecoder == AccountRecord {
        request.including(all: StatusInfo.addingIncludes(AccountRecord.pinnedStatuses)
                            .forKey(CodingKeys.pinnedStatusInfos))
    }
}
