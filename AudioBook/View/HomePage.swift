//
//  HomePage.swift
//  AudioBook
//
//  Created by Богдан Ткачивський on 19/03/2024.
//


import SwiftUI

struct HomePage: View {
    @ObservedObject var viewModel: TabSelectionViewModel
    var navigateToAudioBooks: () -> Void
    
    var body: some View {
        ZStack {
            Spacer()
            VStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 430, height: 599)
                    .background(
                        Image("HomePageDraw")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 430, height: 599)
                            .clipped()
                    )
                Spacer()
                    .frame(height: 150)
                Text("collection...\n")
                    .font(Font.custom("Zen Maru Gothic", size: 24))
                    .foregroundColor(.white)
                    .frame(width: 149, height: 30, alignment: .topLeading)
                Spacer()
                Button(action: {
                    navigateToAudioBooks()
                }) {
                    Text("Let’s go")
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .font(Font.custom("Zen Maru Gothic", size: 30))
                        .background(Color(red: 0.77, green: 0.27, blue: 0.41))
                        .cornerRadius(20)
                }
                .padding(.bottom, 20)
                Spacer(minLength: 100)
            }
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 5) {
                Spacer()
                    .frame(height: 350)
                Text("Your very own ")
                    .font(Font.custom("Zen Maru Gothic", size: 24))
                    .foregroundColor(.white)
                    .frame(width: 220, height: 40, alignment: .topLeading)
                Text("Audiobook")
                    .font(Font.custom("Zen Maru Gothic", size: 42).weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 217, height: 53, alignment: .leading)
            }
            .padding(.horizontal, 60)
        }
        .frame(width: 430, height: 932)
        .background(Color(red: 0.1, green: 0.09, blue: 0.22))
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        let tabSelectionViewModel = TabSelectionViewModel()
        HomePage(viewModel: tabSelectionViewModel, navigateToAudioBooks: {})
    }
}
