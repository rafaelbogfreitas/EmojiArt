//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 24/10/20.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable {

    let id: UUID
    var defaultKey: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    static let palette: String = "🤥😶🤢🤒😈👿🤡💀☠️"
    
    @Published var emojiArt: EmojiArt
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    var cancellable: AnyCancellable?
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        self.defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        cancellable = $emojiArt.sink { (emojiArt) in
            UserDefaults.standard.set(emojiArt.json, forKey: self.defaultKey)
        }
        fetchBackgroundImageData()
    }
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    //MARK: - Intents
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundUrl: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { data, urlError in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                
            fetchImageCancellable = publisher.assign(to: \.backgroundImage, on: self)
        }
    }
}

