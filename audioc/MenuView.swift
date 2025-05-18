//
//  MenuView.swift
//  audioc
//
//  Created by Sina Dalvand on 03/12/24.
//

import SwiftUI
import MacControlCenterUI
import MenuBarExtraAccess

struct MenuView: View {
    
    let audioController: AudioDeviceController
    let audioStorage: AudioDeviceStorage
    @Binding var outputAudioDevices: [AudioDevice]
    @Binding var inputAudioDevices: [AudioDevice]
    @Binding var isMenuPresented: Bool
    let onAboutClicked: () -> Void
    let onSettingsClicked: () -> Void
    let onExitClicked: () -> Void
    
    
    @State private var outputDefaultDevice: AudioDevice?
    @State private var inputDefaultDevice: AudioDevice?
    

    
    private func updateSelectedDevices(){
        outputDefaultDevice = audioStorage.getSelectedOutputDevice()
        inputDefaultDevice = audioStorage.getSelectedInputDevice()
    }
    
    var body: some View {
        MacControlCenterMenu(isPresented: Binding.constant(true)) {
            
            MenuSection("Output",divider: false)
            
            MenuList(outputAudioDevices){ item in
                MenuToggle(isOn: .constant(item.deviceID == outputDefaultDevice?.deviceID), image: Image(systemName: "speaker.wave.2.fill")) {
                    HStack {
                        Text(item.deviceName)
                        Spacer()
                        HStack() {
                            let isCurrent = item.deviceID == audioController.getDefualtOutputDevice()?.deviceID
                            if(isCurrent){
                                Text("Current").opacity(0.2)
                            }
                        }
                        .frame(height: 10)
                        .opacity(0.7)
                    }
                    
                } onClick: { _ in
                    let currentSelected = audioStorage.getSelectedOutputDevice()
                    let clickedSelected = item
                    if(currentSelected?.deviceID == clickedSelected.deviceID){
                        audioStorage.clearSelectedOutputDevice()
                        updateSelectedDevices()
                        return
                    }
                    audioStorage.selectOutputDevice(item)
                    audioController.setDefualtOutputDevice(deviceID: item)
                    updateSelectedDevices()
                }
            }
            
            
            MenuSection("Input")
            
            
            MenuList(inputAudioDevices){ item in
                MenuToggle(isOn: .constant(item.deviceID == inputDefaultDevice?.deviceID), image: Image(systemName: "microphone.fill")) {
                    HStack {
                        Text(item.deviceName)
                        Spacer()
                        HStack() {
                            let isCurrent = item.deviceID == audioController.getDefualtInputDevice()?.deviceID
                            if(isCurrent){
                                Text("Current").opacity(0.2)
                            }
                        }
                        .frame(height: 10)
                        .opacity(0.7)
                    }
                } onClick: { _ in
                    let currentSelected = audioStorage.getSelectedInputDevice()
                    let clickedSelected = item
                    if(currentSelected?.deviceID == clickedSelected.deviceID){
                        audioStorage.clearSelectedInputDevice()
                        updateSelectedDevices()
                        return
                    }
                    audioStorage.selectInputDevice(item)
                    audioController.setDefualtInputDevice(deviceID: item)
                    updateSelectedDevices()
                }
            }
            
            
            Divider()
            
            MenuCommand {
                onAboutClicked()
            } label: {
                Text("About") // custom label view
            }
            
            MenuCommand {
                onSettingsClicked()
            } label: {
                Text("Settings") // custom label view
            }
            
            Divider()
            
            MenuCommand("Quit") {
                onExitClicked()
            }
            
        }.onChange(of: isMenuPresented){
//            updateDetails()
        }.onAppear{
            updateSelectedDevices()
        }
    }
  

}
