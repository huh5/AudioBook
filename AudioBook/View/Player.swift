//
//  Player.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import Combine
import MediaPlayer
import SwiftUI
import AVFoundation

extension Color {
    static var ultraThinMaterial: Color {
        return Color(UIColor.systemGray6)
    }
    
    static var ultraThickMaterial: Color {
        return Color(UIColor.systemGray6)
    }
}

class PlayerInstance: ObservableObject {
    var player: AVPlayer?
}

struct Player: View {
    
    @Binding var audioURL: URL
    var audioFileName: String
    @Binding var selectedBookDetail: BookDetail?
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    @State private var audioSetupComplete = false
    @State private var timeObserver: Any?
    
    // Inject PlayerInstance using @EnvironmentObject
    @EnvironmentObject var playerInstance: PlayerInstance
    
    init(audioURL: Binding<URL>, audioFileName: String, selectedBookDetail: Binding<BookDetail?>, expandSheet: Binding<Bool>, animation: Namespace.ID) {
        self._audioURL = audioURL
        self.audioFileName = audioFileName
        self._selectedBookDetail = selectedBookDetail
        self._expandSheet = expandSheet
        self.animation = animation
    }
    
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let safeArea = geo.safeAreaInsets
            
            ZStack{
                Rectangle()
                    .fill(Color.ultraThickMaterial)
                    .overlay(content: {
                        Rectangle()
                        Image("forest")
                            .blur(radius: 55)
                    })
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
                VStack(spacing: 15){
                    VStack(spacing: 15){
                        GeometryReader{ geo in
                            let size = geo.size
                            Image("forest")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .frame(height: size.width - 50)
                        .padding(.vertical, size.height < 700 ? 10 : 30)
                        
                        PlayerView(size: size)
                            .offset(CGSize(width: 10.0, height: 10.0))
                    }
                    .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                    .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                    .padding(.horizontal, 25)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
                }
            }
            .ignoresSafeArea(.container, edges: .all)
            .onAppear {
                setupAudio()
                playAudio()
                configureAudioSession() // Вызов метода для настройки аудиосессии
                setupNowPlayingInfoCenter() // Настройка информации о воспроизведении для управления с экрана блокировки и экрана управления мультимедиа
                setupRemoteTransportControls() // Настройка управления аудио с экрана блокировки и экрана управления мультимедиа
            }
        }
    }
    
    // Метод для настройки аудиосессии
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session:", error.localizedDescription)
        }
    }
    
    private func setupAudio() {
        guard !audioSetupComplete else { return }
        
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = 1.0
        
        // Observe duration changes for total time
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) { time in
            if let duration = self.player?.currentItem?.duration.seconds, duration > 0.0 {
                DispatchQueue.main.async {
                    self.totalTime = duration
                    self.updateProgress() // Обновляем прогресс при изменении времени
                }
            }
        }
        
        
        audioSetupComplete = true
    }
    
    private func playAudio() {
        player?.play()
        isPlaying = true
    }

    private func stopAudio() {
        player?.pause()
        isPlaying = false
    }

    
    private func updateProgress() {
        currentTime = player?.currentTime().seconds ?? 0.0
    }
    
    private func seekAudio(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
    
    private func timeString(time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: time)!
    }
    
    private mutating func playTrack(with url: URL) {
        self.audioURL = url
        self.audioSetupComplete = false
        self.setupAudio()
        self.playAudio()
    }
    
    private func playNextTrack() {
        guard let bookDetail = selectedBookDetail else { return }
        guard let currentIndex = bookDetail.files.firstIndex(where: { $0.fileURL == audioURL }) else { return }
        guard currentIndex < bookDetail.files.count - 1 else { return }
        let nextTrackURL = bookDetail.files[currentIndex + 1].fileURL
        audioURL = nextTrackURL
        setupAudio()
        playAudio()
    }
    
    private func playPreviousTrack() {
        guard let bookDetail = selectedBookDetail else { return }
        guard let currentIndex = bookDetail.files.firstIndex(where: { $0.fileURL == audioURL }) else { return }
        guard currentIndex > 0 else { return }
        let previousTrackURL = bookDetail.files[currentIndex - 1].fileURL
        audioURL = previousTrackURL
        setupAudio()
        playAudio()
    }
    
    
    // Add buttons and bindings in your PlayerView
    @ViewBuilder
    func PlayerView(size: CGSize) -> some View {
        VStack(spacing: size.height * 0.04) {
            VStack(spacing: size.height * 0.04) {
                HStack(alignment: .center, spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(audioFileName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(".mp3")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.ultraThinMaterial)
                                    .environment(\.colorScheme, .light)
                            )
                    }
                }
                
                Slider(value: Binding(
                    get: { currentTime },
                    set: { newValue in
                        seekAudio(to: newValue)
                    }
                ), in: 0...totalTime)
                .foregroundColor(.white)
                
                HStack {
                    Text(timeString(time: currentTime))
                    Spacer()
                    Text(timeString(time: totalTime))
                }
                HStack(spacing: size.width * 0.18) {
                    
                    Button(action: { self.playPreviousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                    Button(action: {
                        if isPlaying {
                            stopAudio()
                        } else {
                            playAudio()
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                    }
                    
                    Button(action: { self.playNextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                    
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                
            }
            .frame(height: size.height / 2.5, alignment: .top)
            
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Remote Control and Now Playing Info
    
    private func setupNowPlayingInfoCenter() {
        guard let player = player else { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        let duration = CMTimeGetSeconds(player.currentItem?.asset.duration ?? CMTime.zero)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioFileName // Добавляем название файла
        
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
        // Update the now playing info every second
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { time in
            let elapsedTime = CMTimeGetSeconds(time)
            var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
        
    }
    
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { event in
            if !isPlaying {
                playAudio()
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { event in
            if isPlaying {
                stopAudio()
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { event in
            if isPlaying {
                stopAudio()
            } else {
                playAudio()
            }
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { event in
            playNextTrack()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { event in
            playPreviousTrack()
            return .success
        }
        
        // Add seeking controls
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            let newPosition = event.positionTime
            seekAudio(to: newPosition)
            return .success
        }
    }

}
