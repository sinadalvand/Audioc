//
//  DependencyContainer.swift
//  audioc
//
//  Created by Sina Dalvand on 21/02/25.
//
import Factory

extension Container {
    
    
    var audioDeviceController: Factory<AudioDeviceController> {
        self{ AudioDeviceController() }.singleton
    }
    
    var audioDeviceStorage: Factory<AudioDeviceStorage> {
        self{ AudioDeviceStorage() }.singleton
    }
    
    var audioCoordinatorService: Factory<AudioCoordinatorService> {
        self { AudioCoordinatorService(audioStore: self.audioDeviceStorage(), audioDeviceController: self.audioDeviceController()) }.singleton
    }

}
