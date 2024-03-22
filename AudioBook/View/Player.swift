//
//  Player.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//
import SwiftUI
import AVFoundation

extension Color {
    static var ultraThinMaterial: Color {
        return Color(UIColor.systemGray6)
    }
}
extension Color {
    static var ultraThickMaterial: Color {
        // Замените этот код на ваш реальный цвет
        return Color(red: 0.5, green: 0.5, blue: 0.5)
    }
}

struct Player: View {
    
    var audioURL: URL
    var audioFileName: String
    @Binding var selectedBookDetail: BookDetail?
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    
    init(audioURL: URL, audioFileName: String, selectedBookDetail: Binding<BookDetail?>, expandSheet: Binding<Bool>, animation: Namespace.ID) {
        self.audioURL = audioURL
        self.audioFileName = audioFileName
        self._selectedBookDetail = selectedBookDetail
        self._expandSheet = expandSheet
        self.animation = animation
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.ultraThickMaterial)
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
                
                Image("forest")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 55)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                VStack(spacing: 15) {
                    GeometryReader { geometry in
                        Image("forest")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .frame(height: geometry.size.width - 50)
                    .padding(.vertical, geometry.safeAreaInsets.top < 700 ? 10 : 30)
                    
                    VStack(spacing: geometry.size.height * 0.04) {
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
                        
                        Slider(value: Binding(get: { currentTime }, set: { newValue in seekAudio(to: newValue) }), in: 0...totalTime)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text(timeString(time: currentTime))
                            Spacer()
                            Text(timeString(time: totalTime))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    
                    HStack(spacing: geometry.size.width * 0.18) {
                        Button(action: {}) {
                            Image(systemName: "backward.fill")
                                .font(geometry.size.height < 300 ? .title3 : .title)
                        }
                        Button(action: {
                            isPlaying ? stopAudio() : playAudio()
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(geometry.size.height < 300 ? .largeTitle : .system(size: 50))
                        }
                        Button(action: {}) {
                            Image(systemName: "forward.fill")
                                .font(geometry.size.height < 300 ? .title3 : .title)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.top, geometry.safeAreaInsets.top + (geometry.safeAreaInsets.bottom == 0 ? 10 : 0))
                .padding(.bottom, geometry.safeAreaInsets.bottom == 0 ? 10 : geometry.safeAreaInsets.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            }
        }
        .ignoresSafeArea(.container, edges: .all)
        .onAppear(perform: setupAudio)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }

    private func setupAudio() {
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.prepareToPlay()
            totalTime = player?.duration ?? 0.0
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    private func playAudio() {
        player?.play()
        isPlaying = true
    }
    
    private func stopAudio() {
        player?.stop()
        isPlaying = false
    }
    
    private func updateProgress() {
        guard let player = player else { return }
        currentTime = player.currentTime
    }
    
    private func seekAudio(to time: TimeInterval) {
        player?.currentTime = time
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minute, seconds)
    }
}
