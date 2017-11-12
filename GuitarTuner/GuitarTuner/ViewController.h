//
//  ViewController.h
//  GuitarTuner
//
//  Created by Gennadii on 11/12/17.
//  Copyright © 2017 Gennady Oleynik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVAudioPlayerDelegate, AVAudioRecorderDelegate, AVAudioSessionDelegate>


@end

