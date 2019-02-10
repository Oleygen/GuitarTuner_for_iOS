//
//  FFTProcessor.swift
//  GuitarTuner
//
//  Created by Oleynik Gennady on 09/02/2019.
//  Copyright © 2019 Gennady Oleynik. All rights reserved.
//

import Foundation
import Accelerate

class FFTProcessor {
    private let tau: Float = .pi * 2
    private let n = vDSP_Length(2048)
    private let frequencies: [Float] = [1, 5, 25, 30, 75, 100, 300, 500, 512, 1023]
    private var signal: [Float]!
    private var interleavedComplexSignal: [DSPComplex]!
    private var splitComplexSignal: DSPSplitComplex!
    
    init() {
        createSignal()
        createInterleavedComplexSignal()
        createSplitComplexSignal()
    }
    
    
    
    private func createSignal() {
        self.signal = (0...n).map { index in
            frequencies.reduce(0) { accumulator, frequency in
                let normalizedIndex = Float(index) / Float(n)
                return accumulator + sin(normalizedIndex * frequency * tau)
            }
        }
    }
    
    private func createInterleavedComplexSignal() {
        self.interleavedComplexSignal = stride(from: 0, to: Int(n), by: 2).map {
            return DSPComplex(real: signal[$0], imag: signal[$0.advanced(by: 1)])
        }
    }
    
    private func createSplitComplexSignal() {
        let halfN = Int(n / 2)
        var forwardInputReal = [Float](repeating: 0, count: halfN)
        var forwardInputImag = [Float](repeating: 0, count: halfN)
        
        var forwardInput = DSPSplitComplex(realp: &forwardInputReal, imagp: &forwardInputImag)
        vDSP_ctoz(interleavedComplexSignal, 2, &forwardInput, 1, vDSP_Length(halfN))
    }
    
    
}
