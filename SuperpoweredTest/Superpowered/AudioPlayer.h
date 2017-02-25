//
// Created by Martin Mlostek on 20.01.16.
// Copyright (c) 2016 Nomad5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperpoweredIOSAudioIO.h"

/**
 * The loading callback protocol
 */
@protocol AudioPlayerDelegate <NSObject>

@required
    // called once the track is loaded
    - (void)onTrackLoaded;

@end

/**
 * The audio player class
 */
@interface AudioPlayer : NSObject <SuperpoweredIOSAudioIODelegate>

    // delegate
    @property(weak) id <AudioPlayerDelegate> delegate;

    // the constructor to use
    - (instancetype)init;

    // final cleanup
    - (void)cleanup;

    // load track
    - (void)load:(NSString *)path;

    // play
    - (void)play;

    // pause
    - (void)pause;

@end