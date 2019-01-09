//
//  InputStreamManager.swift
//  GuitarTuner
//
//  Created by oleygen ua on 1/4/19.
//  Copyright © 2019 Gennady Oleynik. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox


class InputStreamManager
{
    enum InputStreamManagerError: Error
    {
        case queueUnavailable
        case cantStartStream(status: OSStatus)
        case cantStopStream(status: OSStatus)
        case cantDisposeStream(status: OSStatus)
    }
    
    static private let bufferCount = 3
    
    private let sampleRate: Double
    private let bitsPerChannel: UInt32
    var bytesPerPacket: UInt32
    {
        return bitsPerChannel / 8
    }
    
    var bytesPerFrame: UInt32
    {
        return bitsPerChannel / 8
    }
    
    private lazy var inputFormat: AudioStreamBasicDescription =
        AudioStreamBasicDescription(mSampleRate: sampleRate,
                                    mFormatID: kAudioFormatLinearPCM,
                                    mFormatFlags: kAudioFormatFlagIsSignedInteger
                                        | kAudioFormatFlagsNativeEndian
                                        | kAudioFormatFlagIsPacked
                                        | kAudioFormatFlagIsNonInterleaved,
                                    mBytesPerPacket: bytesPerPacket,
                                    mFramesPerPacket: 1,
                                    mBytesPerFrame: bytesPerFrame,
                                    mChannelsPerFrame: 1,
                                    mBitsPerChannel: bitsPerChannel,
                                    mReserved: 0)
    
    private var ptrAudioQueue : UnsafeMutablePointer<AudioQueueRef?> = UnsafeMutablePointer<AudioQueueRef?>.allocate(capacity: 1)

    private let callBack: AudioQueueInputCallback = {
        inUserData, inAq, inBuffer, inStartTime, inNumberPacketDescription, inPacketDescs in
        print("callback calls")
        

        print(inBuffer.pointee.mAudioData)
        print(inBuffer.pointee.mAudioDataByteSize)

        let samples = extractSamples(from: inBuffer.pointee)
        print(samples)
        AudioQueueEnqueueBuffer(inAq, inBuffer, 0, nil)
    }
    
    private var buffers = [AudioQueueBufferRef?](repeating: nil, count: bufferCount)
    
    /*
    (UnsafeMutableRawPointer?, AudioQueueRef, AudioQueueBufferRef, UnsafePointer<AudioTimeStamp>, UInt32, UnsafePointer<AudioStreamPacketDescription>?)
    */
    init?(sampleRate: Double, bitsPerChannel: UInt32) throws
    {
        self.sampleRate = sampleRate
        self.bitsPerChannel = bitsPerChannel
        
        let inputStatus = AudioQueueNewInput(&inputFormat, callBack, nil, nil, CFRunLoopMode.commonModes.rawValue, 0, ptrAudioQueue)
        if inputStatus != 0
        {
            print("error status: \(inputStatus)")
            return nil
        }
        
    }
    
    func startStream() throws
    {
        try prepareBuffer()
        
        guard let queue = ptrAudioQueue.pointee else
        {
            throw InputStreamManagerError.queueUnavailable
        }
        let status = AudioQueueStart(queue, nil)
        if (status != 0)
        {
            throw InputStreamManagerError.cantStartStream(status: status)
        }
    }
    
    
    func stopStream() throws
    {
        guard let queue = ptrAudioQueue.pointee else
        {
            throw InputStreamManagerError.queueUnavailable
        }
        let status = AudioQueueStop(queue, true)
        if (status != 0)
        {
            throw InputStreamManagerError.cantStopStream(status: status)
        }
    }
    
    
    func disposeStream() throws
    {
        guard let queue = ptrAudioQueue.pointee else
        {
            throw InputStreamManagerError.queueUnavailable
        }
        
        for i in 0 ..< InputStreamManager.bufferCount
        {
            AudioQueueFreeBuffer(queue, buffers[i]!)
        }
        
        let status = AudioQueueDispose(queue, true)
        if (status != 0)
        {
            throw InputStreamManagerError.cantDisposeStream(status: status)
        }
    }
    
    private func deriveBufferSize(audioQueue: AudioQueueRef, ASBDescription: AudioStreamBasicDescription, seconds: Double, outBufferSize: inout UInt32)
    {
        let maxBufferSize = Double(0x50000)
        let maxPacketSize = Double(bytesPerPacket)
        let bytesPerTime = sampleRate * maxPacketSize * seconds
        outBufferSize = UInt32(bytesPerTime < maxBufferSize ? bytesPerTime : maxBufferSize)
    }
    
    private func prepareBuffer() throws
    {
        guard let queue = ptrAudioQueue.pointee else
        {
            throw InputStreamManagerError.queueUnavailable
        }
        
        var bufferSize: UInt32 = 0
        self.deriveBufferSize(audioQueue: queue, ASBDescription: inputFormat, seconds: 0.01, outBufferSize: &bufferSize)
        
        for i in 0 ..< InputStreamManager.bufferCount
        {
            AudioQueueAllocateBuffer(queue, bufferSize, &buffers[i])
            AudioQueueEnqueueBuffer(queue, buffers[i]!, 0, nil)
        }
    }
    
    static private func extractSamples(from buffer: AudioQueueBuffer) -> [Sample]
    {
        let size = buffer.mAudioDataByteSize
        let data = buffer.mAudioData
        
        let ptrIntBuffer = UnsafeBufferPointer(start: data.assumingMemoryBound(to: Int16.self), count: Int(size / 2))
        let intArray = Array<Int16>(ptrIntBuffer)
        
        let result = intArray.map({ value -> Sample in return Sample(value: value)})
        
        return result
    }
}

