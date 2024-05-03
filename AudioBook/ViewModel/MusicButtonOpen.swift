//
//  MusicButtonOpen.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//
import AVFoundation
import SwiftUI
import ZIPFoundation // Для работы с ZIP файлами
import MobileCoreServices
import UniformTypeIdentifiers

//1
class MusicButtonData: ObservableObject {
    @Published var selectedFiles: [URL]
       @Published var audioFileNames: [String] // Добавляем свойство для имен аудиофайлов

       init(selectedFiles: [URL] = [], audioFileNames: [String] = []) {
           self.selectedFiles = selectedFiles
           self.audioFileNames = audioFileNames
       }

    func addFiles(urls: [URL]) {
        self.selectedFiles.append(contentsOf: urls)
    }
    
    func addZipFile(url: URL) {
        do {
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            try FileManager.default.unzipItem(at: url, to: destinationURL)

            // Get all files in the unzipped directory
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                // Clear selectedFiles before adding new files
                self.selectedFiles.removeAll()

                for fileURL in contents {
                    // Check if it's a file and add it to selectedFiles
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) && !isDirectory.boolValue {
                        // Generate a unique filename for audio files
                        let uniqueFilename = UUID().uuidString + "_" + fileURL.lastPathComponent
                        // Construct a new URL with the unique filename
                        let uniqueFileURL = destinationURL.appendingPathComponent(uniqueFilename)
                        // Move the file to the new URL
                        try fileManager.moveItem(at: fileURL, to: uniqueFileURL)
                        // Add the unique file URL to the selectedFiles array
                        self.selectedFiles.append(uniqueFileURL)
                        // You can also add file names for display
                        self.audioFileNames.append(uniqueFilename)
                    }
                }
            }
        } catch {
            print("Error unzipping file: \(error)")
        }
    }

    
    func removeAllFiles() {
        selectedFiles.removeAll()
    }
    
    func saveSelectedFiles() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(selectedFiles) {
            UserDefaults.standard.set(encodedData, forKey: "SelectedFiles")
        }
    }
    
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
    @Binding var showDocumentPicker: Bool

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
    @Binding var selectedFiles: [URL]
    @Binding var audioFileNames: [String]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: [(UTType.audio).identifier, (UTType.zip).identifier], in: .import)
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
            for url in urls {
                if url.pathExtension == "zip" {
                    parent.extractFilesFromZip(url)
                } else {
                    parent.selectedFiles.append(url)
                    parent.audioFileNames.append(url.lastPathComponent)
                }
            }
        }
    }

    func extractFilesFromZip(_ url: URL) {
        do {
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            try FileManager.default.unzipItem(at: url, to: destinationURL)

            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                for fileURL in contents {
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) && !isDirectory.boolValue {
                        // Generate a unique filename for audio files
                        let uniqueFilename = UUID().uuidString + "_" + fileURL.lastPathComponent
                        // Construct a new URL with the unique filename
                        let uniqueFileURL = destinationURL.appendingPathComponent(uniqueFilename)
                        // Move the file to the new URL
                        try fileManager.moveItem(at: fileURL, to: uniqueFileURL)
                        // Add the unique file URL to the selectedFiles array
                        selectedFiles.append(uniqueFileURL)
                        audioFileNames.append(uniqueFilename)
                    }
                }
            }
        } catch {
            print("Error unzipping file: \(error)")
        }
    }

}
