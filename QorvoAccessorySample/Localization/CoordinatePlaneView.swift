//
//  CoordinatePlaneView.swift
//  DisplayLocation
//
//  Created by Mac_Jangyeon on 1/31/25.
//  SwiftUI를 이용해 간단한 좌표 평면(Canvas)을 그리는 예시
//

import SwiftUI

struct CoordinatePlaneView: View {
    var anchorList: [Point]
    var pointsList: [Point?]
    
    var distanceList: [Float]? = nil
    var displayDistanceCircle: Bool = false
    var toggleGrid: Bool = true
    var toggleAxis: Bool = true
    
    var scale: Float = 1.0
    var offsetX: Float = 0.0
    var offsetY: Float = 0.0
    
    // 색상 목록
    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .gray, .black]
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // 1) min/max 계산
                let allPoints = anchorList + pointsList.compactMap{ $0 }
                var minVal: Float = -1
                var maxVal: Float = 5
                if !allPoints.isEmpty {
                    let localMax = allPoints.map { Swift.max($0.x, $0.y) }.max() ?? 5
                    let localMin = allPoints.map { Swift.min($0.x, $0.y) }.min() ?? -1
                    // 1단계 여유
//                    minVal = floor(localMin) - 1
                    maxVal = ceil(localMax) + 1
                }
                let step = Int(maxVal - minVal)
                
                let baseScale = Float(size.width) / (maxVal - minVal)
                let finalScale = baseScale * scale
                
                // 실제 캔버스에서의 원점(행렬) 위치
                let originX = -minVal * finalScale + offsetX
                let originY = Float(size.height) + minVal * finalScale + offsetY
                
                // 2) 그리드
                if toggleGrid {
                    for i in 0...step {
                        let fi = Float(i)
                        // 수직선
                        let x = (minVal + fi) * finalScale + originX
                        var pathV = Path()
                        pathV.move(to: CGPoint(x: CGFloat(x), y: 0))
                        pathV.addLine(to: CGPoint(x: CGFloat(x), y: size.height))
                        context.stroke(pathV, with: .color(.gray.opacity(0.3)))
                        
                        // 수평선
                        let y = originY - (minVal + fi) * finalScale
                        var pathH = Path()
                        pathH.move(to: CGPoint(x: 0, y: CGFloat(y)))
                        pathH.addLine(to: CGPoint(x: size.width, y: CGFloat(y)))
                        context.stroke(pathH, with: .color(.gray.opacity(0.3)))
                    }
                }
                
                // 3) 축
                if toggleAxis {
                    // X축
                    var xAxis = Path()
                    xAxis.move(to: CGPoint(x: 0, y: CGFloat(originY)))
                    xAxis.addLine(to: CGPoint(x: size.width, y: CGFloat(originY)))
                    context.stroke(xAxis, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 2))
                    
                    // Y축
                    var yAxis = Path()
                    yAxis.move(to: CGPoint(x: CGFloat(originX), y: 0))
                    yAxis.addLine(to: CGPoint(x: CGFloat(originX), y: size.height))
                    context.stroke(yAxis, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 2))
                }
                
                // 4) 앵커 표시 (빨간 점 + 거리 원)
                for (i, anchor) in anchorList.enumerated() {
                    let ax = anchor.x * finalScale + originX
                    let ay = originY - anchor.y * finalScale
                    let center = CGPoint(x: CGFloat(ax), y: CGFloat(ay))
                    
                    // anchor dot
                    let anchorDot = Path(ellipseIn: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))
                    context.fill(anchorDot, with: .color(.red))
                    
                    // distance circle (옵션)
                    if displayDistanceCircle, let distArr = distanceList, i < distArr.count {
                        let radius = CGFloat(distArr[i]) * CGFloat(finalScale)
                        var circlePath = Path()
                        circlePath.addEllipse(in: CGRect(
                            x: center.x - radius,
                            y: center.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        ))
                        context.stroke(circlePath, with: .color(.gray), style: StrokeStyle(lineWidth: 1))
                    }
                }
                
                // 5) pointsList
                for (index, p) in pointsList.compactMap({$0}).enumerated() {
                    let px = p.x * finalScale + originX
                    let py = originY - p.y * finalScale
                    let pt = CGPoint(x: CGFloat(px), y: CGFloat(py))
                    
                    let color = colors.indices.contains(index) ? colors[index] : .black
                    var circlePath = Path()
                    circlePath.addEllipse(in: CGRect(x: pt.x - 5, y: pt.y - 5, width: 10, height: 10))
                    context.fill(circlePath, with: .color(color))
                }
            }
        }
    }
}

struct CoordinatePlaneView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatePlaneView(
            anchorList: [
                Point(x: 0, y: 0),
                Point(x: 5, y: 0),
                Point(x: 3, y: 4)
            ],
            pointsList: [
                Point(x: 2, y: 1),
                nil,
                Point(x: 4, y: 2)
            ],
            distanceList: [3.0, 2.5, 4.2],
            displayDistanceCircle: true
        )
        .frame(width: 400, height: 300)
        .background(Color.white)
    }
}
