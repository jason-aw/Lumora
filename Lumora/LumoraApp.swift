//
//  LumoraApp.swift
//  Lumora
//
//  Created by Jason Andersen Winfrey on 7/11/2025.
//

import SwiftUI
import FirebaseCore
import Observation

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct LumoraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var journalModel = JournalsViewModel()
    @State private var micTrasncript = MicTranscript()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(journalModel)
                .environment(micTrasncript)
        }
    }
}
