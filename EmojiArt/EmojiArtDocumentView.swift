//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Rafael Freitas on 24/10/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var choosenPallete = ""
    
    var body: some View {
        VStack {
            HStack {
                PalleteChooser(document: document, choosenPallete: $choosenPallete)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(choosenPallete.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag {
                                    return NSItemProvider(object: emoji as NSString)
                                }
                        }
                    }
                }
            }
            .onAppear {
                choosenPallete = document.defaultPalette
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    
                    if isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea([.horizontal,.bottom])
                .onReceive(document.$backgroundImage) { (image) in
                    zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
                
            }
            .navigationBarItems(trailing: Button(action: {
                if let url = UIPasteboard.general.url, url != self.document.backgroundUrl {
                    confirmBackgroundPaste = true
                } else {
                    explainBackgroundPaste = true
                }
            }, label: {
                Image(systemName: "doc.on.clipboard")
                    .imageScale(.large)
                    .alert(isPresented: $explainBackgroundPaste) {
                        return Alert(
                            title: Text("Paste background"),
                            message: Text("Copy the image URL to the clipboard and use this button to paste it"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }))
            .zIndex(-1)
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            return Alert(
                title: Text("Paste background"),
                message: Text("Replace your image background with \(UIPasteboard.general.url?.absoluteString ?? "nothing") ?"),
                primaryButton: .default(Text("OK")){
                    self.document.backgroundUrl = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    var isLoading: Bool {
        document.backgroundUrl != nil && document.backgroundImage == nil
    }
    
    //MARK: - Zoom
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
       MagnificationGesture()
        .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
            gestureZoomScale = latestGestureScale
        }
        .onEnded { finalGestureScale in
            document.steadyStateZoomScale *= finalGestureScale
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image,
           image.size.width > 0,
           image.size.height > 0,
           size.height > 0,
           size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    //MARK: - Pan
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { (latestDragGestureValue, gesturePanOffset, transaction) in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragState in
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragState.translation / zoomScale)
            }
    }
 
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2 )
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            document.backgroundUrl = url
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


