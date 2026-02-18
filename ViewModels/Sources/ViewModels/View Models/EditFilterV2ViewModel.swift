// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import Foundation
import Mastodon
import ServiceLayer

public final class EditFilterV2ViewModel: ObservableObject {
    @Published public var title: String
    @Published public var context: Set<Filter.Context>
    @Published public var filterAction: FilterV2.Action
    @Published public var expiresAt: Date?
    @Published public var keywords: [FilterKeyword]
    @Published public var saving = false
    @Published public var alertItem: AlertItem?
    public let saveCompleted: AnyPublisher<Void, Never>
    public let identityContext: IdentityContext

    public let isNew: Bool

    public var date: Date {
        didSet { expiresAt = date }
    }

    private let filterId: FilterV2.Id?
    private let originalKeywordIds: Set<FilterKeyword.Id>
    private let saveCompletedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    public init(filter: FilterV2, identityContext: IdentityContext) {
        self.identityContext = identityContext
        isNew = filter.id == FilterV2.newFilterId
        filterId = isNew ? nil : filter.id
        title = filter.title
        context = Set(filter.context)
        filterAction = filter.filterAction
        expiresAt = filter.expiresAt
        keywords = filter.keywords
        originalKeywordIds = Set(filter.keywords.map(\.id))
        date = filter.expiresAt ?? Date()
        saveCompleted = saveCompletedSubject.eraseToAnyPublisher()
    }
}

public extension EditFilterV2ViewModel {
    var isSaveDisabled: Bool { title.isEmpty || context.isEmpty || keywords.isEmpty }

    func toggleSelection(context: Filter.Context) {
        if self.context.contains(context) {
            self.context.remove(context)
        } else {
            self.context.insert(context)
        }
    }

    func addKeyword() {
        keywords.append(.new)
    }

    func removeKeyword(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            keywords.remove(at: index)
        }
    }

    func save() {
        let validKeywords = keywords.filter { !$0.keyword.trimmingCharacters(in: .whitespaces).isEmpty }

        guard !validKeywords.isEmpty else { return }

        let contextArray = Array(context)
        let currentKeywordIds = Set(validKeywords.filter { $0.id != FilterKeyword.newKeywordId }.map(\.id))
        let deletedKeywordIds = Array(originalKeywordIds
            .subtracting([FilterKeyword.newKeywordId])
            .subtracting(currentKeywordIds))

        let publisher: AnyPublisher<FilterV2, Error>

        if isNew {
            publisher = identityContext.service.createFilterV2(
                title: title, context: contextArray, filterAction: filterAction,
                expiresIn: expiresAt, keywords: validKeywords)
        } else {
            publisher = identityContext.service.updateFilterV2(
                id: filterId!, title: title, context: contextArray,
                filterAction: filterAction, expiresIn: expiresAt,
                keywords: validKeywords, deletedKeywordIds: deletedKeywordIds)
        }

        publisher
            .flatMap { [identityContext] _ -> AnyPublisher<Never, Error> in
                identityContext.service.refreshFiltersV2()
            }
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.saving = true },
                receiveCompletion: { [weak self] in
                    guard let self = self else { return }

                    self.saving = false

                    if case .finished = $0 {
                        self.saveCompletedSubject.send()
                    }
                })
            .sink { _ in }
            .store(in: &cancellables)
    }
}
