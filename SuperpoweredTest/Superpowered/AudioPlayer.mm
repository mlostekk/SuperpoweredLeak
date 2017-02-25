//
// Created by Martin Mlostek on 20.01.16.
// Copyright (c) 2016 Nomad5. All rights reserved.
//

#import <pthread.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayer.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredSimple.h"

#define HEADROOM_DECIBEL 3.0f
static const float headroom = powf(10.0f, -HEADROOM_DECIBEL * 0.025f);

@implementation AudioPlayer
    {
        SuperpoweredAdvancedAudioPlayer *player;
        SuperpoweredIOSAudioIO          *output;
        float                           *stereoBuffer;
        float                           vol;
        unsigned int                    lastSampleRate;
    }

    /****************************************************************************************************************************
     */
    void playerEventCallback(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, __unused void *value)
    {
        AudioPlayer *player = ((__bridge AudioPlayer *) clientData);
        switch(event)
        {
            case SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess:
            {
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess");
                if(player->_delegate)
                {
                    [player->_delegate onTrackLoaded];
                }
                break;
            }
            case SuperpoweredAdvancedAudioPlayerEvent_LoadError:
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_LoadError");
                break;
            case SuperpoweredAdvancedAudioPlayerEvent_EOF:
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_EOF");
                break;
            case SuperpoweredAdvancedAudioPlayerEvent_JogParameter:
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_JogParameter");
                break;
            case SuperpoweredAdvancedAudioPlayerEvent_DurationChanged:
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_DurationChanged");
                break;
            case SuperpoweredAdvancedAudioPlayerEvent_NetworkError:
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_NetworkError");
                break;
            case SuperpoweredAdvancedAudioPlayerEvent_LoopEnd:
                NSLog(@"SuperpoweredAdvancedAudioPlayerEvent_LoopEnd");
                break;
        }
    }

    /****************************************************************************************************************************
     */
    static bool audioProcessing(void *clientdata,
                                float **buffers,
                                unsigned int inputChannels,
                                unsigned int outputChannels,
                                unsigned int numberOfSamples,
                                unsigned int samplerate,
                                uint64_t hostTime)
    {
        __unsafe_unretained AudioPlayer *self = (__bridge AudioPlayer *) clientdata;

        if(samplerate != self->lastSampleRate)
        {
            // Has sample rate changed?
            self->lastSampleRate = samplerate;
            self->player->setSamplerate(samplerate);
        };
        bool silence = !self->player->process(self->stereoBuffer, false, numberOfSamples, self->vol, 0.0, -1.0);
        if(!silence)
        {
            SuperpoweredDeInterleave(self->stereoBuffer, buffers[0], buffers[1], numberOfSamples);
        }
        return !silence;
    }

    /****************************************************************************************************************************
     */
    - (instancetype)init
    {
        NSLog(@"initializing audio player");
        self = [super init];
        if(self)
        {
            // init the audio stuff
            lastSampleRate = 0;
            vol            = 1.0f * headroom;
            if(posix_memalign((void **) &stereoBuffer, 16, 4096 + 128) != 0)
            {
                NSLog(@"posix_memalign error, aborting");
                abort();
            }
            player = new SuperpoweredAdvancedAudioPlayer((__bridge void *) self, playerEventCallback, 44100, 0);
            output = [[SuperpoweredIOSAudioIO alloc]
                                              initWithDelegate:(id <SuperpoweredIOSAudioIODelegate>) self
                                              preferredBufferSize:12
                                              preferredMinimumSamplerate:44100
                                              audioSessionCategory:AVAudioSessionCategoryPlayback
                                              channels:2
                                              audioProcessingCallback:audioProcessing
                                              clientdata:(__bridge void *) self];
        }
        return self;
    }

    /****************************************************************************************************************************
     */
    - (void)cleanup
    {
        player->pause(0, 0);
        [output stop];
        output = nil;
        free(player);
        player    = NULL;
        _delegate = nil;
    }

    /****************************************************************************************************************************
     */
    - (void)load:(NSString *)path
    {
        NSLog(@"loading track '%@'", path);
        [output stop];
        player->open(path.fileSystemRepresentation);
        [output start];
    }

    /****************************************************************************************************************************
     */
    - (void)play
    {
        if(!player->playing)
        {
            player->play(false);
        }
    }

    /****************************************************************************************************************************
     */
    - (void)pause
    {
        if(player->playing)
        {
            player->pause(0, 0);
        }
    }

    /****************************************************************************************************************************
     */
    - (void)interruptionStarted
    {
        NSLog(@"interruption started");
    }

    /**
     * Handle permission refused
     */
    - (void)recordPermissionRefused
    {
        NSLog(@"record permission refused");
    }

    /****************************************************************************************************************************
     */
    - (void)interruptionEnded
    {
        NSLog(@"interruption ended");
        player->onMediaserverInterrupt();
    }

    /****************************************************************************************************************************
     */
    - (void)mapChannels:(multiOutputChannelMap *)outputMap
            inputMap:(multiInputChannelMap *)inputMap
            externalAudioDeviceName:(NSString *)externalAudioDeviceName
            outputsAndInputs:(NSString *)outputsAndInputs
    {
        NSLog(@"External device connected > %@ (%@)", externalAudioDeviceName, outputsAndInputs);
    }

@end