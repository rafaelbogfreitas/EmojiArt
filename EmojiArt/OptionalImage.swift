//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 27/12/20.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        return Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
