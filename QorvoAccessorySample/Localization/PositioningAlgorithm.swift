//
//  PositioningAlgorithm.swift
//  DisplayLocation
//
//  Created by Mac_Jangyeon on 1/31/25.
//
//  PositioningAlgorithms.swift
//
//  - Point(x,y,z)
//  - calcBy3Side2D (삼변측량)
//  - 가우스-뉴턴 (refinePositionByGaussNewton)
//  - 레벤버그-마콰르트 (refinePositionByLevenbergMarquardt)
//

import Foundation

// MARK: - Point
struct Point: CustomStringConvertible, Codable {
    var x: Float
    var y: Float
    var z: Float
    
    init(x: Float = 0, y: Float = 0, z: Float = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func distance(to p: Point) -> Float {
        let dx = x - p.x
        let dy = y - p.y
        let dz = z - p.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    var description: String {
        String(format: "(%.2f, %.2f, %.2f)", x, y, z)
    }
}

// dot product (벡터 내적)
func dot(_ a: [Float], _ b: [Float]) -> Float {
    guard a.count == b.count else { return 0 }
    var s: Float = 0
    for i in 0..<a.count {
        s += a[i] * b[i]
    }
    return s
}

// MARK: - 삼변측량 (2D)
func calcBy3Side2D(anchorPositions: [Point], distances: [Float]) -> Point? {
    guard anchorPositions.count >= 3, distances.count >= 3 else { return nil }
    
    let A0 = anchorPositions[0]
    let A1 = anchorPositions[1]
    let A2 = anchorPositions[2]
    let d0 = distances[0]
    let d1 = distances[1]
    let d2 = distances[2]
    
    let x0 = A0.x, y0 = A0.y
    let x1 = A1.x, y1 = A1.y
    let x2 = A2.x, y2 = A2.y
    
    // 식 전개 (안드로이드 calcBy3Side)
    let eq1A = 2*(x1 - x0)
    let eq1B = 2*(y1 - y0)
    let eq1C = (x0*x0 - x1*x1) + (y0*y0 - y1*y1) + (d1*d1 - d0*d0)
    
    let eq2A = 2*(x2 - x0)
    let eq2B = 2*(y2 - y0)
    let eq2C = (x0*x0 - x2*x2) + (y0*y0 - y2*y2) + (d2*d2 - d0*d0)
    
    let M = [
        [eq1A, eq1B],
        [eq2A, eq2B]
    ]
    let v = [-eq1C, -eq2C]
    
    guard let invM = invertMatrix(M) else {
        return nil
    }
    let xy = multiplyMatrixVector(invM, v)
    if xy.count < 2 { return nil }
    
    return Point(x: xy[0], y: xy[1], z: 0)
}

// MARK: - 가우스-뉴턴
func refinePositionByGaussNewton(
    anchorPositions: [Point],
    distances: [Float],
    initialGuess: Point = Point(),
    maxIterations: Int = 50,
    tolerance: Float = 1e-3
) -> Point {
    guard anchorPositions.count == distances.count,
          anchorPositions.count >= 3 else {
        return initialGuess
    }
    
    var estimate = initialGuess
    
    for _ in 0..<maxIterations {
        let n = anchorPositions.count
        
        // residual
        var residuals = [Float](repeating: 0, count: n)
        for i in 0..<n {
            let dEst = estimate.distance(to: anchorPositions[i])
            residuals[i] = dEst - distances[i]
        }
        
        // 자코비안 (n x 3)
        var J = [[Float]](repeating: [0,0,0], count: n)
        for i in 0..<n {
            let distEst = estimate.distance(to: anchorPositions[i])
            if distEst < 1e-9 {
                J[i] = [0,0,0]
            } else {
                let dx = (estimate.x - anchorPositions[i].x)/distEst
                let dy = (estimate.y - anchorPositions[i].y)/distEst
                let dz = (estimate.z - anchorPositions[i].z)/distEst
                J[i] = [dx, dy, dz]
            }
        }
        
        let JT = transposeMatrix(J)       // (3 x n)
        let JTJ = multiplyMatrixMatrix(JT, J) // (3 x 3)
        guard let JTJinv = invertMatrix(JTJ) else {
            break
        }
        let JTres = multiplyMatrixVector(JT, residuals) // (3)
        
        // delta = -(JTJinv * JTres)
        let delta = multiplyMatrixVector(JTJinv, JTres).map { -$0 }
        
        let newEstimate = Point(
            x: estimate.x + delta[0],
            y: estimate.y + delta[1],
            z: estimate.z + delta[2]
        )
        let moveDist = estimate.distance(to: newEstimate)
        estimate = newEstimate
        
        if moveDist < tolerance {
            break
        }
    }
    return estimate
}

// MARK: - 레벤버그-마콰르트
func refinePositionByLevenbergMarquardt(
    anchorPositions: [Point],
    distances: [Float],
    initialGuess: Point = Point(),
    maxIterations: Int = 50,
    tolerance: Float = 1e-3,
    initialLambda: Float = 1e-3
) -> Point {
    guard anchorPositions.count == distances.count,
          anchorPositions.count >= 3 else {
        return initialGuess
    }
    
    var estimate = initialGuess
    var lambda = initialLambda
    
    for _ in 0..<maxIterations {
        let n = anchorPositions.count
        
        // residual
        var residuals = [Float](repeating: 0, count: n)
        for i in 0..<n {
            let dEst = estimate.distance(to: anchorPositions[i])
            residuals[i] = dEst - distances[i]
        }
        let costOld = dot(residuals, residuals)
        
        // 자코비안
        var J = [[Float]](repeating: [0,0,0], count: n)
        for i in 0..<n {
            let distEst = estimate.distance(to: anchorPositions[i])
            if distEst < 1e-9 {
                J[i] = [0,0,0]
            } else {
                let dx = (estimate.x - anchorPositions[i].x)/distEst
                let dy = (estimate.y - anchorPositions[i].y)/distEst
                let dz = (estimate.z - anchorPositions[i].z)/distEst
                J[i] = [dx, dy, dz]
            }
        }
        
        let JT = transposeMatrix(J)
        var JTJ = multiplyMatrixMatrix(JT, J)
        let JTres = multiplyMatrixVector(JT, residuals)
        
        // (JTJ + lambda*I)
        for i in 0..<3 {
            JTJ[i][i] += lambda
        }
        
        guard let invDamped = invertMatrix(JTJ) else {
            break
        }
        let delta = multiplyMatrixVector(invDamped, JTres).map { -$0 }
        
        let candidate = Point(
            x: estimate.x + delta[0],
            y: estimate.y + delta[1],
            z: estimate.z + (delta.count > 2 ? delta[2] : 0)
        )
        
        // 새 cost
        var newResiduals = [Float](repeating: 0, count: n)
        for i in 0..<n {
            newResiduals[i] = candidate.distance(to: anchorPositions[i]) - distances[i]
        }
        let costNew = dot(newResiduals, newResiduals)
        
        if costNew < costOld {
            estimate = candidate
            lambda *= 0.5
            if abs(costOld - costNew) < tolerance {
                break
            }
        } else {
            lambda *= 2.0
        }
    }
    return estimate
}
