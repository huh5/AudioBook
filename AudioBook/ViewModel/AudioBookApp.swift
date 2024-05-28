//
//  AudioBookApp.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import UIKit
import AVFoundation

@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Failed to configure audio session:", error.localizedDescription)
//        }
//        return true
//    }
//}
struct AudioBookApp: App {
    
    @StateObject var playerInstance = PlayerInstance() // Используйте @StateObject для объявления экземпляра PlayerInstance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerInstance)
        }
    }
}
