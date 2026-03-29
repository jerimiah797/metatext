// Copyright © 2021 Metabolist. All rights reserved.

import Mastodon
import SwiftUI
import ViewModels

struct NotificationPreferencesView: View {
    @StateObject var viewModel: PreferencesViewModel
    @StateObject var identityContext: IdentityContext

    init(viewModel: PreferencesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _identityContext = StateObject(wrappedValue: viewModel.identityContext)
    }

    var body: some View {
        Form {
            Section {
                Toggle("preferences.notifications.include-pictures",
                       isOn: $identityContext.appPreferences.notificationPictures)
                .accessibilityIdentifier("notifications.include-pictures")
                Toggle("preferences.notifications.include-account-name",
                       isOn: $identityContext.appPreferences.notificationAccountName)
                .accessibilityIdentifier("notifications.include-account-name")
            }
            Section(header: Text("preferences.notifications.sounds")) {
                ForEach(MastodonNotification.NotificationType.allCasesExceptUnknown) { type in
                    Toggle(isOn: .init {
                        viewModel.identityContext.appPreferences.notificationSounds.contains(type)
                    } set: {
                        if $0 {
                            viewModel.identityContext.appPreferences.notificationSounds.insert(type)
                        } else {
                            viewModel.identityContext.appPreferences.notificationSounds.remove(type)
                        }
                    }) {
                        Label(type.localizedStringKey, systemImage: type.systemImageName)
                    }
                    .accessibilityIdentifier("notifications.sound.\(type.id)")
                }
            }
        }
        .navigationTitle("preferences.notifications")
    }
}

extension MastodonNotification.NotificationType {
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .follow:
            return "preferences.notification-types.follow"
        case .mention:
            return "preferences.notification-types.mention"
        case .reblog:
            return "preferences.notification-types.reblog"
        case .favourite:
            return "preferences.notification-types.favourite"
        case .poll:
            return "preferences.notification-types.poll"
        case .followRequest:
            return "preferences.notification-types.follow-request"
        case .status:
            return "preferences.notification-types.status"
        case .update:
            return ""
        case .unknown:
            return ""
        }
    }

    var systemImageName: String {
        switch self {
        case .follow, .followRequest:
            return "person.badge.plus"
        case .mention:
            return "at"
        case .reblog:
            return "arrow.2.squarepath"
        case .favourite:
            return "star.fill"
        case .poll:
            return "chart.bar.xaxis"
        case .status:
            return "bell.fill"
        case .update:
            return "pencil"
        case .unknown:
            return "app.badge"
        }
    }
}

#if DEBUG
import PreviewViewModels

struct NotificationPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesView(viewModel: .init(identityContext: .preview))
    }
}
#endif
