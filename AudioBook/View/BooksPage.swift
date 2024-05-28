//
//  BooksPage.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import AVFoundation

struct BooksPage: View {
    @ObservedObject var viewModel: TabSelectionViewModel
    @StateObject var libraryStore = LibraryStore()
    @StateObject var imageStore = ImageStore()
    @StateObject var playerInstance = PlayerInstance()
    @State private var activeAudioURL: URL? = nil
    @State private var activeAudioFileName: String? = nil
    @State private var activeBookDetail: BookDetail? = nil
    @State private var expandSheet: Bool = false
    @Namespace var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.tabSelected) {
                AudioBooksPage(
                    libraryStore: libraryStore,
                    imageStore: imageStore,
                    selectedFiles: $viewModel.musicButtonData.selectedFiles,
                    onSelectAudioFile: { url in
                        self.activeAudioURL = url
                        // Найти fileName и bookDetail на основе URL
                        if let bookDetail = libraryStore.library.first(where: { $0.files.contains(where: { $0.fileURL == url }) }) {
                            self.activeBookDetail = bookDetail
                            self.activeAudioFileName = bookDetail.files.first(where: { $0.fileURL == url })?.fileName
                        }
                        self.viewModel.tabSelected = 1 // Переключаемся на вкладку Player
                    }
                )
                .tabItem {
                    Label("Library", systemImage: "book.fill")
                }
                .tag(3)

                UploadFilePage()
                .tabItem {
                    Label("Upload", systemImage: "icloud.and.arrow.down")
                }
                .tag(2)

                if let url = activeAudioURL, let fileName = activeAudioFileName, let bookDetail = activeBookDetail {
                    Player(
                        audioURL: Binding(get: { url }, set: { self.activeAudioURL = $0 }),
                        audioFileName: Binding(get: { fileName }, set: { self.activeAudioFileName = $0 }),
                        selectedBookDetail: Binding(get: { bookDetail }, set: { self.activeBookDetail = $0 }),
                        expandSheet: $expandSheet,
                        animation: animation
                    )
                    .tabItem {
                        Label("Player", systemImage: "play.circle.fill")
                    }
                    .tag(1)
                } else {
                    Text("Player")
                        .tabItem {
                            Label("Player", systemImage: "play.circle.fill")
                        }
                        .tag(1)
                }
            }
        }
        .environmentObject(playerInstance)
    }
}

struct BooksPage_Previews: PreviewProvider {
    static var previews: some View {
        BooksPage(viewModel: TabSelectionViewModel())
    }
}
