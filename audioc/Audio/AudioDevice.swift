//
//  AudioDevice.swift
//  audioc
//
//  Created by Sina Dalvand on 04/12/24.
//
import CoreAudio

struct AudioDevice : Hashable , Equatable , Codable {
    let deviceID: AudioObjectID
    let deviceName: String
    let isInput: Bool
}

extension AudioDevice: Identifiable {
    
    var id: String {
        String(deviceID)
    }
    
    func isEqual(to other: AudioDevice?) -> Bool {
     return self.id == other?.id
    }
}
