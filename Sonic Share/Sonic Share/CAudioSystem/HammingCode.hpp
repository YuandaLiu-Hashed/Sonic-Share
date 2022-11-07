//
//  HammingCode.hpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/21/22.
//

#import <stdio.h>
#import <iostream>
#import <array>

std::bitset<16> encodeHamm15_11_SECDED(std::bitset<16> data);
std::tuple<std::bitset<16>, bool> decodeHamm15_11_SECDED(std::bitset<16> data);
