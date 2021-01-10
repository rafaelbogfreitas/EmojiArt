//
//  EmojiArtDocumen+Pallete.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 10/01/21.
//

import Foundation

extension EmojiArtDocument {
    private static var PalletesKey = "EmojiArtDocument.PalletesKey"
    
    private(set) var palleteNames: [String: String] {
        get {
            UserDefaults.standard.object(forKey: EmojiArtDocument.PalletesKey) as? [String: String] ?? [
                "😀😃😄😁😆😅😂🤣☺️😊😇🙂🙃😉😌😍": "faces",
                "🍏🍎🍐🍊🍋🍌🍉🍇🍓🍈🍒🍑🥭🍍🥥🥝🍅🍆🥑🥦🥬🥒🌶🌽": "food",
                "⌚️📱📲💻⌨️🖥🖨🖱🖲🕹🗜💽💾💿📀📼📷📸📹🎥": "objects"
                
            ]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: EmojiArtDocument.PalletesKey)
            objectWillChange.send()
        }
    }
    
    var sortedPalletes: [String] {
        palleteNames.keys.sorted(by: { palleteNames[$0]! < palleteNames[$1]! })
    }
    
    var defaultPalletes: String {
        sortedPalletes.first ?? "⚠️"
    }
    
    func renamePallete(_ pallete: String, to name: String) {
        palleteNames[pallete] = name
    }
    
    func addPallete(_ pallete: String, named name: String) {
        palleteNames[name] = pallete
    }
    
    func removePallete(named name: String) {
        palleteNames[name] = nil
    }
}
