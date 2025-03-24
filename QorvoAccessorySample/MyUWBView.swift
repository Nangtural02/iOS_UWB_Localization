//
//  MyUWBView.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 1/22/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

struct MyUWBView: View {
    @ObservedObject var viewModel : MyUWBViewModel
    var body: some View {
        ZStack(){
            
            VStack{
//                Button(action: {viewModel.doLocalization = true}){
//                    Text("Start Localization")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.pink)
//                        .cornerRadius(8)
//                }.frame(width: 200, height: 100)
                Text("현재 위치: \(viewModel.myString)")
//                Text("주차 위치: \(viewModel.parkPosition?.description ?? "운전 중")")
//                Text("행동거지: \(viewModel.motionState ?? "未知")")
//                ForEach(viewModel.distances.sorted(by: { $0.key < $1.key }), id: \.key) { (deviceID, distance) in
//                    Text("id: \(deviceID), distance: \(distance)")
//                }
//                Text("\(viewModel.getDistanceSum())")
                CoordinatePlaneView(anchorList: viewModel.getAnchorPositions(), pointsList: [viewModel.targetPosition, viewModel.parkPosition], distanceList: viewModel.getDistances(), displayDistanceCircle: true).aspectRatio(1,contentMode: ContentMode.fit)
            }
            
                
        }.alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("확인", role: .cancel) {}
        }
    }
    
    
}

#Preview {
    MyUWBView(viewModel: MyUWBViewModel())
}
