//
//  HammingCode.cpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/21/22.
//

#import "HammingCode.hpp"

///Input a 11 bit data (left 5 bit is unused), output a 16 bit Secoded hamming code.
std::bitset<16> encodeHamm15_11_SECDED(std::bitset<16> data) {
	std::bitset<16> output = (data << 5) & std::bitset<16>(0b1111111111100000);
	output[0] = (data & std::bitset<16>(0b10101011011)).count() % 2;
	output[1] = (data & std::bitset<16>(0b11001101101)).count() % 2;
	output[2] = (data & std::bitset<16>(0b11110001110)).count() % 2;
	output[3] = (data & std::bitset<16>(0b11111110000)).count() % 2;
	output[4] = output.count() % 2;
	
	return output;
};

///Input a 16 bit Secoded hamming code. Output a 11 bit data (left 5 bit is unused) and whether the code good.
std::tuple<std::bitset<16>, bool> decodeHamm15_11_SECDED(std::bitset<16> data) {
	std::bitset<16> cData = data;
	
	std::bitset<5> syndrome;
	syndrome[4] = (data & std::bitset<16>(0b1111111111111111)).count() % 2;
	syndrome[3] = (data & std::bitset<16>(0b1111111000001000)).count() % 2;
	syndrome[2] = (data & std::bitset<16>(0b1111000111000100)).count() % 2;
	syndrome[1] = (data & std::bitset<16>(0b1100110110100010)).count() % 2;
	syndrome[0] = (data & std::bitset<16>(0b1010101101100001)).count() % 2;
	
	int location = -1;
	
		 if (syndrome == 0b11111) location = 15;
	else if (syndrome == 0b11110) location = 14;
	else if (syndrome == 0b11101) location = 13;
	else if (syndrome == 0b11100) location = 12;
	else if (syndrome == 0b11011) location = 11;
	else if (syndrome == 0b11010) location = 10;
	else if (syndrome == 0b11001) location = 9;
	else if (syndrome == 0b10111) location = 8;
	else if (syndrome == 0b10110) location = 7;
	else if (syndrome == 0b10101) location = 6;
	else if (syndrome == 0b10011) location = 5;
	else if (syndrome == 0b10000) location = 4;
	else if (syndrome == 0b11000) location = 3;
	else if (syndrome == 0b10100) location = 2;
	else if (syndrome == 0b10010) location = 1;
	else if (syndrome == 0b10001) location = 0;
	
	bool broken = syndrome[3] | syndrome[2] | syndrome[1] | syndrome[0];
	
	//Data is fine
	if (!broken && !syndrome[4]) {
		return std::make_tuple(cData >> 5, true);
	}
	
	//Data is repaired
	if (syndrome[4] && broken) {
		cData[location] = !cData[location];
		return std::make_tuple(cData >> 5, true);
	}
	
	//FUBAR
	return std::make_tuple(cData >> 5, false);
};
