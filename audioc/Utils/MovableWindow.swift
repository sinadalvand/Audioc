//
//  TransparentWindow.swift
//  audioc
//
//  Created by Sina Dalvand on 17/05/25.
//

import SwiftUI

struct MovableWindow: View {
    
    var body: some View {
        EmptyView().background(WindowAccessor())
    }

    struct WindowAccessor: NSViewRepresentable {
        func makeNSView(context: Context) -> NSView {
            let nsView = NSView()
            DispatchQueue.main.async {
                nsView.window?.isMovableByWindowBackground = true
            }
            return nsView
        }

        func updateNSView(_ nsView: NSView, context: Context) {}
    }
}
