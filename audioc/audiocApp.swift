//
//  audiocApp.swift
//  audioc
//
//  Created by Sina Dalvand on 03/12/24.
//

import AudioToolbox
import CoreAudio
import MacControlCenterUI
import SwiftData
import SwiftUI
import SwiftyBeaver
import Factory


let logger = SwiftyBeaver.self

@main
struct audiocApp: App {
    
    @Environment(\.openWindow) private var openWindow
    
    @Injected(\.audioDeviceController)
    private var audioDeviceController:AudioDeviceController
    
    
    @Injected(\.audioDeviceStorage)
    var audioStorage:AudioDeviceStorage
    
    
    @InjectedObject(\.audioCoordinatorService)
    private var audioCoordinatorService:AudioCoordinatorService
    
    
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        
        MenuBarExtra("Audioc Control Center", systemImage: "waveform") {
            MenuView(
                audioController: audioDeviceController,
                audioStorage:audioStorage,
                outputAudioDevices: $audioCoordinatorService.outputDevices,
                inputAudioDevices: $audioCoordinatorService.inputDevices,
                isMenuPresented: $isMenuPresented,
                onAboutClicked: {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "about")
                },
                onSettingsClicked: {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "settings")
                },
                onExitClicked: {
                    NSApplication.shared.terminate(nil)
                }
            )
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented)
        
        
        Window("About Audioc",id: "about") {
            AboutContentView()
                .background(MovableWindow())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

                 
        Window("Audioc Settings",id: "settings") {
            SettingsContentView()
                .background(MovableWindow())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
    }
    
    @MainActor
    @preconcurrency
    init() {
        let console = ConsoleDestination()
        logger.addDestination(console)
        logger.info("App initialized 🔥")
        
        audioCoordinatorService.start()
        audioCoordinatorService.loadSavedSettings()
    }
    
    
}


