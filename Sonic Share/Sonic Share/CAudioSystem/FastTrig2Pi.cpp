//
//  FastTrig2Pi.cpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import "FastTrig2Pi.hpp"
#import <math.h>

///Lut from 0 to pi/2

double sin4mac(double x) {
	return 6.2831853072 * x - 41.3417022404 * pow(x, 3) + 81.6052492761 * pow(x, 5) - 76.7058597531 * pow(x, 7);
};


double fast_sin2pi(double x) {
	const double m = fmod(x, 1);
	const double a = abs(abs(-abs(m-0.25)+0.5)-0.25);
	
	return sin4mac(abs(a)) * (m > 0.5 ? -1 : 1);
};
