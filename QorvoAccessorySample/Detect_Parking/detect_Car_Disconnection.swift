//
//  detect_Car_Disconnection.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 2/7/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
import AVFoundation

final class BluetoothAudioMonitor: ObservableObject {
    @Published var isBluetoothConnected: Bool = false
    // 이전 상태 저장 (기본값: false)
    private var previousBluetoothState: Bool = false

    // 연결 → 해제 이벤트 발생 시 호출할 핸들러 (외부에서 설정 가능)
    var onBluetoothDisconnected: (() -> Void)?

    func startMonitoring() {
        // 오디오 라우트 변경 노티피케이션 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        // 앱 실행 시 초기 상태 업데이트
        updateBluetoothState()
    }

    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        updateBluetoothState()
    }

    // 현재 오디오 출력 목록에서 블루투스 장치 여부를 확인하고,
    // 이전 상태와 비교하여 연결 → 해제 전환이 감지되면 이벤트 핸들러 호출
    private func updateBluetoothState() {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs

        let isBTConnected = outputs.contains { output in
            output.portType == .bluetoothA2DP ||
            output.portType == .bluetoothHFP ||
            output.portType == .bluetoothLE
        }

        DispatchQueue.main.async {
            // 만약 이전에 블루투스 연결 상태였는데 현재 해제되었다면 이벤트 발생
            if self.previousBluetoothState == true && isBTConnected == false {
                self.onBluetoothDisconnected?()
            }
            self.previousBluetoothState = isBTConnected
            self.isBluetoothConnected = isBTConnected
        }
    }
}
