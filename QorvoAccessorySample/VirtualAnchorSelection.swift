//
//  VirtualAnchorSelection.swift
//  Qorvo NI Background
//
//  Created by Mac_Jangyeon on 3/19/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import simd
struct VirtualAnchor{
    let position: SIMD3<Float>
    let distances: [Int: Float]
    
    func description() -> String {
        return String(format: "(%.2f, %.2f, %.2f), ", position.x, position.y, position.z) + "\(distances)"
    }
}

func selectVirtualAnchors(for tagID: Int, from anchorList: [VirtualAnchor], k: Int) -> [VirtualAnchor] {
    // 만약 전체 앵커 수가 k 이하이면 그대로 반환합니다.
    if anchorList.count <= k {
        return anchorList
    }
    
    // 각 앵커의 x, y 좌표를 추출하여 영역 경계 계산
    let xs = anchorList.map { $0.position.x }
    let ys = anchorList.map { $0.position.y }
    guard let xmin = xs.min(), let xmax = xs.max(), let ymin = ys.min(), let ymax = ys.max() else {
        return []
    }
    
    // k개의 클러스터(그리드)를 만들기 위해, 행/열 수를 sqrt(k)의 정수 부분으로 설정
    let gridCount = Int(floor(sqrt(Float(k))))
    var selectedAnchors = [VirtualAnchor]()
    
    // 영역을 gridCount x gridCount로 나눕니다.
    for i in 0..<gridCount {
        for j in 0..<gridCount {
            let xLow = xmin + Float(i) * (xmax - xmin) / Float(gridCount)
            let xHigh = xmin + Float(i + 1) * (xmax - xmin) / Float(gridCount)
            let yLow = ymin + Float(j) * (ymax - ymin) / Float(gridCount)
            let yHigh = ymin + Float(j + 1) * (ymax - ymin) / Float(gridCount)
            
            // 해당 셀 영역 내에 포함되고, tagID에 해당하는 거리 값이 존재하는 앵커들 필터링
            let cellAnchors = anchorList.filter { anchor in
                let x = anchor.position.x
                let y = anchor.position.y
                return x >= xLow && x <= xHigh &&
                       y >= yLow && y <= yHigh &&
                       anchor.distances[tagID] != nil
            }
            
            // 셀 내 앵커들 중, 해당 태그에 대한 distance 값이 가장 작은 앵커 선택
            if let bestAnchor = cellAnchors.min(by: { (a, b) in
                let aDistance = a.distances[tagID] ?? Float.greatestFiniteMagnitude
                let bDistance = b.distances[tagID] ?? Float.greatestFiniteMagnitude
                return aDistance < bDistance
            }) {
                // 중복 선택이 없도록 확인 후 추가
                if !selectedAnchors.contains(where: { $0.position == bestAnchor.position && $0.distances == bestAnchor.distances }) {
                    selectedAnchors.append(bestAnchor)
                }
            }
        }
    }
    
    // 만약 선택된 앵커 수가 k보다 적으면, 아직 선택되지 않은 앵커들 중 추가로 선택 (재귀 호출)
    if selectedAnchors.count < k {
        let remainingAnchors = anchorList.filter { anchor in
            return !selectedAnchors.contains(where: { $0.position == anchor.position && $0.distances == anchor.distances })
        }
        let additionalAnchors = selectVirtualAnchors(for: tagID, from: remainingAnchors, k: k - selectedAnchors.count)
        selectedAnchors.append(contentsOf: additionalAnchors)
    }
    
    // 선택된 앵커 수가 k개를 초과하는 경우, 앞의 k개만 반환 (필요시 정렬 기준을 추가할 수 있음)
    if selectedAnchors.count > k {
        return Array(selectedAnchors.prefix(k))
    }
    
    return selectedAnchors
}
