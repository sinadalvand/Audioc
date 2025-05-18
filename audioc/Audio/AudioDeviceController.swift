//
//  MediaController.swift
//  audioc
//
//  Created by Sina Dalvand on 04/12/24.
//
import CoreAudio
import AudioToolbox
import CoreAudio
import Foundation
import AppKit

class AudioDeviceController : ObservableObject {
    
    init() {
        logger.info("AudioDeviceController initialized")
    }
    
    // keep last input and output to know change from what to what
    private var lastDefaultOutputDevice: AudioDevice? = nil
    private var lastDefaultInputDevice: AudioDevice? = nil
    
    // define a list of AudioDeviceChangeListenerDelegate
    private var listeners: [AudioDeviceChangeListener] = []
    
    
    func getInputDevices() -> [AudioDevice] {
        return listAudioDevices().filter { $0.isInput }
    }
    
    func getOutputDevices() -> [AudioDevice] {
        return listAudioDevices().filter { !$0.isInput }
    }
    
    func getDefualtInputDevice() -> AudioDevice? {
        return getDefaultInputAudioDevice()
    }
    
    func getDefualtOutputDevice() -> AudioDevice? {
        return getDefualtOutputAudioDevice()
    }
    
    func setDefualtInputDevice(deviceID: AudioDevice) {
        setDefaultAudioDevice(deviceID: deviceID.deviceID, isOutput: false)
    }
    
    func setDefualtOutputDevice(deviceID: AudioDevice) {
        setDefaultAudioDevice(deviceID: deviceID.deviceID, isOutput: true)
    }

    func isAudioDeviceAvailable(deviceID: AudioObjectID) -> Bool {
        return listAudioDevices().contains { $0.deviceID == deviceID }
    }
    
    
    func addListener(_ listener: AudioDeviceChangeListener) {
        listeners.append(listener)
    }
    
    func removeListener(_ listener: AudioDeviceChangeListener) {
        listeners.removeAll{ $0 === listener }
    }

    
    
    func startAudioChangeListening() {
        
        
        // set current input and output
        lastDefaultInputDevice = getDefualtInputDevice()
        lastDefaultOutputDevice = getDefualtOutputDevice()
        
        
        // Listen for changes in the default output device
        var outputAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &outputAddress, DispatchQueue.main) { _, _ in
            self.handleDeviceChange(isOutput: true)
        }

        // Listen for changes in the default input device
        var inputAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &inputAddress, DispatchQueue.main) { _, _ in
            self.handleDeviceChange(isOutput: false)
        }

        
        logger.info("Listening for audio device changes...")
    }

    
    /// Get the list of audio devices
    /// - Returns: List of audio devices
    private func listAudioDevices() -> [AudioDevice]{
        var propertySize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // Get the size of the devices array
        let error = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize
        )
        
        if error != noErr {
            print("Error getting property data size: \(error)")
            return []
        }
        
        // Get the list of device IDs
        let deviceCount = Int(propertySize / UInt32(MemoryLayout<AudioObjectID>.size))
        var devices = [AudioObjectID](repeating: AudioObjectID(), count: deviceCount)
        let result = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &devices
        )
        
        if result != noErr {
            print("Error getting devices: \(result)")
            return []
        }
        
        var parsedDevices = Array<AudioDevice>()
        for device in devices {
            let name = getDeviceName(deviceID: device) ?? "Unknown"
            let isVirtual = self.isAudioDeviceVirtual(deviceID: device)
            if error == noErr && !isVirtual {
                let parsedDevice = AudioDevice(deviceID: device, deviceName: name, isInput: self.isInput(deviceID: device))
                parsedDevices.append(parsedDevice)
            }
        }
        return parsedDevices
    }
    
    
    /// Get the default input device
    /// - Returns: Default input device
    private func getDefaultInputAudioDevice() -> AudioDevice? {
        var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultInputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var deviceID = AudioObjectID(0)
            var propertySize = UInt32(MemoryLayout<AudioObjectID>.size)
            
            // Get the default input device ID
            let status = AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &propertyAddress,
                0,
                nil,
                &propertySize,
                &deviceID
            )
            
            guard status == noErr else {
                print("Error getting default input device ID: \(status)")
                return nil
            }
            
            // Get the name of the device
        let deviceName = getDeviceName(deviceID: deviceID)
        guard status == noErr else {
            print("Error getting device name: \(status)")
            return nil
        }
        
        return AudioDevice(deviceID: deviceID, deviceName: deviceName ?? "Unknown", isInput: true)
        
    }
    
    
    /// Get the default output device
    /// - Returns: Default output device
    private func getDefualtOutputAudioDevice() -> AudioDevice? {
        var propertyAddress = AudioObjectPropertyAddress(
              mSelector: kAudioHardwarePropertyDefaultOutputDevice,
              mScope: kAudioObjectPropertyScopeGlobal,
              mElement: kAudioObjectPropertyElementMain
          )
          
          var deviceID = AudioObjectID(0)
          var propertySize = UInt32(MemoryLayout<AudioObjectID>.size)
          
          // Get the default output device ID
          let status = AudioObjectGetPropertyData(
              AudioObjectID(kAudioObjectSystemObject),
              &propertyAddress,
              0,
              nil,
              &propertySize,
              &deviceID
          )
          
          guard status == noErr else {
              print("Error getting default output device ID: \(status)")
              return nil
          }
          
          // Get the name of the device
          let deviceName = getDeviceName(deviceID: deviceID)
        
            guard status == noErr else {
                print("Error getting device name: \(status)")
                return nil
            }
        
        return AudioDevice(deviceID: deviceID, deviceName: deviceName ?? "Unknown", isInput: false)
    }
    
    
    /// Check if the device is an input device
    /// - Parameter deviceID: Device ID to check
    /// - Returns: True if the device is an input device
    private func isInput(deviceID: AudioObjectID) -> Bool {
        var propertySize: UInt32 = 0

        // Check if the device has input streams
        var inputAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        let inputResult = AudioObjectGetPropertyDataSize(deviceID, &inputAddress, 0, nil, &propertySize)
        let hasInput = (inputResult == noErr && propertySize > 0)

        // Check if the device has output streams
        var outputAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let outputResult = AudioObjectGetPropertyDataSize(deviceID, &outputAddress, 0, nil, &propertySize)
        let hasOutput = (outputResult == noErr && propertySize > 0)

//        // Determine if the device is input, output, or both
//        if hasInput && hasOutput {
//            print("Device \(deviceID) supports both input and output.")
//        } else if hasInput {
//            print("Device \(deviceID) is an input device.")
//        } else if hasOutput {
//            print("Device \(deviceID) is an output device.")
//        } else {
//            print("Device \(deviceID) does not support input or output.")
//        }
        
        return !hasOutput && hasInput
    }
    
    
    /// Set the default audio device
    /// - Parameters: deviceID: Device ID to set as default
    private func setDefaultAudioDevice(deviceID: AudioObjectID, isOutput: Bool) {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: isOutput ? kAudioHardwarePropertyDefaultOutputDevice : kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var device = deviceID
        let result = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            UInt32(MemoryLayout<AudioObjectID>.size),
            &device
        )
        
        if result == noErr {
            print("Successfully set device \(deviceID) as default \(isOutput ? "output" : "input").")
        } else {
            print("Failed to set default device: \(result)")
        }
    }


    /// Handle audio device change (calling listeners)
    /// - Parameter isOutput: True if the change is in the output device
    private func handleDeviceChange(isOutput: Bool) {
        
        let currentInput = getDefualtInputDevice()
        let currentOutput = getDefualtOutputDevice()
        
        let lastDefaultInput = lastDefaultInputDevice
        let lastDefaultOutput = lastDefaultOutputDevice
 
        // for each listener do this
        if(lastDefaultInput?.isEqual(to: currentInput) == false || lastDefaultOutput?.isEqual(to: currentOutput) == false ){
            let oldDevice = isOutput ? lastDefaultOutputDevice : lastDefaultInputDevice
            let newDevice = isOutput ? currentOutput : currentInput
            for listener in listeners {
                listener.onAudioDeviceChanged(oldDevice: oldDevice, newDevice: newDevice)
                if(isOutput){
                    listener.onAudioOutputDeviceChanged(oldDevice: oldDevice, newDevice: newDevice)
                }else{
                    listener.onAudioInputDeviceChanged(oldDevice: oldDevice, newDevice: newDevice)
                }
            }
            
            logger.info("Audio device \(isOutput ? "Output":"Input") changed from \(oldDevice?.deviceName ?? "Unknown") to \(newDevice?.deviceName ?? "Unknown")")
            
            if(isOutput){
                lastDefaultOutputDevice = newDevice
            }else{
                lastDefaultInputDevice = newDevice
            }
        }

    }

    
    /// Check if the device is a virtual device
    /// - Parameter deviceID: Device ID to check
    /// - Returns: True if the device is a virtual device
    private func isAudioDeviceVirtual(deviceID: AudioObjectID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var transportType: UInt32 = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, &transportType)
        
        guard status == noErr else {
            print("Error getting transport type: \(status)")
            return false
        }
        
        // Transport types that typically indicate a virtual device
        let virtualTransportTypes: [UInt32] = [
            kAudioDeviceTransportTypeVirtual,
            kAudioDeviceTransportTypeAggregate,
            kAudioDeviceTransportTypeAutoAggregate
        ]
        
        return virtualTransportTypes.contains(transportType)
    }
    
    
    /// Get the name of the device
    /// - Parameter deviceID: Device ID to get the name of
    /// - Returns: Name of the device
    private func getDeviceName(deviceID: AudioObjectID) -> String? {
        var deviceName: CFString = "" as CFString
          var nameSize = UInt32(MemoryLayout<CFString>.size)
          var nameAddress = AudioObjectPropertyAddress(
              mSelector: kAudioDevicePropertyDeviceNameCFString,
              mScope: kAudioObjectPropertyScopeGlobal,
              mElement: kAudioObjectPropertyElementMain
          )
          
          // Create a buffer to hold the CFString
          let status = withUnsafeMutablePointer(to: &deviceName) { deviceNamePtr -> OSStatus in
              return AudioObjectGetPropertyData(
                  deviceID,
                  &nameAddress,
                  0,
                  nil,
                  &nameSize,
                  deviceNamePtr
              )
          }
          
          // Check if the operation was successful
          guard status == noErr else {
              print("Error getting device name: \(status)")
              return nil
          }
          
          return deviceName as String
    }
}
