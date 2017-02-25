//
//  ViewController.h
//  SuperpoweredTest
//
//  Created by Martin Mlostek on 25.02.17.
//  Copyright © 2017 nomad5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"

@interface ViewController : UIViewController <AudioPlayerDelegate>

    @property IBOutlet UIButton* playButton;

@end

