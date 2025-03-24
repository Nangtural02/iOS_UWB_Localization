//
//  MyUWBViewModel.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 1/25/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

class MyUWBViewModel: ObservableObject {
    
    var bluetoothMonitor = BluetoothAudioMonitor()
    var motionMonitor = MotionActivityMonitor()
    @State private var eventTriggered: Bool = false
    @Published var showAlert: Bool = false // Alert 트리거 추가
    @Published var alertMessage: String = "" // Alert 메시지 저장
    
    @Published var myString: String = "init"
    @Published var anchorIDs: [Int] = []
    @Published var distances: [Int: Float] = [:]
    @Published var anchorPositions: [Int: Point] = [:]
    @Published var targetPosition: Point = Point()
    @Published var doLocalization: Bool = false
    @Published var parkPosition: Point? = nil
    @Published var bluetoothState: String?
    @Published var motionState:String? = nil
    @State var inDeploymentMode: Bool = false
    var arViewModel: ARViewModel? = nil
    
    init() {
        self.bluetoothMonitor.onBluetoothDisconnected = {
            DispatchQueue.main.async {
                self.eventTriggered = true
                self.alertMessage = "주차를 감지했습니다. \(self.targetPosition.description)"
                self.parkPosition = self.targetPosition
                print("주차를 감지했습니다. \(self.targetPosition.description)")
                self.showAlert = true
                self.bluetoothState = self.bluetoothMonitor.isBluetoothConnected ? "Connected" : "Disconnected"
            }
        }
        self.motionMonitor.onActivityChange = {
            DispatchQueue.main.async {
                self.motionState = self.motionMonitor.currentActivity
            }
        }
        self.motionMonitor.startMonitoring()
        self.bluetoothMonitor.startMonitoring()
        

    }
    deinit {
        // ViewModel이 해제될 때 (onDestroy 역할)
        bluetoothMonitor.stopMonitoring()
        motionMonitor.stopMonitoring()
    }
    
    
    func updateString(_ string: String){
        self.myString = string
    }
    func updateDistance(from deviceID : Int, distance: Float) {
        if(!anchorIDs.contains(deviceID)){
            DispatchQueue.main.async {
                self.anchorIDs.append(deviceID)
            }
        }
        DispatchQueue.main.async {
            self.distances[deviceID] = distance
        }
    }

    func updateAnchorPosition(from deviceID : Int, position: Point) {
        if(!anchorIDs.contains(deviceID)){
            DispatchQueue.main.async {
                self.anchorIDs.append(deviceID)
            }
        }
        DispatchQueue.main.async {
            self.anchorPositions[deviceID] = position
            //Save in UserDefaults
            let key = "devicePoint_\(deviceID)"
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(position) {
                UserDefaults.standard.set(encoded, forKey: key)
            } else {
                print("Failed to encode Point for device \(deviceID)")
            }
        }
    }
    func getAnchorPosition(_ deviceID: Int) {
        let key = "devicePoint_\(deviceID)"
        if let savedData = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let point = try? decoder.decode(Point.self, from: savedData) {
                DispatchQueue.main.async {
                    self.updateAnchorPosition(from: deviceID, position: point)
                }
            } else {
                print("Failed to decode Point for device \(deviceID)")
            }
        }
    }
    
    func localization(){
//        guard doLocalization else {myString = "Not Localized"; return}
        guard distances.count == 3||distances.count == 4 else { print("Not enough devices"); return }
        
//        targetPosition = calcBy3Side2D(anchorPositions: getAnchorPositions(),
//                                       distances: getDistances()) ?? Point(x:-1,y:-1,z:-1)
        DispatchQueue.main.async {
            self.targetPosition = refinePositionByLevenbergMarquardt(anchorPositions: self.getAnchorPositions(), distances: self.getDistances())
            self.myString = self.targetPosition.description
        }
        
    }
    func getAnchorPositions()->[Point]{
        return anchorIDs.compactMap { anchorPositions[$0] }
    }
    func getDistances()->[Float]{
        return anchorIDs.compactMap { distances[$0] }
    }
    
    func updateVirtualAnchor(){
        guard let arViewModel = self.arViewModel else { return }
        arViewModel.virtualAnchors.append(VirtualAnchor(position: arViewModel.position, distances: self.distances))
        print("update Virtual Anchor \(arViewModel.position.description), \(distances.description)")
    }
}
