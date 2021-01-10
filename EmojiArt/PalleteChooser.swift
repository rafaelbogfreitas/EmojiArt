//
//  PalleteChooser.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 09/01/21.
//

import SwiftUI

struct PalleteChooser: View {
    
    @ObservedObject var document: EmojiArtDocument
    @Binding var choosenPallete: String
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    self.choosenPallete = self.document.palette(after: choosenPallete)
                },
                onDecrement: {
                    self.choosenPallete = self.document.palette(before: choosenPallete)
                },
                label: {
                    EmptyView()
                })
            
            Text(self.document.paletteNames[self.choosenPallete] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PalleteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PalleteChooser(document: EmojiArtDocument(), choosenPallete: Binding.constant(""))
    }
}
