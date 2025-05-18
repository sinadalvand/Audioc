//
//  AudioDeviceChangeListenerCallback.swift
//  audioc
//
//  Created by Sina Dalvand on 20/02/25.
//

protocol AudioDeviceChangeListener : AnyObject {
    
    func onAudioDeviceChanged(oldDevice: AudioDevice?, newDevice: AudioDevice?)
    
    func onAudioInputDeviceChanged(oldDevice: AudioDevice?, newDevice: AudioDevice?)
    
    func onAudioOutputDeviceChanged(oldDevice: AudioDevice?, newDevice: AudioDevice?)
}
