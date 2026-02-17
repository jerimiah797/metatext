// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import UIKit

final class AppDelegate: NSObject {
    @Published private var application: UIApplication?
    private let deviceTokenSubject = PassthroughSubject<Data, Error>()
}

extension AppDelegate {
    func registerForRemoteNotifications() -> AnyPublisher<Data, Error> {
        $application
            .compactMap { $0 }
            .handleEvents(receiveOutput: { $0.registerForRemoteNotifications() })
            .setFailureType(to: Error.self)
            .zip(deviceTokenSubject)
            .first()
            .map { $1 }
            .eraseToAnyPublisher()
    }
}

extension AppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.application = application

        #if DEBUG
        configureDebugLogging()
        #endif

        configureGlobalAppearance()

        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        deviceTokenSubject.send(deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        deviceTokenSubject.send(completion: .failure(error))
    }
}

private extension AppDelegate {
    func configureDebugLogging() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logPath = documentsPath.appendingPathComponent("debug.log")

        // Redirect both stdout (print) and stderr (NSLog) to our log file
        freopen(logPath.path.cString(using: .utf8), "a+", stdout)
        freopen(logPath.path.cString(using: .utf8), "a+", stderr)

        // Disable stdout buffering so print() flushes immediately (like stderr/NSLog)
        setbuf(stdout, nil)

        print("[DEBUG-LOG] Logging redirected to: \(logPath.path)")
        print("[DEBUG-LOG] Documents directory: \(documentsPath.path)")
    }

    func configureGlobalAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()

            appearance.configureWithDefaultBackground()

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
