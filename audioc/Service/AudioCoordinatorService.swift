//
//  AudioCoordinator.swift
//  audioc
//
//  Created by Sina Dalvand on 20/02/25.
//
import Combine
import Foundation
import CoreAudio

class AudioCoordinatorService  : ObservableObject , AudioDeviceChangeListener {
    
    // is responsible to store selected input and output
    // but here we just gonna use it for getting stuff.
    private var audioStore: AudioDeviceStorage
    
    
    // responsible to detect Audio Device Changes
    private var audioDeviceController: AudioDeviceController
    
    
    @Published var outputDevices: [AudioDevice] = []
    @Published var inputDevices: [AudioDevice] = []
    
    
    init(audioStore: AudioDeviceStorage , audioDeviceController: AudioDeviceController) {
        self.audioStore = audioStore
        self.audioDeviceController = audioDeviceController
        self.audioDeviceController.addListener(self)
        updateDevices()
    }
    
    deinit {
        // remove this class from change listener
        self.audioDeviceController.removeListener(self)
    }
    
    
    func start(){
        audioDeviceController.startAudioChangeListening()
    }
    
    func loadSavedSettings(){
        audioStore.loadPersistentlySaved()
        let selectedOutput = audioStore.getSelectedOutputDevice()
        let selectedInput = audioStore.getSelectedInputDevice()
        
        if(selectedOutput != nil && audioDeviceController.isAudioDeviceAvailable(deviceID: selectedOutput!.deviceID)){
            logger.info("Set Output from storage : \(selectedOutput?.deviceName ?? "Unknown")")
            audioDeviceController.setDefualtOutputDevice(deviceID: selectedOutput!)
        }
        
        if(selectedInput != nil && audioDeviceController.isAudioDeviceAvailable(deviceID: selectedInput!.deviceID)){
            logger.info("Set Input from storage : \(selectedInput?.deviceName ?? "Unknown")")
            audioDeviceController.setDefualtInputDevice(deviceID: selectedInput!)
        }
        
        updateDevices()
    }
    
    private func updateDevices(){
        self.outputDevices = audioDeviceController.getOutputDevices()
        self.inputDevices = audioDeviceController.getInputDevices()
    }
    
    func onAudioDeviceChanged(oldDevice: AudioDevice?, newDevice: AudioDevice?) {
        updateDevices()
    }
    
    func onAudioInputDeviceChanged(oldDevice: AudioDevice?, newDevice: AudioDevice?) {
        let selectedInput = audioStore.getSelectedInputDevice()
        let isDifferent = selectedInput?.isEqual(to: oldDevice) ?? false
        let isStillAvailable = audioDeviceController.isAudioDeviceAvailable(deviceID: selectedInput?.deviceID ?? 0)
        
        if (isDifferent && isStillAvailable && selectedInput != nil){
            guard let selectedInput = selectedInput else { return }
            audioDeviceController.setDefualtInputDevice(deviceID: selectedInput)
            logger.info("Audio Input Device Changed: \(oldDevice?.deviceName ?? "Unknown") -> \(newDevice?.deviceName ?? "Unknown")")
        }
    }
    
    func onAudioOutputDeviceChanged(oldDevice: AudioDevice?, newDevice: AudioDevice?) {
        
        let selectedOutput = audioStore.getSelectedOutputDevice()
        let isDifferent = selectedOutput?.isEqual(to: oldDevice) ?? false
        let isStillAvailable = audioDeviceController.isAudioDeviceAvailable(deviceID: selectedOutput?.deviceID ?? 0)
        
        if (isDifferent && isStillAvailable && selectedOutput != nil){
            guard let selectedOutput = selectedOutput else { return }
            audioDeviceController.setDefualtOutputDevice(deviceID: selectedOutput)
            logger.info("Audio Output Device Changed: \(oldDevice?.deviceName ?? "Unknown") -> \(newDevice?.deviceName ?? "Unknown")")
        }
    }
    
    
}
