//
//  CReceiver.h
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import <AVFAudio/AVFAudio.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CircularBuffer.hpp"
#import "Shared.hpp"
#import <Accelerate/Accelerate.h>

struct CReceiver {
private:
	bool highSampleRate = false;
	float * const workingBuffer1 = (float *)malloc(sizeof(float) * 256);
	float * const workingBuffer2 = (float *)malloc(sizeof(float) * 256);
	DSPSplitComplex * workingBuffer2sc = new DSPSplitComplex();
	
	bool * const outputTmp = (bool *)malloc(sizeof(bool) * 2);
	uint8_t * const byteTmp = (uint8_t *)malloc(sizeof(uint8_t) * 1);
	bool * const convTmp = (bool *)malloc(sizeof(bool) * 16);
	
	double samplesRead = 0;
	std::atomic<bool> isReading = false;
	
	float runSignalDetectFFT();
	std::tuple<bool, bool, bool> runSignalExtractFFT();
	
	CircularBuffer<float> buffer = CircularBuffer<float>(8192);
	CircularBuffer<bool> intensityBuffer = CircularBuffer<bool>(256);
	CircularBuffer<uint8_t> bytesBuffer = CircularBuffer<uint8_t>(2048);
	
	uint8_t * const doneBytesBuffer = (uint8_t *)malloc(sizeof(uint8_t) * 2048);
	int doneSize = 0;
	std::atomic<bool> unread = false;
	
	
	float det_noiseFloor = -90;
	
	void process(UInt32 frames, float * newBuffer);
	
public:
	CReceiver();
	~CReceiver();
	void attachToInputNode(AVAudioInputNode * inputNode);
	void changeHighSampleRate(bool highSampleRate);
	int unreadByteSize() const;
	int readBytes(uint8_t * buffer);
	bool isListening();
};
