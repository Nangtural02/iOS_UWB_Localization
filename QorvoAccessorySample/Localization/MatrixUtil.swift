//
//  MatrixUtil.swift
//  DisplayLocation
//  Created by Mac_Jangyeon on 1/31/25.
//  Accelerate 기반 행렬/벡터 연산 유틸
//
//  안드로이드 MatrixUtil.kt → Accelerate 없이 순수 Swift for-loop로 구현
//

import Foundation

/// 전치 (Transpose)
func transposeMatrix(_ matrix: [[Float]]) -> [[Float]] {
    let rowCount = matrix.count
    guard rowCount > 0 else { return [[]] }
    let colCount = matrix[0].count
    
    var result = Array(
        repeating: Array(repeating: 0.0 as Float, count: rowCount),
        count: colCount
    )
    for i in 0..<rowCount {
        for j in 0..<colCount {
            result[j][i] = matrix[i][j]
        }
    }
    return result
}

/// 행렬 곱셈 (A: m×k, B: k×n => result: m×n)
func multiplyMatrixMatrix(_ a: [[Float]], _ b: [[Float]]) -> [[Float]] {
    let m = a.count
    guard m > 0 else { return [[]] }
    let k = a[0].count
    
    let k2 = b.count
    guard k2 > 0 else { return [[]] }
    let n = b[0].count
    
    // 차원 불일치 시 빈 배열
    if k != k2 {
        return [[]]
    }
    
    var result = Array(
        repeating: Array(repeating: 0.0 as Float, count: n),
        count: m
    )
    for i in 0..<m {
        for j in 0..<n {
            var sum: Float = 0
            for x in 0..<k {
                sum += a[i][x] * b[x][j]
            }
            result[i][j] = sum
        }
    }
    return result
}

/// 행렬 × 벡터 (A: m×n, v: n => result: m)
func multiplyMatrixVector(_ matrix: [[Float]], _ vector: [Float]) -> [Float] {
    let m = matrix.count
    if m == 0 { return [] }
    let n = matrix[0].count
    if n != vector.count { return [] }
    
    var result = [Float](repeating: 0, count: m)
    for i in 0..<m {
        var sum: Float = 0
        for j in 0..<n {
            sum += matrix[i][j] * vector[j]
        }
        result[i] = sum
    }
    return result
}

/// 행렬 덧셈 (동일 크기)
func addMatrices(_ A: [[Float]], _ B: [[Float]]) -> [[Float]] {
    let rows = A.count
    if rows == 0 { return [[]] }
    let cols = A[0].count
    if B.count != rows || B[0].count != cols {
        return [[]]
    }
    var result = A
    for i in 0..<rows {
        for j in 0..<cols {
            result[i][j] = A[i][j] + B[i][j]
        }
    }
    return result
}

/// 행렬 × 스칼라 곱
func scalarMultiplyMatrix(_ matrix: [[Float]], _ scalar: Float) -> [[Float]] {
    let rows = matrix.count
    if rows == 0 { return [[]] }
    let cols = matrix[0].count
    
    var result = matrix
    for i in 0..<rows {
        for j in 0..<cols {
            result[i][j] = matrix[i][j] * scalar
        }
    }
    return result
}

/// 행렬의 역행렬 (정방행렬) - 가우스-조던 소거
func invertMatrix(_ matrix: [[Float]]) -> [[Float]]? {
    let n = matrix.count
    if n == 0 || matrix[0].count != n {
        // 정방행렬 아니면 nil
        return nil
    }
    
    // [A | I], size: n x 2n
    var augmented = Array(
        repeating: Array(repeating: 0.0 as Float, count: 2*n),
        count: n
    )
    
    // 초기화: [A | I]
    for i in 0..<n {
        for j in 0..<n {
            augmented[i][j] = matrix[i][j]
        }
        augmented[i][n + i] = 1.0
    }
    
    // 가우스-조던
    for i in 0..<n {
        // 1) 피벗 선택(행 교환)
        var pivotRow = i
        var maxVal = abs(augmented[i][i])
        for r in (i+1)..<n {
            let val = abs(augmented[r][i])
            if val > maxVal {
                maxVal = val
                pivotRow = r
            }
        }
        if pivotRow != i {
            let tmp = augmented[i]
            augmented[i] = augmented[pivotRow]
            augmented[pivotRow] = tmp
        }
        
        // 피벗이 0이면 역행렬 불가
        let pivot = augmented[i][i]
        if abs(pivot) < 1e-9 {
            return nil
        }
        
        // 2) 피벗 행 나누기
        for c in 0..<(2*n) {
            augmented[i][c] /= pivot
        }
        
        // 3) 다른 행에서 피벗 열을 0으로
        for r in 0..<n {
            if r != i {
                let factor = augmented[r][i]
                for c in 0..<(2*n) {
                    augmented[r][c] -= factor * augmented[i][c]
                }
            }
        }
    }
    
    // 추출: 역행렬
    var inverse = Array(
        repeating: Array(repeating: 0.0 as Float, count: n),
        count: n
    )
    for i in 0..<n {
        for j in 0..<n {
            inverse[i][j] = augmented[i][j + n]
        }
    }
    return inverse
}
