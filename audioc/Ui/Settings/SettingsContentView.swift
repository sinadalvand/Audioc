import LaunchAtLogin
//
//  ContentView.swift
//  audioc
//
//  Created by Sina Dalvand on 10/12/24.
//
import SwiftUI

struct SettingsContentView: View {

    // define a state variable to track the auto start status
    @State private var autoStartEnabled: Bool = LaunchAtLogin.isEnabled

    // function to handle the toggle action
    func toggleAutoStart() {
        if autoStartEnabled {
            LaunchAtLogin.isEnabled = false
        } else {
            LaunchAtLogin.isEnabled = true
        }
        autoStartEnabled = LaunchAtLogin.isEnabled
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea()
            VStack {

                // Header with icon and title
                HStack(spacing: 10) {
                    Text("Settings")
                        .font(
                            .system(size: 24, weight: .bold, design: .rounded)
                        )
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
                .padding(.leading, 4)
                
                HStack(alignment: .top) {
                    // Icon and title+description in a VStack
                    Image(systemName: "power")
                        .foregroundColor(autoStartEnabled ? .accentColor : .white)
                        .font(.title2)
                        .padding(.trailing, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto Start")
                            .font(.headline)
                        Text("Start utomatically when you log in.") // description
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                    Spacer()
                    Toggle("", isOn: $autoStartEnabled)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
                .padding(.vertical, 4)
                .padding()
                .onChange(of: autoStartEnabled) {
                    toggleAutoStart()
                }
                
                Spacer()
        
            }
        }
        .frame(width: 300, height: 400)
    }
}

#Preview {
    SettingsContentView()
}
