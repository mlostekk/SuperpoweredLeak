//
//  ViewController.m
//  SuperpoweredTest
//
//  Created by Martin Mlostek on 25.02.17.
//  Copyright © 2017 nomad5. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
    {
        AudioPlayer *audioPlayer;
    }

    /****************************************************************************************************************************
     */
    - (IBAction)onLoadPressed
    {
        _playButton.enabled = false;
        if(audioPlayer != nil)
        {
            [audioPlayer cleanup];
        }
        audioPlayer = [[AudioPlayer alloc] init];
        audioPlayer.delegate = self;
        [audioPlayer load:[[NSBundle mainBundle] pathForResource:@"strong-the-root" ofType:@"mp3"]];
    }

    /****************************************************************************************************************************
     */
    - (void)onTrackLoaded
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
        {
            _playButton.enabled = true;
            [audioPlayer play];
        }];
    }

@end
