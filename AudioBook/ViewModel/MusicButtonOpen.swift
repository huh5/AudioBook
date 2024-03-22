//
//  MusicButtonOpen.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//
// Your corrected code goes here
import SwiftUI
import AVFoundation

class MusicButtonData: ObservableObject {
    @Published var selectedFiles: [URL]

    init(selectedFiles: [URL] = []) {
        self.selectedFiles = selectedFiles
    }

    func addFiles(urls: [URL]) {
        print("Adding files: \(urls)")
        self.selectedFiles.append(contentsOf: urls)
    }
}

struct MusicButtonOpen: View {
    @ObservedObject var data: MusicButtonData
    @State private var showDocumentPicker = false

    var body: some View {
        VStack {
            Button(action: { showDocumentPicker.toggle() }) {
                Text("Выбрать аудиофайлы")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(width: 200)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(data: data) // Pass MusicButtonData here
        }
    }
}

// Update DocumentPicker to use MusicButtonData
struct DocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var data: MusicButtonData

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .open)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Call addFiles on MusicButtonData
            parent.data.addFiles(urls: urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Optional: handle document picker cancellation
        }
    }
}
