//
//  ContentView.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import AVKit
import AVFoundation
import MediaPlayer

struct ContentView: View {
    @StateObject var tabSelectionViewModel = TabSelectionViewModel()
    @State private var isMediaPickerPresented = false
    @State private var showAlert = false
    
    var body: some View {
        BooksPage(viewModel: tabSelectionViewModel)
            .onAppear {
                MPMediaLibrary.requestAuthorization { status in
                    if status != .authorized {
                        // Пользователь не разрешил доступ к музыкальной библиотеке
                        showAlert = true
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

