////
////  PlayerNotificationHandler.swift
////  AudioBook
////
////  Created by Богдан Ткачивський on 24/05/2024.
////
//
//import Foundation
//import AVFoundation
//
//class PlayerNotificationHandler {
//    static let shared = PlayerNotificationHandler()
//    private var audioURL: URL?
//    private var player: AVPlayer?
//
//    private init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
//    }
//
//    @objc private func appWillResignActive() {
//        AudioManager.shared.stopCurrentPlayer()
//    }
//
//    func setPlayer(_ player: AVPlayer, url: URL) {
//        self.player = player
//        self.audioURL = url
//    }
//}
