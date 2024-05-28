//
//  ContentView.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import MediaPlayer

class TabSelectionViewModel: ObservableObject {
    @Published var tabSelected: Int = 0
    @Published var musicButtonData = MusicButtonData() // Define musicButtonData here
}

struct ContentView: View {
    @ObservedObject var tabSelectionViewModel = TabSelectionViewModel() // Use ObservedObject
    @State private var showAlert = false
    @State private var isOnHomePage = true // Add state variable to track if on HomePage
    
    var body: some View {
        ZStack {
            if isOnHomePage {
                HomePage(viewModel: tabSelectionViewModel) {
                    isOnHomePage = false // Update state to transition to BooksPage
                }
            } else {
                BooksPage(viewModel: tabSelectionViewModel)
                    .onAppear {
                        tabSelectionViewModel.musicButtonData.loadSelectedFiles()
                    }
                    .onDisappear {
                        tabSelectionViewModel.musicButtonData.saveSelectedFiles()
                    }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Доступ к музыкальной библиотеке"),
                message: Text("Разрешите доступ к вашей музыкальной библиотеке в настройках приложения, чтобы иметь возможность выбирать музыкальные треки."),
                primaryButton: .default(Text("Открыть настройки")) {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            requestMediaLibraryAuthorization()
        }
    }
    
    private func requestMediaLibraryAuthorization() {
        MPMediaLibrary.requestAuthorization { status in
            if status != .authorized {
                showAlert = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
