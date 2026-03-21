// Copyright © 2024 Metabolist. All rights reserved.

import Combine
import Mastodon
import UIKit
import ViewModels

final class ComposeToolbarView: UIView {
    var activeInputTag: Int = 0

    private let parentViewModel: NewStatusViewModel
    private let stackView = UIStackView()
    private var activeViewModel: CompositionViewModel
    private var cancellables = Set<AnyCancellable>()
    private var compositionCancellables = Set<AnyCancellable>()

    // Buttons that need updating when active composition changes
    private let attachmentButton: UIButton
    private let pollButton: UIButton
    private let visibilityButton: UIButton
    private let contentWarningButton: UIButton
    private let emojiButton: UIButton
    private let addButton: UIButton
    private let charactersLabel = UILabel()

    // swiftlint:disable:next function_body_length
    init(viewModel: CompositionViewModel, parentViewModel: NewStatusViewModel) {
        self.parentViewModel = parentViewModel
        self.activeViewModel = viewModel

        // Create buttons
        attachmentButton = Self.makeToolbarButton(
            systemImage: "paperclip",
            accessibilityIdentifier: "compose.attachment",
            accessibilityLabel: NSLocalizedString("compose.attachments-button.accessibility-label", comment: ""))

        pollButton = Self.makeToolbarButton(
            systemImage: "chart.bar.xaxis",
            accessibilityIdentifier: "compose.poll",
            accessibilityLabel: NSLocalizedString("compose.poll-button.accessibility-label", comment: ""))

        visibilityButton = Self.makeToolbarButton(
            systemImage: parentViewModel.visibility.systemImageName,
            accessibilityIdentifier: "compose.visibility",
            accessibilityLabel: nil)
        visibilityButton.isEnabled = parentViewModel.canChangeVisibility

        contentWarningButton = Self.makeToolbarButton(
            title: NSLocalizedString("status.content-warning-abbreviation", comment: ""),
            accessibilityIdentifier: "compose.content-warning",
            accessibilityLabel: nil)

        emojiButton = Self.makeToolbarButton(
            systemImage: "face.smiling",
            accessibilityIdentifier: "compose.emoji",
            accessibilityLabel: NSLocalizedString("compose.emoji-button", comment: ""))

        addButton = Self.makeToolbarButton(
            systemImage: "plus.circle.fill",
            accessibilityIdentifier: "compose.add",
            accessibilityLabel: nil)

        switch parentViewModel.identityContext.appPreferences.statusWord {
        case .toot:
            addButton.accessibilityLabel =
                NSLocalizedString("compose.add-button-accessibility-label.toot", comment: "")
        case .post:
            addButton.accessibilityLabel =
                NSLocalizedString("compose.add-button-accessibility-label.post", comment: "")
        }

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground

        // Configure stack view
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = .defaultSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: .defaultSpacing, bottom: 0, right: .defaultSpacing)
        stackView.isLayoutMarginsRelativeArrangement = true

        // Characters label (replaces the disabled bar button item)
        charactersLabel.adjustsFontForContentSizeCategory = true
        charactersLabel.font = .preferredFont(forTextStyle: .callout)
        charactersLabel.setContentHuggingPriority(.required, for: .horizontal)
        charactersLabel.accessibilityIdentifier = "compose.characters"

        // Add separator above toolbar
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        // Layout
        stackView.addArrangedSubview(attachmentButton)
        stackView.addArrangedSubview(pollButton)
        stackView.addArrangedSubview(visibilityButton)
        stackView.addArrangedSubview(contentWarningButton)
        stackView.addArrangedSubview(emojiButton)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacer)

        stackView.addArrangedSubview(charactersLabel)
        stackView.addArrangedSubview(addButton)

        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.heightAnchor.constraint(equalToConstant: .hairline),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: .minimumButtonDimension),
            heightAnchor.constraint(equalToConstant: .minimumButtonDimension)
        ])

        // Set up button actions
        attachmentButton.showsMenuAsPrimaryAction = true

        pollButton.addAction(UIAction { [weak viewModel] _ in
            viewModel?.displayPoll.toggle()
        }, for: .touchUpInside)

        contentWarningButton.addAction(UIAction { [weak viewModel] _ in
            viewModel?.displayContentWarning.toggle()
        }, for: .touchUpInside)

        emojiButton.addAction(UIAction { [weak self, weak parentViewModel] _ in
            guard let self = self, let parentViewModel = parentViewModel else { return }
            parentViewModel.presentEmojiPicker(tag: self.activeInputTag)
        }, for: .touchUpInside)

        addButton.addAction(UIAction { [weak parentViewModel, weak viewModel] _ in
            guard let parentViewModel = parentViewModel, let viewModel = viewModel else { return }
            parentViewModel.insert(after: viewModel)
        }, for: .touchUpInside)

        // Visibility menu
        visibilityButton.showsMenuAsPrimaryAction = true
        visibilityButton.menu = Self.visibilityMenu(parentViewModel: parentViewModel,
                                                     selectedVisibility: parentViewModel.visibility)

        // Attachment menu
        attachmentButton.menu = Self.attachmentMenu(viewModel: viewModel, parentViewModel: parentViewModel)

        // Shared subscriptions (don't change with active composition)
        parentViewModel.$visibility
            .sink { [weak self] visibility in
                guard let self = self else { return }
                self.visibilityButton.setImage(UIImage(systemName: visibility.systemImageName), for: .normal)
                self.visibilityButton.menu = Self.visibilityMenu(
                    parentViewModel: parentViewModel,
                    selectedVisibility: visibility)
                self.visibilityButton.accessibilityLabel = String.localizedStringWithFormat(
                    NSLocalizedString("compose.visibility-button.accessibility-label-%@", comment: ""),
                    visibility.title ?? "")
            }
            .store(in: &cancellables)

        // Bind to initial composition
        bindToActiveComposition()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActiveComposition(_ viewModel: CompositionViewModel) {
        activeViewModel = viewModel
        rebuildActions(for: viewModel)
        bindToActiveComposition()
    }
}

private extension ComposeToolbarView {
    static func makeToolbarButton(systemImage: String? = nil,
                                   title: String? = nil,
                                   accessibilityIdentifier: String,
                                   accessibilityLabel: String?) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label

        let button: UIButton
        if let systemImage = systemImage {
            config.image = UIImage(systemName: systemImage)
            button = UIButton(configuration: config)
        } else if let title = title {
            config.title = title
            config.titleTextAttributesTransformer = .init { attrs in
                var attrs = attrs
                attrs.font = UIFont.preferredFont(forTextStyle: .body).bold()
                return attrs
            }
            button = UIButton(configuration: config)
        } else {
            button = UIButton(configuration: config)
        }

        button.accessibilityIdentifier = accessibilityIdentifier
        if let accessibilityLabel = accessibilityLabel {
            button.accessibilityLabel = accessibilityLabel
        }
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    static func visibilityMenu(parentViewModel: NewStatusViewModel,
                                selectedVisibility: Status.Visibility) -> UIMenu {
        UIMenu(children: Status.Visibility.allCasesExceptUnknown.reversed().map { visibility in
            UIAction(
                title: visibility.title ?? "",
                image: UIImage(systemName: visibility.systemImageName),
                discoverabilityTitle: visibility.description,
                state: visibility == selectedVisibility ? .on : .off) { [weak parentViewModel] _ in
                parentViewModel?.visibility = visibility
            }
        })
    }

    static func attachmentMenu(viewModel: CompositionViewModel,
                                parentViewModel: NewStatusViewModel) -> UIMenu {
        var actions = [
            UIAction(
                title: NSLocalizedString("compose.browse", comment: ""),
                image: UIImage(systemName: "ellipsis")) { [weak parentViewModel, weak viewModel] _ in
                guard let parentViewModel = parentViewModel, let viewModel = viewModel else { return }
                parentViewModel.presentDocumentPicker(viewModel: viewModel)
            },
            UIAction(
                title: NSLocalizedString("compose.photo-library", comment: ""),
                image: UIImage(systemName: "rectangle.on.rectangle")) { [weak parentViewModel, weak viewModel] _ in
                guard let parentViewModel = parentViewModel, let viewModel = viewModel else { return }
                parentViewModel.presentMediaPicker(viewModel: viewModel)
            }
        ]

        #if !IS_SHARE_EXTENSION
        actions.insert(UIAction(
            title: NSLocalizedString("compose.take-photo-or-video", comment: ""),
            image: UIImage(systemName: "camera.fill")) { [weak parentViewModel, weak viewModel] _ in
            guard let parentViewModel = parentViewModel, let viewModel = viewModel else { return }
            parentViewModel.presentCamera(viewModel: viewModel)
        }, at: 1)
        #endif

        return UIMenu(children: actions)
    }

    func rebuildActions(for viewModel: CompositionViewModel) {
        attachmentButton.menu = Self.attachmentMenu(viewModel: viewModel, parentViewModel: parentViewModel)

        pollButton.removeTarget(nil, action: nil, for: .touchUpInside)
        pollButton.addAction(UIAction { [weak viewModel] _ in
            viewModel?.displayPoll.toggle()
        }, for: .touchUpInside)

        contentWarningButton.removeTarget(nil, action: nil, for: .touchUpInside)
        contentWarningButton.addAction(UIAction { [weak viewModel] _ in
            viewModel?.displayContentWarning.toggle()
        }, for: .touchUpInside)

        addButton.removeTarget(nil, action: nil, for: .touchUpInside)
        addButton.addAction(UIAction { [weak parentViewModel, weak viewModel] _ in
            guard let parentViewModel = parentViewModel, let viewModel = viewModel else { return }
            parentViewModel.insert(after: viewModel)
        }, for: .touchUpInside)
    }

    func bindToActiveComposition() {
        compositionCancellables.removeAll()

        let viewModel = activeViewModel

        viewModel.$canAddAttachment
            .sink { [weak self] in self?.attachmentButton.isEnabled = $0 }
            .store(in: &compositionCancellables)

        viewModel.$attachmentViewModels
            .combineLatest(viewModel.$attachmentUploadViewModels)
            .sink { [weak self] in self?.pollButton.isEnabled = $0.isEmpty && $1.isEmpty }
            .store(in: &compositionCancellables)

        viewModel.$remainingCharacters.sink { [weak self] remaining in
            self?.charactersLabel.text = String(remaining)
            self?.charactersLabel.textColor = remaining < 0 ? .systemRed : .label
            self?.charactersLabel.accessibilityHint = String.localizedStringWithFormat(
                NSLocalizedString("compose.characters-remaining-accessibility-label-%ld", comment: ""),
                remaining)
        }
        .store(in: &compositionCancellables)

        viewModel.$isPostable
            .sink { [weak self] in self?.addButton.isEnabled = $0 }
            .store(in: &compositionCancellables)

        viewModel.$displayContentWarning
            .sink { [weak self] in
                if $0 {
                    self?.contentWarningButton.accessibilityHint =
                        NSLocalizedString("compose.content-warning-button.remove", comment: "")
                } else {
                    self?.contentWarningButton.accessibilityHint =
                        NSLocalizedString("compose.content-warning-button.add", comment: "")
                }
            }
            .store(in: &compositionCancellables)
    }
}

private extension UIFont {
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
