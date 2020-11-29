//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 24/10/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) {
                        Text($0)
                            .font(Font.system(size: defaultEmojiSize))
                    }
                }
            }
            .padding(.horizontal)
            Rectangle()
                .foregroundColor(Color.white).overlay(
                   Group {
                        if document.backgroundImage != nil {
                            Image(uiImage: document.backgroundImage!)
                        }
                        
                    }
                )
                .edgesIgnoringSafeArea([.horizontal,.bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    
                    drop(providers: providers)
                }
        }
    }
    
    private func drop(providers: [NSItemProvider]) -> Bool {
        let found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            document.setBackgroundURL(url)
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
