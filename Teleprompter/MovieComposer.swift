//
//  MovieComposer.swift
//  Teleprompter
//
//  Created by Hossam on 04/10/2021.
//

import Foundation
import AVFoundation
import CoreMedia



 class MovieComposer {
    
     private var mixComposition = AVMutableComposition()
     private var instruction: AVMutableVideoCompositionInstruction!
     private var videoComposition = AVMutableVideoComposition()
     private var assetExportSession: AVAssetExportSession!
     private var currentTimeDuration: CMTime = .zero

    // AVMutableVideoCompositionLayerInstruction's List
    open var layerInstructions:[AVVideoCompositionLayerInstruction] = []
    
    
    // Add Video
     func addVideo(_ movieURL: URL , aspect : Aspect) {
        
         let videoAsset = AVURLAsset(url:movieURL, options:nil)
        
         videoComposition.frameDuration = .init(value: 1, timescale: 30)
         
         let tracks = getTrack(videoAsset)
        
        var compositionVideoTrack: AVMutableCompositionTrack!
        var compositionAudioTrack: AVMutableCompositionTrack!
         
        let videoTrack = tracks.filter({$0.mediaType == .video}).first!
        compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 1)
         
         
        do {
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                of: videoTrack,
                at: currentTimeDuration)
        } catch _ {
            print("Error: AVMediaTypeVideo")
        }
        
       
        
        compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 1)
        do {
            print(tracks.count , "RR")
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                of: tracks.filter({$0.mediaType == .audio}).first! ,
                at: currentTimeDuration)
        } catch _ {
            print("Error: AVMediaTypeAudio")
        }

        currentTimeDuration = mixComposition.duration

        
        
       
        
        
        let videoSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        let aspect : CGFloat = aspect.aspectRatio
        let width = videoSize.width
        let height = videoSize.width * aspect
        let yTransform = -(videoSize.height - height) / 2
        // Add Layer Instruction
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        let angle = Double.pi / 2
        let t1 = CGAffineTransform.init(translationX: width, y: yTransform)
        let t2 = CGAffineTransform.init(rotationAngle: CGFloat(angle))
        let t3 = t2.concatenating(t1)
        
        videoComposition.renderSize = .init(width: width, height: height)
        
        layerInstruction.setTransform(t3, at: .zero)
        layerInstructions.append(layerInstruction)
    
        
       
    }
    
    
    
    // Export
    open func readyToComposeVideo(_ composedMovieURL: URL) -> AVAssetExportSession! {
        
        // create instruction
        instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: CMTime.zero, duration: mixComposition.duration)
        
        videoComposition.instructions = [instruction]
        instruction.layerInstructions = layerInstructions.reversed()
        
        // generate AVAssetExportSession based on the composition
        self.assetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        assetExportSession.videoComposition = videoComposition
        assetExportSession.outputFileType = AVFileType.mov
        assetExportSession.outputURL = composedMovieURL
       
        
        // delete file
       
        return assetExportSession
    }
     
     public func getTrack(_ asset: AVURLAsset)->[AVAssetTrack] {
             var track : [AVAssetTrack] = []
             let group = DispatchGroup()
             group.enter()
             asset.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: {
                 var error: NSError? = nil;
                 let status = asset.statusOfValue(forKey: "tracks", error: &error)
                 if (status == .loaded) {
                     track = asset.tracks
                 }
                 group.leave()
             })
             group.wait()
             return track
         }
}