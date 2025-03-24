//
//  DetailScreen.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 2/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI
import ARKit
import RealityKit
import simd

struct DeploymentView: View {
    @ObservedObject var uwbViewModel: MyUWBViewModel
    @StateObject var arViewModel = ARViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Top bar: 검정색 바에 뒤로가기 버튼
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color.black)
            
            Spacer()
            ZStack(alignment: .bottom) {
                            // ARViewContainer를 전체 화면으로 표시
                ARViewContainer(arViewModel: arViewModel, uwbViewModel: uwbViewModel)
                                .edgesIgnoringSafeArea(.all)
                
                            // 화면 하단에 VIO 좌표를 텍스트로 오버레이하여 표시
                VStack{
                    Text(String(format: "VIO 좌표: (%.2f, %.2f, %.2f)",
                                arViewModel.position.x,
                                arViewModel.position.y,
                                arViewModel.position.z))
                }
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.bottom, 20)
                        }
            Spacer()
        }
        .onAppear {
            uwbViewModel.arViewModel = self.arViewModel
            uwbViewModel.inDeploymentMode = true
        }
        .onDisappear{
            uwbViewModel.arViewModel = nil
            uwbViewModel.inDeploymentMode = false
        }
    }
}

class ARViewModel: ObservableObject {
    @Published var position: SIMD3<Float> = .zero
    @Published var virtualAnchors: [VirtualAnchor] = []
    
    
}

// ARView를 SwiftUI에 통합하여 AR 세션을 실행하는 UIViewRepresentable
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel
    @ObservedObject var uwbViewModel: MyUWBViewModel
    
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        // 환경 설정 (예: gravity 기반 world alignment)
        configuration.worldAlignment = .gravity
        arView.session.run(configuration)
        // ARSessionDelegate를 할당하여 매 프레임마다 업데이트 받음
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 필요 시 업데이트 처리 (현재는 별도 처리 없음)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(arViewModel: arViewModel, uwbViewModel: uwbViewModel)
    }
    
    // ARSessionDelegate를 구현하여 카메라의 위치 정보를 업데이트
    class Coordinator: NSObject, ARSessionDelegate {
        var arViewModel: ARViewModel
        var uwbViewModel: MyUWBViewModel
        
        init(arViewModel: ARViewModel, uwbViewModel: MyUWBViewModel) {
            self.arViewModel = arViewModel
            self.uwbViewModel = uwbViewModel
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // ARFrame의 카메라 transform에서 위치(translation) 추출
            let transform = frame.camera.transform
            let position = SIMD3<Float>(transform.columns.3.x,
                                        transform.columns.3.y,
                                        transform.columns.3.z)
            // UI 업데이트는 메인 스레드에서 진행
            DispatchQueue.main.async {
                self.arViewModel.position = position
            }
        }
    }
}
