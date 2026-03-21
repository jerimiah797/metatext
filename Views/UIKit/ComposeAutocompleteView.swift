// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import Mastodon
import UIKit
import ViewModels

final class ComposeAutocompleteView: UIView {
    let autocompleteSelections: AnyPublisher<String, Never>

    private let autocompleteCollectionView: UICollectionView
    private let autocompleteDataSource: AutocompleteDataSource
    private let autocompleteCollectionViewHeightConstraint: NSLayoutConstraint
    private let autocompleteSelectionsSubject = PassthroughSubject<String, Never>()
    private let parentViewModel: NewStatusViewModel
    private var cancellables = Set<AnyCancellable>()

    init(queryPublisher: AnyPublisher<String?, Never>,
         parentViewModel: NewStatusViewModel) {
        self.parentViewModel = parentViewModel

        autocompleteCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: Self.autocompleteLayout())
        autocompleteDataSource = AutocompleteDataSource(
            collectionView: autocompleteCollectionView,
            queryPublisher: queryPublisher,
            parentViewModel: parentViewModel)
        autocompleteCollectionViewHeightConstraint =
            autocompleteCollectionView.heightAnchor.constraint(equalToConstant: .hairline)
        autocompleteSelections = autocompleteSelectionsSubject.eraseToAnyPublisher()

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        addSubview(autocompleteCollectionView)
        autocompleteCollectionView.translatesAutoresizingMaskIntoConstraints = false
        autocompleteCollectionView.alwaysBounceVertical = false
        autocompleteCollectionView.backgroundColor = .clear
        autocompleteCollectionView.layer.cornerRadius = .defaultCornerRadius
        autocompleteCollectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        autocompleteCollectionView.dataSource = autocompleteDataSource
        autocompleteCollectionView.delegate = self

        let autocompleteBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        autocompleteCollectionView.backgroundView = autocompleteBackgroundView

        NSLayoutConstraint.activate([
            autocompleteCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            autocompleteCollectionView.topAnchor.constraint(equalTo: topAnchor),
            autocompleteCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            autocompleteCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            autocompleteCollectionViewHeightConstraint
        ])

        autocompleteCollectionView.publisher(for: \.contentSize)
            .map(\.height)
            .removeDuplicates()
            .throttle(for: .seconds(TimeInterval.shortAnimationDuration), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] height in
                UIView.animate(withDuration: .zeroIfReduceMotion(.shortAnimationDuration)) {
                    self?.setAutocompleteHeight(height)
                }
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ComposeAutocompleteView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let item = autocompleteDataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case let .account(account):
            autocompleteSelectionsSubject.send("@".appending(account.acct))
        case let .tag(tag):
            autocompleteSelectionsSubject.send("#".appending(tag.name))
        case let .emoji(emoji):
            let escaped = emoji.applyingDefaultSkinTone(identityContext: parentViewModel.identityContext).escaped
            autocompleteSelectionsSubject.send(escaped)
            autocompleteDataSource.updateUse(emoji: emoji)
        }

        UISelectionFeedbackGenerator().selectionChanged()

        UIView.animate(withDuration: .zeroIfReduceMotion(.shortAnimationDuration)) {
            self.setAutocompleteHeight(.hairline)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = autocompleteDataSource.itemIdentifier(for: indexPath),
              case let .emoji(emojiItem) = item,
              case let .system(emoji, _) = emojiItem,
              !emoji.skinToneVariations.isEmpty
        else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: ([emoji] + emoji.skinToneVariations).map { skinToneVariation in
                UIAction(title: skinToneVariation.emoji) { [weak self] _ in
                    self?.autocompleteSelectionsSubject.send(skinToneVariation.emoji)
                    self?.autocompleteDataSource.updateUse(emoji: emojiItem)
                }
            })
        }
    }
}

private extension ComposeAutocompleteView {
    static let autocompleteCollectionViewMaxHeight: CGFloat = 150

    static func autocompleteLayout() -> UICollectionViewLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .clear

        return UICollectionViewCompositionalLayout { index, environment -> NSCollectionLayoutSection? in
            guard let autocompleteSection = AutocompleteSection(rawValue: index) else { return nil }

            switch autocompleteSection {
            case .search:
                return .list(using: listConfig, layoutEnvironment: environment)
            case .emoji:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(.minimumButtonDimension),
                    heightDimension: .absolute(.minimumButtonDimension))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                section.interGroupSpacing = .defaultSpacing
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: .compactSpacing,
                    leading: .compactSpacing,
                    bottom: .compactSpacing,
                    trailing: .compactSpacing)

                return section
            }
        }
    }

    func setAutocompleteHeight(_ height: CGFloat) {
        let clampedHeight = min(max(height, .hairline), Self.autocompleteCollectionViewMaxHeight)
        autocompleteCollectionViewHeightConstraint.constant = clampedHeight
        autocompleteCollectionView.alpha = clampedHeight == .hairline ? 0 : 1
        superview?.layoutIfNeeded()
    }
}
