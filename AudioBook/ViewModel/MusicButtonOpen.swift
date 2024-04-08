//
//  MusicButtonOpen.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI

class MusicButtonData: ObservableObject {
    @Published var selectedFiles: [URL]
    @Published var showDocumentPicker: Bool = false

    init(selectedFiles: [URL] = []) {
        self.selectedFiles = selectedFiles
    }

    func addFiles(urls: [URL]) {
        print("Adding files: \(urls)")
        self.selectedFiles.append(contentsOf: urls)
    }
    
    // Добавьте метод для сохранения выбранных файлов
    func saveSelectedFiles() {
        // Сохраните выбранные файлы в UserDefaults или в другое хранилище данных
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(selectedFiles) {
            UserDefaults.standard.set(encodedData, forKey: "SelectedFiles")
        }
    }
    
    // Добавьте метод для загрузки выбранных файлов
    func loadSelectedFiles() {
        if let data = UserDefaults.standard.data(forKey: "SelectedFiles") {
            let decoder = JSONDecoder()
            if let decodedFiles = try? decoder.decode([URL].self, from: data) {
                self.selectedFiles = decodedFiles
            }
        }
    }
}

struct MusicButtonOpen: View {
    @Binding var showDocumentPicker: Bool // Use a separate binding for simplicity

    var body: some View {
        VStack {
            Button(action: { showDocumentPicker.toggle() }) {
                Text("Choose Audio Files")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(width: 200)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var data: MusicButtonData

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.data.addFiles(urls: urls)
            parent.data.showDocumentPicker = false // Dismiss the picker
        }
    }
}
