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
                .foregroundColor(Color.yellow)
                .edgesIgnoringSafeArea([.horizontal,.bottom])
        }
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
