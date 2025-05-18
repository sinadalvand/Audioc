//
//  TransparentWindow.swift
//  audioc
//
//  Created by Sina Dalvand on 17/05/25.
//

import SwiftUI

struct TransparentWindow: View {
    var body: some View {
        EmptyView()
            .background(WindowAccessor())
    }

    struct WindowAccessor: NSViewRepresentable {
        func makeNSView(context: Context) -> NSView {
            DispatchQueue.main.async {
                if let window = NSApp.windows.first {
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.titlebarAppearsTransparent = true
                    window.hasShadow = false // Optional
                    
                    window.styleMask.remove(.resizable)
                    window.isMovableByWindowBackground = true
                }
            }
            return NSView()
        }

        func updateNSView(_ nsView: NSView, context: Context) {}
    }
}
