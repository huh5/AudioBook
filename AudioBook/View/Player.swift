//
//  Player.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//


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
        GeometryReader{ geo in
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
            .ignoresSafeArea(.container, edges: .all)
        }
    }
    
    private func setupAudio() {
            do {
                player = try AVAudioPlayer(contentsOf: audioURL)
                player?.prepareToPlay()
                totalTime = player?.duration ?? 0.0
                setVolumeToMatchSystem()
            } catch let error {
                print("Error loading audio: \(error.localizedDescription)")
            }
        }
        
    private func setVolumeToMatchSystem() {
        player?.volume = 1.0
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
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: time)!
    }
    
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
                
                Slider(value: Binding(get: {
                    currentTime
                }, set: { newValue in
                    seekAudio(to: newValue)
                }),in: 0...totalTime)
                .foregroundColor(.white)
                
                HStack {
                    Text(timeString(time: currentTime))
                    Spacer()
                    Text(timeString(time: totalTime))
                }
                HStack(spacing: size.width * 0.18) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                    Button(action: {
                        isPlaying ? stopAudio() : playAudio()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                    }
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            
            }
            .frame(height: size.height / 2.5, alignment: .top)
            
        }
        .ignoresSafeArea(.container, edges: .all)
        .onAppear(perform: setupAudio)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
        let dummyBookDetail = BookDetail(book: Book(title: "Sample Title", author: "Sample Author"), files: [FileDetail(fileName: "Sample File", fileURL: URL(fileURLWithPath: "samplefile.mp3"))], imageData: nil)
        
        return Player(audioURL: URL(string: "samplefile.mp3")!,
                      audioFileName: "Sample File",
                      selectedBookDetail: .constant(dummyBookDetail),
                      expandSheet: .constant(true),
                      animation: Namespace().wrappedValue)
            .preferredColorScheme(.dark)
    }
}
