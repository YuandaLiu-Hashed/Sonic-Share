//
//  Shared.cpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/20/22.
//

#import "Shared.hpp"


// 10 09 08 07 06 05 04 03 02 01 00 P5 P4 P3 P2 P1
// 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0

std::bitset<16> jumbo(std::bitset<16> x) {
	std::bitset<16> jumboed = 0;
	
	jumboed[15] = x[15]; jumboed[14] = x[14]; jumboed[13] = x[13]; jumboed[12] = x[ 7];
	jumboed[11] = x[12]; jumboed[10] = x[11]; jumboed[ 9] = x[ 6]; jumboed[ 8] = x[10];
	jumboed[ 7] = x[ 9]; jumboed[ 6] = x[ 5]; jumboed[ 5] = x[ 8]; jumboed[ 4] = x[ 4];
	jumboed[ 3] = x[ 3]; jumboed[ 2] = x[ 2]; jumboed[ 1] = x[ 1]; jumboed[ 0] = x[ 0];
	
	return jumboed;
};

std::bitset<16> unJumbo(std::bitset<16> x) {
	std::bitset<16> norm = 0;
	
	norm[15] = x[15]; norm[14] = x[14]; norm[13] = x[13]; norm[ 7] = x[12];
	norm[12] = x[11]; norm[11] = x[10]; norm[ 6] = x[ 9]; norm[10] = x[ 8];
	norm[ 9] = x[ 7]; norm[ 5] = x[ 6]; norm[ 8] = x[ 5]; norm[ 4] = x[ 4];
	norm[ 3] = x[ 3]; norm[ 2] = x[ 2]; norm[ 1] = x[ 1]; norm[ 0] = x[ 0];
	
	return norm;
};
