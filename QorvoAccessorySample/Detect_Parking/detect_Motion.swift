//
//  detect_Motion.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 2/9/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
import CoreMotion

struct MotionStatusView: View {
    @StateObject private var motionMonitor = MotionActivityMonitor()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("현재 모션 상태")
                .font(.headline)
            Text(motionMonitor.currentActivity)
                .font(.largeTitle)
                .foregroundColor(.blue)
        }
        .padding()
        .onAppear {
            motionMonitor.startMonitoring()
        }
        .onDisappear {
            motionMonitor.stopMonitoring()
        }
    }
}

final class MotionActivityMonitor: ObservableObject {
    @Published var currentActivity: String = "Unknown"
    
    var onActivityChange: (() -> Void)?
    
    private let activityManager = CMMotionActivityManager()
    private var isMonitoring: Bool = false
    
    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            currentActivity = "모션 감지 기능이 지원되지 않습니다."
            return
        }
        
        isMonitoring = true
        
        activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] activity in
            guard let activity = activity, let self = self else { return }
            DispatchQueue.main.async {
                // 우선 순위에 따라 모션 상태를 결정 (운전 > 도보 > 정지 > 기타)
                if activity.automotive {
                    self.currentActivity = "Driving"
                } else if activity.walking {
                    self.currentActivity = "Walking"
                } else if activity.running {
                    self.currentActivity = "Running"
                } else if activity.stationary {
                    self.currentActivity = "Stationary"
                } else {
                    self.currentActivity = "Unknown"
                }
                self.onActivityChange?()
            }
        }
    }
    
    func stopMonitoring() {
        if isMonitoring {
            activityManager.stopActivityUpdates()
            isMonitoring = false
        }
    }
}

struct MotionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        MotionStatusView()
    }
}
