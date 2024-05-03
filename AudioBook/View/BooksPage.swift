//
//  BooksPage.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import AVFoundation

struct BooksPage: View {
    @ObservedObject var viewModel: TabSelectionViewModel // Используйте ObservedObject здесь
       @StateObject var libraryStore = LibraryStore()
       @StateObject var imageStore = ImageStore()


    var body: some View {
        TabView(selection: $viewModel.tabSelected) {
            homeView
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.tabSelected = 2
                        }) {
                            Text("Let’s go")
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .font(Font.custom("Zen Maru Gothic", size: 30))
                                .background(Color(red: 0.77, green: 0.27, blue: 0.41))
                                .cornerRadius(20)
                        }
                    }
                }
            
            playerView
                .tabItem {
                    Label("Player", systemImage: "play.circle.fill")
                }
                .tag(1)
                .toolbar(.visible, for: .tabBar)
            
            uploadFilePage
                .tabItem {
                    Label("Upload", systemImage: "icloud.and.arrow.down")
                }
                .tag(2)
                .toolbar(.visible, for: .tabBar)
            
            libraryView
                .tabItem {
                    Label("Library", systemImage: "book.fill")
                }
                .tag(3)
                .toolbar(.visible, for: .tabBar)
        }
    }
    
    private var homeView: some View {
        HomePage(viewModel: viewModel)
    }
    
    private var playerView: some View {
        if let fileURL = libraryStore.library.first?.files.first?.fileURL {
            return AnyView(
                Player(audioURL: .constant(fileURL), audioFileName: libraryStore.library.first?.files.first?.fileName ?? "", selectedBookDetail: .constant(nil), expandSheet: .constant(true), animation: Namespace().wrappedValue)

            )
        } else {
            return AnyView(
                Text("No audio file selected")
            )
        }
    }

    
    private var uploadFilePage: some View {
        UploadFilePage()
    }
    
    private var libraryView: some View {
        AudioBooksPage(libraryStore: libraryStore, imageStore: imageStore, selectedFiles: $viewModel.musicButtonData.selectedFiles)
    }
}
