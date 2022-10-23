//
//  CSender.hpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import <AVFAudio/AVFAudio.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CircularBuffer.hpp"
#import "Shared.hpp"

struct CSender {
private:
	double sampleRate = 44100;
	void renderAudio(bool * isSilence, double sampleTime, int frameCount, AudioBufferList * outputData);
	
	MessageFragment * const outputTmp = (MessageFragment *)malloc(sizeof(MessageFragment));
	MessageFragment * const sendingPrePasteTmp = (MessageFragment *)malloc(sizeof(MessageFragment) * 1024);
	
	bool on0 = false;
	bool on1 = false;
	bool on2 = false;
	bool on3 = false;
	bool oldOn0 = false;
	bool oldOn1 = false;
	bool oldOn2 = false;
	bool oldOn3 = false;
	
	int remainSample = 0;
	
	CircularBuffer<MessageFragment> sendingBuffer = CircularBuffer<MessageFragment>(1024);
	
public:
	CSender();
	~CSender();
	AVAudioSourceNode * getSourceNode();
	void send(MessageFragment point);
	void sendBytes(uint8_t * bytes, int size);
	void changeSampleRate(double sampleRate);
};
