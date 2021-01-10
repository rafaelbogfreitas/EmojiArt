//
//  PalleteChooser.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 09/01/21.
//

import SwiftUI

struct PalleteChooser: View {
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {  },
                onDecrement: {  },
                label: {
                    EmptyView()
                })
            
            Text("Pallete name")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PalleteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PalleteChooser()
    }
}
