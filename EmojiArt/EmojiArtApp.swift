//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 24/10/20.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let store: EmojiArtDocumentStore = EmojiArtDocumentStore(named: "Emoji Art")
    var body: some Scene {
        
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
        }
    }
}
