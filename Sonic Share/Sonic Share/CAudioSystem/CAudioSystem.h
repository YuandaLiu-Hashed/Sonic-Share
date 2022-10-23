//
//  CAudioSystem.h
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import <Foundation/Foundation.h>
#import <AVFAudio/AVFAudio.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CAudioSystem: NSObject
-(id _Nonnull)init;
-(void)start;
-(void)stop;
-(void)sendBytes:(uint8_t * _Nonnull)bytes size:(int)size;
-(int)unreadByteSize;
-(int)readBytes:(uint8_t * _Nonnull)bytes;
-(bool)isListening;
@end
