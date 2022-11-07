//
//  CSender.cpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import <stdio.h>
#import "CSender.hpp"
#import "FastTrig2Pi.hpp"
#import "HammingCode.hpp"

CSender::CSender() {
	
};

CSender::~CSender() {
	free(outputTmp);
	free(sendingPrePasteTmp);
};

AVAudioSourceNode * CSender::getSourceNode() {
	
	AVAudioSourceNodeRenderBlock renderBlock = ^OSStatus(BOOL * _Nonnull isSilence,
														 const AudioTimeStamp * _Nonnull timestamp,
														 AVAudioFrameCount frameCount,
														 AudioBufferList * _Nonnull outputData) {
		this->renderAudio(isSilence, timestamp->mSampleTime, frameCount, outputData);
		
		return 0;
	};
	
	return [[AVAudioSourceNode alloc] initWithRenderBlock:renderBlock];;
};

void CSender::renderAudio(bool * isSilence, double sampleTime, int frameCount, AudioBufferList * outputData) {
	float * buffer = (float *)outputData->mBuffers->mData;
	*isSilence = false;
	
	const long double sampleRate = this->sampleRate;
	
	for (int i = 0; i < frameCount; i++) {
		const long currentFrame = (long)sampleTime + i;
		const long double s = (long double)currentFrame / sampleRate;
		const long double signalTimer = fmod(s * kTpSec, 1);
		const float level = std::min((float)signalTimer / 0.1, 1.0);
		const float oldLevel = 1.0 - level;
		
		const long double ls = (long double)(currentFrame - 1) / sampleRate;
		const long double lSignalTimer = fmod(ls * kTpSec, 1);
		
		if (lSignalTimer - signalTimer > 0.5) {
			oldOn0 = on0;
			oldOn1 = on1;
			oldOn2 = on2;
			oldOn3 = on3;
			const bool read = sendingBuffer.read(outputTmp, 1) == 1;
			on0 = read ? std::get<0>(outputTmp[0]) : 0;
			on1 = read ? std::get<1>(outputTmp[0]) : 0;
			on2 = read ? std::get<2>(outputTmp[0]) : 0;
			on3 = read ? std::get<3>(outputTmp[0]) : 0;
		};
//		std::cout << level << std::endl;
		
		float val = 0;
		val += (level * (float)on0 + oldLevel * (float)oldOn0) * (float)fast_sin2pi(s * 17000);
		val += (level * (float)on1 + oldLevel * (float)oldOn1) * (float)fast_sin2pi(s * 18000);
		val += (level * (float)on2 + oldLevel * (float)oldOn2) * (float)fast_sin2pi(s * 19000);
		val += (level * (float)on3 + oldLevel * (float)oldOn3) * (float)fast_sin2pi(s * 20000);
		//FUN
//		val += (level * (float)on0 + oldLevel * (float)oldOn0) * (float)fast_sin2pi(523.25 * s);
//		val += (level * (float)on1 + oldLevel * (float)oldOn1) * (float)fast_sin2pi(659.25 * s);
//		val += (level * (float)on2 + oldLevel * (float)oldOn2) * (float)fast_sin2pi(783.99 * s);
//		val += (level * (float)on3 + oldLevel * (float)oldOn3) * (float)fast_sin2pi(1046.5 * s);
		//ENDFUN
		buffer[i] = val;
	};
};

void CSender::send(MessageFragment point) {
	*sendingPrePasteTmp = point;
	sendingBuffer.write(sendingPrePasteTmp, 1);
};

void CSender::sendBytes(uint8_t * bytes, int size) {
	if (size <= 0) return;
	int nextMsgLoc = 1;
	//start signal
	constexpr auto allOn = std::make_tuple(true, true, true, true);
	constexpr auto allOff = std::make_tuple(false, false, false, false);
	sendingPrePasteTmp[0] = allOn;
	
	const uint8_t sizLhs = (size & 0xFF00) >> 8;
	const uint8_t sizRhs = size & 0x00FF;
	
	//message
	for(int i = 0; i < size + 2; i++) {
		uint8_t byte = 0;
		if (i == 0) byte = sizLhs;
		if (i == 1) byte = sizRhs;
		if (i >= 2) byte = bytes[i - 2];
		
		const auto hamm = encodeHamm15_11_SECDED(std::bitset<16>((int)byte << 3) | std::bitset<16>(0b111));
		
		for (int i = 0; i < 8; i++) {
			const int si = 15 - 2*i;
			const bool a = hamm[si];
			const bool b = hamm[si-1];
			if (!a && !b) sendingPrePasteTmp[nextMsgLoc++] = std::make_tuple(1,0,0,0);
			if ( a && !b) sendingPrePasteTmp[nextMsgLoc++] = std::make_tuple(0,1,0,0);
			if ( a &&  b) sendingPrePasteTmp[nextMsgLoc++] = std::make_tuple(0,0,1,0);
			if (!a &&  b) sendingPrePasteTmp[nextMsgLoc++] = std::make_tuple(0,0,0,1);
		};
		
		std::cout << "Send Byte: " << std::bitset<8>(byte) << std::endl;
		std::cout << "Send Code Raw: " << hamm << std::endl;
	};
	sendingPrePasteTmp[nextMsgLoc++] = allOff;//00000001111 10111
	sendingPrePasteTmp[nextMsgLoc++] = allOff;//00000001111 00110
	sendingPrePasteTmp[nextMsgLoc++] = allOff;
	sendingBuffer.write(sendingPrePasteTmp, nextMsgLoc);
};

void CSender::changeSampleRate(double sampleRate) {
	this->sampleRate = sampleRate;
};
