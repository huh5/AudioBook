//
//  UploadFilePage.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//

import SwiftUI


struct UploadFilePage: View {
    @State private var expandSheet = false
    @State private var showSecondView = false
    @State private var selectedFiles: [URL] = []
    var body: some View {
        
        NavigationView{
            ZStack{
                VStack{
                  
                    HStack(alignment:.center, spacing: 30){
                        Image("Vector")
                        
                        Text("File upload")
                            .font(
                                Font.custom("Zen Maru Gothic", size: 26)
                                    .weight(.bold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 30, alignment: .center)
                        Image("More")
                    }
                    Spacer()
                        .frame(height: 750)
                }
                
                
                ZStack{
                    
                    VStack(spacing: 15){
                        
                        
                        Image(systemName: "icloud.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 107, height: 95.50034)
                            .foregroundColor(.gray)
                        NavigationLink(destination: AddBookView(selectedFiles: $selectedFiles, libraryStore: LibraryStore(), imageStore: ImageStore(), musicButtonData: MusicButtonData(selectedFiles: selectedFiles))) {


                            Text("Upload")
                                .frame(width: 150, height: 50)

                                .foregroundColor(.white)
                                .background(.gray)
                                .cornerRadius(15)
                        }
                        
                        
                        HStack(alignment: .center, spacing: 0){
                            Text("Supported format: Zip files, MP3")
                                .font(Font.custom("Zen Maru Gothic", size: 12))
                                .foregroundColor(.white)
                                .frame(width: 194, height: 17, alignment: .topLeading)
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 15)
                        .padding(.top, 18)
                        .padding(.bottom, 15)
                        .frame(height: 50, alignment: .trailing)
                        .background(.white.opacity(0.33))
                        
                        .cornerRadius(11)
                    }
                    
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 294, height: 272)
                    //                .background(
                    //                    LinearGradient(
                    //                        stops: [
                    //                            Gradient.Stop(color: .black.opacity(0), location: 0.00),
                    //                            Gradient.Stop(color: Color(red: 0.77, green: 0.27, blue: 0.41), location: 0.78),
                    //                            Gradient.Stop(color: Color(red: 0.77, green: 0.27, blue: 0.41).opacity(0.99), location: 1.00),
                    //                            Gradient.Stop(color: Color(red: 0.08, green: 0.03, blue: 0.04).opacity(0), location: 1.00),
                    //                        ],
                    //                        startPoint: UnitPoint(x: 0.5, y: 0.55),
                    //                        endPoint: UnitPoint(x: 0.5, y: 1)
                    //                    )
                    //
                    //
                    //                )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 1, green: 1, blue: 1).opacity(0.98), style: StrokeStyle(lineWidth: 4, dash: [12, 12]))
                        )
                    
                    
                    
                    
                }
                
            }
            
            .navigationBarHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            
            .frame(width: 430, height: 932)
            .background(Color(red: 0.1, green: 0.09, blue: 0.22))
            .ignoresSafeArea()
        }
        
        
    }
    
}
struct UploadFilePage_Previews: PreviewProvider {
    static var previews: some View {
        UploadFilePage()
    }
}
