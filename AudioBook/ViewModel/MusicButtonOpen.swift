//
//  MusicButtonOpen.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI

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
    @State private var showDocumentPicker = false // Add state variable to control sheet presentation

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
        .sheet(isPresented: $showDocumentPicker) { // Use $showDocumentPicker to bind to state variable
            DocumentPicker(data: self.data)
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var data: MusicButtonData // Remove Binding

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
            print("Document picker did pick documents: \(urls)")
            // Call addFiles on MusicButtonData
            parent.data.addFiles(urls: urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Optional: handle document picker cancellation
        }
    }
}
