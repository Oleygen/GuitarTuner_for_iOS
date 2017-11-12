//
//  ViewController.m
//  GuitarTuner
//
//  Created by Gennadii on 11/12/17.
//  Copyright © 2017 Gennady Oleynik. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, strong, readonly) AVAudioRecorder *recorder;
@property (nonatomic, strong, readonly) AVAudioPlayer *player;
@property (nonatomic, strong, readonly) AVAudioSession *session;
@property (nonatomic, strong, readonly) NSString *fileURLString;
@property (nonatomic, strong, readonly) NSURL *fileURL;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

@implementation ViewController

@synthesize session = _session;
@synthesize recorder = _recorder;
@synthesize fileURL = _fileURL;
#pragma mark - lazy getters

-(AVAudioSession *) session {
    if (!_session) {
        _session = [AVAudioSession sharedInstance];
        NSError *error;
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        
        if (error) {
            NSLog(@"WARNING, WE HAVE ERROR WHILE SESSION CREATE PROCESS, %@", error.localizedDescription);
        }
    }
    return _session;
}

-(NSString *)fileURLString {
    return @"TestRecord";
}

-(NSURL *)fileURL {
    if (!_fileURL) {
        
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   self.fileURLString,
                                   nil];
        
        _fileURL = [NSURL fileURLWithPathComponents:pathComponents];
    }
    return _fileURL;

}

-(AVAudioRecorder *)recorder {
    if (!_recorder) {
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        NSError *error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.fileURL settings:recordSetting error:&error];
        _recorder.delegate = self;
        [_recorder setMeteringEnabled:YES];
        if (error) {
            NSLog(@"EBALO V GOVNE U RECORDERA %@", error.localizedDescription);
        }
        
    }
    return _recorder;
}



#pragma mark - UIViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    
    
 
    
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Interaction


- (IBAction)didToggleRecordButton:(UIButton *)sender {
    if (sender.isSelected) {
        [sender setSelected:NO];
        [self stopRecordingSession];
    } else {
        [sender setSelected:YES];
        [self askRecordingSession];
    }
}





#pragma mark - recorder toggle

-(void)askRecordingSession {
    
    if (![self.recorder prepareToRecord]) {
        NSLog(@"recorder v gavne");
    } else {
        [self.session requestRecordPermission:^(BOOL granted) {
            if (!granted) {
                NSLog(@"USER PEEDOR NE DAL DOSTUP");
            } else {
                [self startRecordingSession];
            }
        }];
    }
    
    
    
   
}

-(void)startRecordingSession {
    NSError *error;
    [self.session setActive:true error:&error];
    
    if (error) {
        NSLog(@"SHIT HAPPENS BRO %@", error.localizedDescription);
    } else {
        NSLog(@"Startuem, segodnya mi s toboy startuem");
        if (![self.recorder record]) {
            NSLog(@"Na4alnik, recorder obosralsya");
        } else {
            NSLog(@"STARTANOOLO STARTANOOLO!");
        }
    }
}

-(void)stopRecordingSession {
    [self.recorder stop];
    NSLog(@"Bilo stope");
}

#pragma mark - AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"did finish recording");
    
    
    
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    NSLog(@"didOccurError %@", error.localizedDescription);
}


@end
