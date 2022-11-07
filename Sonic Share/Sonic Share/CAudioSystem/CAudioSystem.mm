//
//  CAudioSystem.m
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import "CAudioSystem.h"
#import "CSender.hpp"
#import "CReceiver.hpp"

#import <iostream>

@implementation CAudioSystem {
	AVAudioEngine * engine;
	Float64 sampleRate;
	std::unique_ptr<CSender> sender;
	std::unique_ptr<CReceiver> receiver;
}

-(id)init {
	[self setup];
	self = [super init];
	return self;
};

-(void)setup {
	engine = [[AVAudioEngine alloc] init];
	sender = std::make_unique<CSender>();
	receiver = std::make_unique<CReceiver>();
	
	AVAudioSourceNode * sourceNode = sender->getSourceNode();
	[engine attachNode: sourceNode];
	const auto outputSampleRate = [[engine outputNode] outputFormatForBus:0].sampleRate;
	const auto inputSampleRate = [[engine inputNode] outputFormatForBus:0].sampleRate;
	
	std::cout << "Output Sample Rate: " << outputSampleRate << std::endl;
	std::cout << "Input Sample Rate: " << inputSampleRate << std::endl;
	
	const auto format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:outputSampleRate channels:1 interleaved:false];
	
	sender->changeSampleRate(outputSampleRate);
	receiver->changeHighSampleRate(inputSampleRate == 48000);
	
	[engine connect:sourceNode to:[engine mainMixerNode] format: format];
	receiver->attachToInputNode([engine inputNode]);
};

-(void)start {
	[engine startAndReturnError: nullptr];
};

-(void)stop {
	[engine stop];
};

-(void)sendBytes:(uint8_t *)bytes size:(int)size {
	sender->sendBytes(bytes, size);
};

-(int)unreadByteSize {
	return receiver->unreadByteSize();
};

-(int)readBytes:(uint8_t *)bytes {
	return receiver->readBytes(bytes);
};

-(bool)isListening {
	return receiver->isListening();
};

@end
