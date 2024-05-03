//
//  AudioBooksPage.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI
import AVFoundation
import ZIPFoundation

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
    }
    
    private enum CodingKeys: String, CodingKey {
        case book, files, imageData
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.book = try container.decode(Book.self, forKey: .book)
        self.files = try container.decode([FileDetail].self, forKey: .files)
        self.imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(book, forKey: .book)
        try container.encode(files, forKey: .files)
        try container.encodeIfPresent(imageData, forKey: .imageData)
    }
    
    func saveFiles() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(files) {
            UserDefaults.standard.set(encodedData, forKey: "\(id.uuidString)_files")
        }
    }
    
    func loadFiles() {
        if let data = UserDefaults.standard.data(forKey: "\(id.uuidString)_files") {
            let decoder = JSONDecoder()
            if let decodedFiles = try? decoder.decode([FileDetail].self, from: data) {
                files = decodedFiles
            }
        }
    }
}

class LibraryStore: ObservableObject {
    @Published var library: [BookDetail]
    
    init() {
        self.library = LibraryStore.loadLibrary()
        for bookDetail in library {
            bookDetail.loadFiles()
        }
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
        bookDetail.saveFiles()
        saveLibrary()
    }
    
    func removeBook(at index: Int) {
        let bookToRemove = library.remove(at: index)
        UserDefaults.standard.removeObject(forKey: "\(bookToRemove.id.uuidString)_files")
        saveLibrary()
    }
}

struct AudioBooksPage: View {
    @State private var selectedBookDetail: BookDetail?
    @ObservedObject var libraryStore: LibraryStore
    @ObservedObject var imageStore: ImageStore
    @Binding var selectedFiles: [URL]
    @State private var isAddBookViewActive = false
    @State private var selectedBookTitle = ""
    @State private var selectedBookAuthor = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(libraryStore.library) { bookDetail in
                    NavigationLink(destination: BookDetailView(selectedBookDetail: $selectedBookDetail, bookDetail: bookDetail, libraryStore: libraryStore, imageStore: imageStore)) {
                        BookRow(bookDetail: bookDetail)
                    }
                }
                .onDelete { indexSet in
                    libraryStore.removeBook(at: indexSet.first!)
                }
            }
            .navigationTitle("My Library")
            .navigationBarItems(trailing:
                Button(action: {
                    isAddBookViewActive = true
                }) {
                    Image(systemName: "plus.circle")
                }
            )
        }
        .sheet(isPresented: $isAddBookViewActive) {
            NavigationView {
                AddBookView(selectedFiles: $selectedFiles, libraryStore: libraryStore, imageStore: imageStore)
                    .navigationBarItems(leading: Button("Back") {
                        isAddBookViewActive = false
                    })
                    .navigationBarBackButtonHidden(true) // Скрываем стандартную кнопку "Назад"
            }
        }

    }
}


struct BookRow: View {
    var bookDetail: BookDetail
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageData = bookDetail.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 20, height: 25)
            } else {
                Image(systemName: "text.book.closed.fill")
                    .resizable()
                    .frame(width: 20, height: 25)
            }
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


struct BookDetailView: View {
    
    @Binding var selectedBookDetail: BookDetail?
    var bookDetail: BookDetail
    @ObservedObject var libraryStore: LibraryStore
    @ObservedObject var imageStore: ImageStore
    @State private var selectedFile: IdentifiedURL?
    
    @EnvironmentObject var playerInstance: PlayerInstance
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let imageData = bookDetail.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "text.book.closed.fill")
                        .resizable()
                        .frame(width: 20, height: 25)
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
                        self.selectedFile = IdentifiedURL(url: file.fileURL)
                    }) {
                        Text(file.fileName)
                    }
                }
            }
        }
        .padding()
        .navigationTitle(bookDetail.book.title)
        .sheet(item: $selectedFile) { identifiedURL in
            Player(audioURL: .constant(identifiedURL.url), audioFileName: identifiedURL.url.lastPathComponent, selectedBookDetail: $selectedBookDetail, expandSheet: .constant(true), animation: Namespace().wrappedValue)
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
       @State private var showDocumentPicker = false
       @State private var audioFileNames: [String] = [] // Добавляем переменную для имен аудиофайлов
       @Environment(\.presentationMode) var presentationMode
    
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
                Button(action: {
                    showDocumentPicker.toggle()
                }) {
                    Text("Choose Audio Files")
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker(selectedFiles: $selectedFiles, audioFileNames: $audioFileNames)
                }
                
                
                
                ForEach(selectedFiles.indices, id: \.self) { index in
                    Text("\(index + 1). \(selectedFiles[index].lastPathComponent)")
                }
                .onMove { indices, newOffset in
                    selectedFiles.move(fromOffsets: indices, toOffset: newOffset)
                }

                


                
             
            }
            Section {
                Button("Add Book") {
                    if !title.isEmpty && !author.isEmpty && !selectedFiles.isEmpty {
                        // Create a new BookDetail object with selected files
                        let newBook = Book(title: title, author: author)
                        let files: [FileDetail] = selectedFiles.map { FileDetail(fileName: $0.lastPathComponent, fileURL: $0) }
                        let newBookDetail = BookDetail(book: newBook, files: files, imageData: image?.jpegData(compressionQuality: 0.5))
                        // Add the new book to the library
                        libraryStore.addBook(newBookDetail)
                        // Reset all data for adding a new book
                        resetFields()
                        // Закрыть представление при добавлении книги
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Add Book")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image)
        }
        .onAppear {
            // Reset all fields when AddBookView appears
            resetFields()
        }
        .navigationBarBackButtonHidden(false) // Показываем стандартную кнопку "Назад"
    }
    
    // Function to reset all fields
    func resetFields() {
        title = ""
        author = ""
        image = nil
        selectedFiles = []
    }

    func getDefaultImageData() -> Data? {
        guard let defaultImage = UIImage(named: "text.book.closed.fill") else {
            return nil
        }
        return defaultImage.jpegData(compressionQuality: 0.5)
    }

    func move(from source: IndexSet, to destination: Int) {
        selectedFiles.move(fromOffsets: source, toOffset: destination)
    }
    func move(indices: IndexSet, newOffset: Int) {
        selectedFiles.move(fromOffsets: indices, toOffset: newOffset)
    }
}


//struct AddBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddBookView(selectedFiles: .constant([]), libraryStore: LibraryStore(), imageStore: ImageStore(), title: .constant(""), author: .constant(""))
//    }
//}


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

struct IdentifiedURL: Identifiable {
    var id: URL { url }
    let url: URL
}
