//
//  WindowAccessor.swift
//  audioc
//
//  Created by Sina Dalvand on 23/03/25.
//

import SwiftUI


struct WindowAccessor: NSViewRepresentable {
    // Callback that passes the NSWindow reference.
    var callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        // Use DispatchQueue.main.async to ensure the window is available.
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
        return nsView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) { }
}
