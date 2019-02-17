//
//  FFTProcessor.swift
//  GuitarTuner
//
//  Created by Oleynik Gennady on 09/02/2019.
//  Copyright © 2019 Gennady Oleynik. All rights reserved.
//

import Foundation
import Accelerate

public class FFTProcessor {
    private let tau: Float = .pi * 2
    private let n = vDSP_Length(2048)
    private let frequencies: [Float] = [1, 5, 25, 30, 75, 100, 300, 500, 512, 1023]
    private var signal: [Float]!
    private var interleavedComplexSignal: [DSPComplex]!
    private var splitComplexSignal: DSPSplitComplex!
    private var fftSetUp: FFTSetup!
    private var forwardInput: DSPSplitComplex!
    
    private var forwardOutputReal: [Float] = []
    private var forwardOutputImag: [Float] = []
    private var forwardOutput: DSPSplitComplex!
    
    init() {
        createSignal()
        createInterleavedComplexSignal()
        createSplitComplexSignal()
        createSetup()
        performForwardTransform()
    }
    
    func printReal() {
        print(forwardOutputReal)
    }
    
    func printImag() {
        let components = forwardOutputImag.enumerated().filter {
            $0.element < -1
            }.map {
                return $0.offset
        }
        
        
        print(components)
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
        
        self.forwardInput = DSPSplitComplex(realp: &forwardInputReal, imagp: &forwardInputImag)
        vDSP_ctoz(interleavedComplexSignal, 2, &forwardInput, 1, vDSP_Length(halfN))
    }
    
    private func createSetup() {
        let log2n = vDSP_Length(log2(Float(n)))
        
        self.fftSetUp = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
    }
    
    private func performForwardTransform() {
        let halfN = Int(n / 2)
        let log2n = vDSP_Length(log2(Float(n)))

        self.forwardOutputReal = [Float](repeating: 0, count: halfN)
        self.forwardOutputImag = [Float](repeating: 0, count: halfN)
        self.forwardOutput = DSPSplitComplex(realp: &forwardOutputReal, imagp: &forwardOutputImag)
        vDSP_fft_zrop(fftSetUp, &forwardInput, 1, &forwardOutput, 1, log2n, FFTDirection(kFFTDirection_Forward))
    }
    
    deinit {
        vDSP_destroy_fftsetup(self.fftSetUp)
    }
}
