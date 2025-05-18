import SwiftUI

class AudioDeviceStorage {
    
    private let inputKey = "input"
    private let outputKey = "output"
    
    private var selectedInputDevice: AudioDevice?
    
    private var selectedOutputDevice: AudioDevice?
    
    
    func selectInputDevice(_ device: AudioDevice) {
        self.selectedInputDevice = device
        saveInputPersistently()
    }
    
    func selectOutputDevice(_ device: AudioDevice) {
        self.selectedOutputDevice = device
        saveOutputPersistently()
    }
    
    
    func getSelectedInputDevice() -> AudioDevice? {
        return self.selectedInputDevice
    }
    
    
    func getSelectedOutputDevice() -> AudioDevice? {
        return self.selectedOutputDevice
    }
    
    
    func clearSelectedInputDevice() {
        self.selectedInputDevice = nil
        clearInputPersistently()
    }
    
    func clearSelectedOutputDevice() {
        self.selectedOutputDevice = nil
        clearOutputPersistently()
    }
    
    func savePersistently() {
        if(selectedInputDevice != nil) { saveInputPersistently() }
        if(selectedOutputDevice != nil) { saveOutputPersistently() }
    }
    
    func loadPersistentlySaved() {
        if let savedData1 = UserDefaults.standard.data(forKey: inputKey) {
            if let loadedSelectedInputDevice = try? JSONDecoder().decode(AudioDevice.self, from: savedData1) {
                selectedInputDevice = loadedSelectedInputDevice
            }
        }
        if let savedData2 = UserDefaults.standard.data(forKey: outputKey) {
            if let loadedSelectedOutputDevice = try? JSONDecoder().decode(AudioDevice.self, from: savedData2) {
                selectedOutputDevice = loadedSelectedOutputDevice
            }
        }
    }
    
    private func saveInputPersistently() {
        if let encoded = try? JSONEncoder().encode(selectedInputDevice) {
            UserDefaults.standard.set(encoded, forKey: inputKey)
        }
    }
    
    private func clearInputPersistently() {
        UserDefaults.standard.removeObject(forKey: inputKey)
    }
    
    private func saveOutputPersistently() {
        if let encoded = try? JSONEncoder().encode(selectedOutputDevice) {
            UserDefaults.standard.set(encoded, forKey: outputKey)
        }
    }
    
    private func clearOutputPersistently() {
        UserDefaults.standard.removeObject(forKey: outputKey)
    }
        
    
}
