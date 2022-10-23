//
//  CReceiver.c
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import "CReceiver.hpp"
#import <iostream>
#import "HammingCode.hpp"

CReceiver::CReceiver() {
	workingBuffer2sc->realp = workingBuffer2;
	workingBuffer2sc->imagp = workingBuffer2 + 128;
};

CReceiver::~CReceiver() {
	delete(workingBuffer2sc);
	free(workingBuffer1);
	free(workingBuffer2);
	free(outputTmp);
	free(convTmp);
	free(doneBytesBuffer);
};

void CReceiver::process(UInt32 frames, float * newBuffer) {
	buffer.write(newBuffer, frames);
	const double sampleRate = highSampleRate ? 48000 : 44100;
	const double samplePerTick = sampleRate / kTpSec;
	
	if (!isReading) {
		while (true) {
			const int freeSamples = buffer.unreadSize();
			if (freeSamples < (int)samplePerTick + 8) break;
			buffer.preview(workingBuffer1, 16);
			const float signalDetect = runSignalDetectFFT();
			const bool haveSignal = signalDetect > det_noiseFloor + 50;
			if (haveSignal) {
				samplesRead = 0;
				isReading = true;
				buffer.purge(16);
				break;
			};
			det_noiseFloor = std::min(std::max(det_noiseFloor * 0.97 + signalDetect * 0.03, -180.0), -40.0);
			buffer.purge(16);
		};
	};
	
	if (isReading) {
		while (true) {
			int freeSamples = buffer.unreadSize();
			if (freeSamples < (int)samplePerTick + 8) break;
			const double currentTick = floor((samplesRead + 256) / samplePerTick);
			//Run signal extraction
			buffer.read(workingBuffer1, 256);
			
			std::cout << "Tick: " << currentTick << std::endl;
			if (currentTick >= 1) {
				const auto signal = runSignalExtractFFT();
				outputTmp[0] = std::get<0>(signal);
				outputTmp[1] = std::get<1>(signal);
				const bool good = std::get<2>(signal);
				std::cout << "Extracted " << outputTmp[0] << " " << outputTmp[1] << " " << good << std::endl;
				if (!good) {
					isReading = false;
					intensityBuffer.purge(256);
					doneSize = bytesBuffer.read(doneBytesBuffer, 2048);
					unread = true;
					std::cout << "Commited" << std::endl;
					break;
				} else {
					intensityBuffer.write(outputTmp, 2);
				}
			}
			
			samplesRead += 256;
			
			//setup for next
			const double nextTickSample = (currentTick + 1) * samplePerTick;
			const int samplesToPurge = (int)nextTickSample - samplesRead;
			buffer.purge(samplesToPurge);
			samplesRead += samplesToPurge;
			
			const int avelableIntensityPoints = intensityBuffer.unreadSize();
			if (avelableIntensityPoints >= 16) {
				intensityBuffer.read(convTmp, 16);
				std::cout << "Unread Size: " << avelableIntensityPoints << std::endl;
				uint16_t hammingCode = 0;
				for (int i = 0; i < 16; i++) hammingCode |= ((int)(convTmp[i]) << (uint16_t)(15 - i));
				std::cout << "Received Code Jum: " << std::bitset<16>(hammingCode) << std::endl;
				const auto result = decodeHamm15_11_SECDED(hammingCode);
				std::bitset<16> dataBits = std::get<0>(result);
				bool good = std::get<1>(result);
				if (!good) {
					isReading = false;
					intensityBuffer.purge(256);
					doneSize = bytesBuffer.read(doneBytesBuffer, 2048);
					unread = true;
					std::cout << "Commited" << std::endl;
					break;
				};
				std::cout << "Received Byte: " << std::bitset<8>(dataBits.to_ulong() >> 3) << std::endl;
				*byteTmp = (dataBits >> 3).to_ulong();
				bytesBuffer.write(byteTmp, 1);
				std::cout << "Writing " << dataBits << std::endl;
			};
		};
	};
};

FFTSetup setup16 = vDSP_create_fftsetup(4, kFFTRadix2);
FFTSetup setup256 = vDSP_create_fftsetup(8, kFFTRadix2);

float CReceiver::runSignalDetectFFT() {
	//size = 16, log2n = 4
	vDSP_hann_window(workingBuffer2, 16, 0);
	vDSP_vmul(workingBuffer2, 1, workingBuffer1, 1, workingBuffer1, 1, 16);
	
	vDSP_ctoz((DSPComplex *)workingBuffer1, 2, workingBuffer2sc, 1, 8);
	vDSP_fft_zrip(setup16, workingBuffer2sc, 1, 4, kFFTDirection_Forward);
	vDSP_zvmags(workingBuffer2sc, 1, workingBuffer1, 1, 8);
	return 20 * log(sqrt(workingBuffer1[highSampleRate ? 6 : 6]) / 8);
};

std::tuple<bool, bool, bool> CReceiver::runSignalExtractFFT() {
	//size = 256, log2n = 8
	vDSP_hann_window(workingBuffer2, 256, 0);
	vDSP_vmul(workingBuffer2, 1, workingBuffer1, 1, workingBuffer1, 1, 256);
	
	vDSP_ctoz((DSPComplex *)workingBuffer1, 2, workingBuffer2sc, 1, 128);
	vDSP_fft_zrip(setup256, workingBuffer2sc, 1, 8, kFFTDirection_Forward);
	vDSP_zvmags(workingBuffer2sc, 1, workingBuffer1, 1, 128);
	
	const float qc0 = 20 * log(sqrt(workingBuffer1[highSampleRate ?  88 :  96]) / 128);
	const float qc1 = 20 * log(sqrt(workingBuffer1[highSampleRate ?  94 : 102]) / 128);
	const float qc2 = 20 * log(sqrt(workingBuffer1[highSampleRate ?  99 : 107]) / 128);
	const float qc3 = 20 * log(sqrt(workingBuffer1[highSampleRate ? 104 : 113]) / 128);
	const float qc4 = 20 * log(sqrt(workingBuffer1[highSampleRate ? 110 : 119]) / 128);
	
	const float pt0 = 20 * log(sqrt(workingBuffer1[highSampleRate ?  91 :  99]) / 128);
	const float pt1 = 20 * log(sqrt(workingBuffer1[highSampleRate ?  96 : 104]) / 128);
	const float pt2 = 20 * log(sqrt(workingBuffer1[highSampleRate ? 101 : 110]) / 128);
	const float pt3 = 20 * log(sqrt(workingBuffer1[highSampleRate ? 107 : 116]) / 128);
	
	const float avgFloor = (qc0 + qc1 + qc2 + qc3 + qc4) / 5;
	const float maxSig = std::max(std::max(pt0, pt1),std::max(pt2, pt3));
	std::cout << pt0 << " " << pt1 << " " << pt2 << " " << pt3 << std::endl;
	if (avgFloor < -400) return std::make_tuple(0,0,0);
	
	const float diff0 = pt0 - 0.7 * avgFloor - 0.3 * (qc0 + qc1)/2;
	const float diff1 = pt1 - 0.7 * avgFloor - 0.3 * (qc1 + qc2)/2;
	const float diff2 = pt2 - 0.7 * avgFloor - 0.3 * (qc2 + qc3)/2;
	const float diff3 = pt3 - 0.7 * avgFloor - 0.3 * (qc3 + qc4)/2;
	
	if (maxSig - avgFloor < 30) return std::make_tuple(0,0,0);
	
	if (diff0 > std::max(diff1, std::max(diff2, diff3))) return std::make_tuple(0, 0, 1);
	if (diff1 > std::max(diff0, std::max(diff2, diff3))) return std::make_tuple(1, 0, 1);
	if (diff2 > std::max(diff0, std::max(diff1, diff3))) return std::make_tuple(1, 1, 1);
	if (diff3 > std::max(diff0, std::max(diff1, diff2))) return std::make_tuple(0, 1, 1);
	
	return std::make_tuple(0, 0, 0);
};

void CReceiver::attachToInputNode(AVAudioInputNode * inputNode) {
	[inputNode installTapOnBus:0 bufferSize:1024 format:[inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
		process([buffer frameLength], [buffer floatChannelData][0]);
	}];
};

void CReceiver::changeHighSampleRate(bool highSampleRate) {
	this->highSampleRate = highSampleRate;
};

int CReceiver::unreadByteSize() const {
	if (!unread) return 0;
	if (doneSize <= 2) return 0;
	const uint16_t size = ((uint16_t)doneBytesBuffer[0] << 8) | (uint16_t)doneBytesBuffer[1];
	if (doneSize - 2 < size) return 0;
	return size;
};

int CReceiver::readBytes(uint8_t * buffer) {
	const int ubs = unreadByteSize();
	if (ubs > 0) memcpy(buffer, doneBytesBuffer + 2, sizeof(uint8_t) * ubs);
	unread = false;
	return ubs;
};

bool CReceiver::isListening() {
	return isReading;
};
