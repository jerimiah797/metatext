// Copyright © 2020 Metabolist. All rights reserved.

import Mastodon
import SwiftUI
import ViewModels

struct NotificationTypesPreferencesView: View {
    @StateObject var viewModel: NotificationTypesPreferencesViewModel

    var body: some View {
        Form {
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.follow) {
                Label(MastodonNotification.NotificationType.follow.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.follow.systemImageName)
            }
            .accessibilityIdentifier("notification-types.follow")
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.favourite) {
                Label(MastodonNotification.NotificationType.favourite.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.favourite.systemImageName)
            }
            .accessibilityIdentifier("notification-types.favourite")
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.reblog) {
                Label(MastodonNotification.NotificationType.reblog.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.reblog.systemImageName)
            }
            .accessibilityIdentifier("notification-types.reblog")
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.mention) {
                Label(MastodonNotification.NotificationType.mention.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.mention.systemImageName)
            }
            .accessibilityIdentifier("notification-types.mention")
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.followRequest) {
                Label(MastodonNotification.NotificationType.followRequest.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.followRequest.systemImageName)
            }
            .accessibilityIdentifier("notification-types.follow-request")
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.poll) {
                Label(MastodonNotification.NotificationType.poll.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.poll.systemImageName)
            }
            .accessibilityIdentifier("notification-types.poll")
            Toggle(isOn: $viewModel.pushSubscriptionAlerts.status) {
                Label(MastodonNotification.NotificationType.status.localizedStringKey,
                      systemImage: MastodonNotification.NotificationType.status.systemImageName)
            }
            .accessibilityIdentifier("notification-types.status")
        }
        .navigationTitle("preferences.notification-types")
        .alertItem($viewModel.alertItem)
    }
}

#if DEBUG
import PreviewViewModels

struct NotificationTypesPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationTypesPreferencesView(viewModel: .init(identityContext: .preview))
    }
}
#endif
