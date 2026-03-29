// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import Mastodon
import SwiftUI
import ViewModels

struct SwiftUIComposeAutocompleteView: View {
    @ObservedObject var parentViewModel: NewStatusViewModel
    @ObservedObject var compositionViewModel: CompositionViewModel
    let onSelect: (String) -> Void

    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var emojiPickerViewModel: EmojiPickerViewModel
    @State private var searchResults = [AutocompleteResult]()
    @State private var emojiResults = [PickerEmoji]()

    init(parentViewModel: NewStatusViewModel,
         compositionViewModel: CompositionViewModel,
         onSelect: @escaping (String) -> Void) {
        self.parentViewModel = parentViewModel
        self.compositionViewModel = compositionViewModel
        self.onSelect = onSelect
        _searchViewModel = StateObject(wrappedValue:
            SearchViewModel(identityContext: parentViewModel.identityContext))
        _emojiPickerViewModel = StateObject(wrappedValue:
            EmojiPickerViewModel(identityContext: parentViewModel.identityContext, queryOnly: true))
    }

    var body: some View {
        VStack(spacing: 0) {
            if hasActiveQuery, !searchResults.isEmpty {
                searchResultsList
                    .frame(maxHeight: 150)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            } else if hasActiveQuery, !emojiResults.isEmpty {
                emojiResultsGrid
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            }
        }
        .onChange(of: compositionViewModel.autocompleteQuery) { routeQuery($0) }
        .onReceive(searchViewModel.updates.receive(on: DispatchQueue.main)) { update in
            let items: [AutocompleteResult] = update.sections.flatMap(\.items).compactMap { item in
                switch item {
                case let .account(account, _, _):
                    return .account(account)
                case let .tag(tag):
                    return .tag(tag)
                default:
                    return nil
                }
            }
            if !items.isEmpty || searchViewModel.query.isEmpty {
                searchResults = items
            }
        }
        .onReceive(emojiPickerViewModel.$emoji.receive(on: DispatchQueue.main)) { sections in
            emojiResults = sections.sorted { $0.key < $1.key }.flatMap(\.value)
        }
    }
}

private extension SwiftUIComposeAutocompleteView {
    var hasActiveQuery: Bool {
        guard let query = compositionViewModel.autocompleteQuery else { return false }
        return !query.isEmpty
    }

    enum AutocompleteResult: Identifiable {
        case account(Account)
        case tag(Tag)

        var id: String {
            switch self {
            case let .account(account): return "account-\(account.id)"
            case let .tag(tag): return "tag-\(tag.name)"
            }
        }
    }

    var searchResultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(searchResults) { result in
                    Button {
                        select(result: result)
                    } label: {
                        resultRow(result)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    var emojiResultsGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .defaultSpacing) {
                ForEach(Array(emojiResults.enumerated()), id: \.offset) { _, emoji in
                    Button {
                        selectEmoji(emoji)
                    } label: {
                        emojiLabel(emoji)
                            .frame(width: .minimumButtonDimension, height: .minimumButtonDimension)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, .compactSpacing)
        }
        .frame(height: .minimumButtonDimension + .compactSpacing * 2)
    }

    @ViewBuilder
    func resultRow(_ result: AutocompleteResult) -> some View {
        switch result {
        case let .account(account):
            HStack {
                Text("@\(account.acct)")
                    .font(.body)
                if !account.displayName.isEmpty {
                    Text(account.displayName)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, .compactSpacing)
        case let .tag(tag):
            Text("#\(tag.name)")
                .font(.body)
                .padding(.horizontal)
                .padding(.vertical, .compactSpacing)
        }
    }

    @ViewBuilder
    func emojiLabel(_ emoji: PickerEmoji) -> some View {
        switch emoji {
        case .system(let systemEmoji, _):
            Text(systemEmoji.emoji)
                .font(.title2)
        case .custom(let customEmoji, _):
            AsyncImage(url: customEmoji.url.url) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 24, height: 24)
        }
    }

    func routeQuery(_ query: String?) {
        guard let query = query, !query.isEmpty else {
            searchViewModel.query = ""
            emojiPickerViewModel.query = ""
            searchResults = []
            emojiResults = []
            return
        }

        if query.starts(with: ":") {
            searchViewModel.query = ""
            searchResults = []
            emojiPickerViewModel.query = String(query.dropFirst())
        } else {
            if query.starts(with: "@") {
                searchViewModel.scope = .accounts
            } else if query.starts(with: "#") {
                searchViewModel.scope = .tags
            }
            searchViewModel.query = String(query.dropFirst())
            emojiPickerViewModel.query = ""
            emojiResults = []
        }
    }

    func select(result: AutocompleteResult) {
        switch result {
        case let .account(account):
            onSelect("@\(account.acct)")
        case let .tag(tag):
            onSelect("#\(tag.name)")
        }
        searchViewModel.query = ""
        searchResults = []
    }

    func selectEmoji(_ emoji: PickerEmoji) {
        let resolved = emoji.applyingDefaultSkinTone(identityContext: parentViewModel.identityContext)
        onSelect(resolved.escaped)
        emojiPickerViewModel.query = ""
        emojiPickerViewModel.updateUse(emoji: emoji)
        emojiResults = []
    }
}
