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
    @State private var showPalleteEditor: Bool = false
    
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
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPalleteEditor = true
                }
                .popover(isPresented: $showPalleteEditor) {
                    PalleteEditor(choosenPallete: $choosenPallete)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}


struct PalleteEditor: View {
    @Binding var choosenPallete: String
    @EnvironmentObject var document: EmojiArtDocument
    @State var palleteName: String = ""
    @State var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text("PalleteEditor").font(.title).padding()
            Divider()
            Form {
                Section(header: Text("Pallete name")) {
                    TextField("Pallete name", text: $palleteName, onEditingChanged: { began in
                        if !began {
                            document.renamePalette(choosenPallete, to: palleteName)
                        }
                    })
                    TextField("Add emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            choosenPallete = document.addEmoji(emojisToAdd, toPalette: choosenPallete)
                            emojisToAdd = ""
                        }
                    })
                }
                
                Section(header: Text("Remove Emoji")) {
                    VStack {
                        ForEach(emojisToAdd.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .onTapGesture {
                                    choosenPallete = document.removeEmoji(emoji, fromPalette: choosenPallete)
                                }
                        }
                    }
                }
                
            }
            Spacer()
        }
        .onAppear {
            palleteName = document.paletteNames[choosenPallete] ?? ""
        }
    }
}



struct PalleteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PalleteChooser(document: EmojiArtDocument(), choosenPallete: Binding.constant(""))
    }
}
