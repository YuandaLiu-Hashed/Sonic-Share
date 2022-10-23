//
//  Shared.hpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/20/22.
//
#import <stdio.h>
#import <tuple>
#import <bitset>

typedef std::tuple<float, float, float, float> IntensityPoint;
typedef std::tuple<bool, bool, bool, bool> MessageFragment;

std::bitset<16> jumbo(std::bitset<16> x);
std::bitset<16> unJumbo(std::bitset<16> x);

//constexpr double kTpSec = 262.5;
constexpr double kTpSec = 150;


//0 - 00
//1 - 10
//2 - 11
//3 - 01
