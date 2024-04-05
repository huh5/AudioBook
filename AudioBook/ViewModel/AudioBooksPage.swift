//
//  AudioBooksPage.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import AVFoundation

class FileDetail: Identifiable, Codable {
    var id = UUID()
    var fileName: String
    var fileURL: URL
    var isDeleted = false
    var player: AVPlayer?

    init(fileName: String, fileURL: URL) {
        self.fileName = fileName
        self.fileURL = fileURL
        self.player = AVPlayer(url: fileURL)
    }

    // MARK: - Codable Conformance

    private enum CodingKeys: String, CodingKey {
        case fileName, fileURL
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.fileURL = try container.decode(URL.self, forKey: .fileURL)
        self.player = AVPlayer(url: fileURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileURL, forKey: .fileURL)
    }
}

struct Book: Identifiable, Codable {
    var id = UUID()
    var title: String
    var author: String
}

class BookDetail: Identifiable, Codable {
    var id = UUID()
    var book: Book
    var files: [FileDetail]
    var imageData: Data?

    init(book: Book, files: [FileDetail], imageData: Data? = nil) {
        self.book = book
        self.files = files
        self.imageData = imageData

        for file in files {
            file.player = AVPlayer(url: file.fileURL)
        }
    }
}
struct IdentifiedURL: Identifiable {
    var id: URL { url }
    let url: URL
}
class LibraryStore: ObservableObject {
    @Published var library: [BookDetail]

    init() {
        self.library = LibraryStore.loadLibrary()
    }

    private static let libraryKey = "Library"

    private static func loadLibrary() -> [BookDetail] {
        if let data = UserDefaults.standard.data(forKey: libraryKey) {
            let decoder = JSONDecoder()
            if let decodedLibrary = try? decoder.decode([BookDetail].self, from: data) {
                return decodedLibrary
            }
        }
        return []
    }

    private func saveLibrary() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(library) {
            UserDefaults.standard.set(encodedData, forKey: Self.libraryKey)
        }
    }

    func addBook(_ bookDetail: BookDetail) {
        library.append(bookDetail)
        saveLibrary()
    }

    func addFiles(to index: Int, files: [FileDetail]) {
        library[index].files.append(contentsOf: files)
        saveLibrary()
    }

    func removeFiles(from index: Int, at indexes: IndexSet) {
        library[index].files.remove(atOffsets: indexes)
        saveLibrary()
    }

    func removeBook(at index: Int) {
        library.remove(at: index)
        saveLibrary()
    }
}

struct AudioBooksPage: View {
    @State private var selectedBookDetail: BookDetail?
    @ObservedObject var libraryStore: LibraryStore
    @ObservedObject var imageStore: ImageStore
    @Binding var selectedFiles: [URL] // Add selectedFiles binding

    var body: some View {
        NavigationView {
            List {
                ForEach(libraryStore.library) { bookDetail in
                    NavigationLink(destination: BookDetailView(selectedBookDetail: $selectedBookDetail, bookDetail: bookDetail, libraryStore: libraryStore, imageStore: imageStore)) {
                        HStack(spacing: 15) {
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .frame(width: 20, height: 25)

                            VStack(alignment: .leading, spacing: 10) {
                                Text(bookDetail.book.title)
                                    .font(.headline)
                                Text(bookDetail.book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    libraryStore.removeBook(at: indexSet.first!)
                }
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddBookView(selectedFiles: $selectedFiles, libraryStore: libraryStore, imageStore: imageStore)) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }
}


struct BookDetailView: View {
    @Binding var selectedBookDetail: BookDetail?
    var bookDetail: BookDetail
    @ObservedObject var libraryStore: LibraryStore
    @ObservedObject var imageStore: ImageStore
    @State private var selectedFile: IdentifiedURL? // Change type to IdentifiedURL

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let imageData = bookDetail.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                Text(bookDetail.book.title)
                    .font(.title)
                Text(bookDetail.book.author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            VStack {
                ForEach(bookDetail.files, id: \.id) { file in
                    Button(action: {
                        self.selectedFile = IdentifiedURL(url: file.fileURL) // Wrap URL in IdentifiedURL
                    }) {
                        Text(file.fileName)
                    }
                }
            }
        }
        .padding()
        .navigationTitle(bookDetail.book.title)
        .sheet(item: $selectedFile) { identifiedURL in // Use item instead of isPresented for dynamic sheet presentation
            Player(audioURL: identifiedURL.url, audioFileName: identifiedURL.url.lastPathComponent, selectedBookDetail: $selectedBookDetail, expandSheet: .constant(true), animation: Namespace().wrappedValue)

        }
    }
}


struct AddBookView: View {
    @Binding var selectedFiles: [URL]
    @ObservedObject var libraryStore: LibraryStore
    @ObservedObject var imageStore: ImageStore
    @State private var title = ""
    @State private var author = ""
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    @ObservedObject var musicButtonData = MusicButtonData()

    var body: some View {
        List {
            Section {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
            }
            Section {
                if let image = image {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.vertical, 10)
                        Spacer()
                        Button(action: {
                            // Clear the image
                            self.image = nil
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Button(action: {
                        isImagePickerPresented = true
                    }, label: {
                        Text("Add Image")
                    })
                }
            }
            Section {
                MusicButtonOpen(data: musicButtonData)
                
                ForEach(musicButtonData.selectedFiles.indices, id: \.self) { index in
                    Button(action: {
                        // No need to add selected files here
                    }) {
                        Text(musicButtonData.selectedFiles[index].lastPathComponent)
                    }
                }
            }
            Section {
                Button("Add Book") {
                    if !self.title.isEmpty && !self.author.isEmpty  {
                        // Create a new BookDetail object with the selected files
                        let newBook = Book(title: self.title, author: self.author)
                        let files: [FileDetail] = musicButtonData.selectedFiles.map { FileDetail(fileName: $0.lastPathComponent, fileURL: $0) }
                        let newBookDetail = BookDetail(book: newBook, files: files, imageData: self.image?.jpegData(compressionQuality: 0.5))
                        // Add the new book to the library
                        self.libraryStore.addBook(newBookDetail)
                        // Reset all data for adding a new book
                        self.title = ""
                        self.author = ""
                        self.image = nil
                        self.selectedFiles = []
                    }
                }
            }
        }
        .navigationTitle("Add Book")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image)
        }
    }
}




           struct AudioBookPage_Previews: PreviewProvider {
               static var previews: some View {
                   AudioBooksPage(libraryStore: LibraryStore(), imageStore: ImageStore(), selectedFiles: .constant([]))
               }
           }

           class ImageStore: ObservableObject {
               @Published var imageData: Data? {
                   didSet {
                       UserDefaults.standard.set(imageData, forKey: "storedImageData")
                   }
               }
               
               init() {
                   self.imageData = UserDefaults.standard.data(forKey: "storedImageData")
               }
           }

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
