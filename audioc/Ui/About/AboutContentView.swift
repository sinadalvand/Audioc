//
//  ContentView.swift
//  audioc
//
//  Created by Sina Dalvand on 10/12/24.
//
import SwiftUI

struct AboutContentView: View {
    
    var appName: String {
        let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
        return name.prefix(1).capitalized + name.dropFirst()
    }
    
    var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        return "Version \(version)"
    }
    
    
    var appDescription: String {
        "🎧 Stay in control!\nThis app keeps your chosen audio input/output locked, even when new devices connect to your Mac."
    }
    
    var copyrightText: String {
        "© 2025 Open Source —"
    }
    
    let viewOnGitHubText = "View on GitHub"
    
    // Replace with your actual repo link!
    let githubURL = URL(string: "https://github.com/sinadalvand/Audioc")!
    
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea()
            VStack {
                if let appIcon = NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 128, height: 128)
                        .cornerRadius(24)
                        .shadow(radius: 10)
                }
                
                Text(appName)
                    .font(.title2)
                    .bold()
                
 
                Text(appVersion)
                    .font(.subheadline)
                    .opacity(0.6)
                
                Text(appDescription)
                    .font(.system(size: 15, weight: .regular, design: .rounded)) // Thin, modern
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(0.8)
                    .padding(.top, 16)
                    .padding(.horizontal, 18)
                
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(copyrightText)
                        .font(.footnote)
                        .opacity(0.4)
                    Link(viewOnGitHubText, destination: githubURL)
                        .font(.footnote)
                        .opacity(0.7)
                }.padding(.bottom, 8)
                
            }
        }
        .frame(width: 300, height: 400)
    }
}
