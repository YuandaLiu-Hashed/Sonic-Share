//
//  Sonic_Share_Tests.m
//  Sonic Share Tests
//
//  Created by Yuanda Liu on 10/19/22.
//

#import <XCTest/XCTest.h>
#import "CircularBuffer.hpp"

@interface Circular_Buffer_Tests : XCTestCase

@end

@implementation Circular_Buffer_Tests {
	CircularBuffer<UInt32> * buffer;
}

- (void)setUp {
	buffer = new CircularBuffer<UInt32>(8);
}

- (void)tearDown {
	delete buffer;
}

- (void)test_buffer {
	UInt32 * testBuffer;
	UInt32 * readingBuffer;
	testBuffer = (UInt32 *)malloc(sizeof(UInt32) * 5);
	readingBuffer = (UInt32 *)malloc(sizeof(UInt32) * 8);
	readingBuffer[5] = 27;
	testBuffer[0] = 0;
	testBuffer[1] = 1;
	testBuffer[2] = 2;
	testBuffer[3] = 3;
	testBuffer[4] = 4;
	
	buffer->write(testBuffer, 5);
	const int size = buffer->read(readingBuffer, 8);
	XCTAssertEqual(size, 5);
	XCTAssertEqual(readingBuffer[0], 0);
	XCTAssertEqual(readingBuffer[1], 1);
	XCTAssertEqual(readingBuffer[2], 2);
	XCTAssertEqual(readingBuffer[3], 3);
	XCTAssertEqual(readingBuffer[4], 4);
	XCTAssertEqual(readingBuffer[5], 27);
	
	testBuffer[0] = 7;
	testBuffer[1] = 6;
	testBuffer[2] = 5;
	testBuffer[3] = 4;
	testBuffer[4] = 3;
	buffer->write(testBuffer, 5);
	const int size2 = buffer->read(readingBuffer, 8);
	XCTAssertEqual(size2, 5);
	XCTAssertEqual(readingBuffer[0], 7);
	XCTAssertEqual(readingBuffer[1], 6);
	XCTAssertEqual(readingBuffer[2], 5);
	XCTAssertEqual(readingBuffer[3], 4);
	XCTAssertEqual(readingBuffer[4], 3);
	XCTAssertEqual(readingBuffer[5], 27);
	
	const int size3 = buffer->read(readingBuffer, 8);
	XCTAssertEqual(size3, 0);
}

@end
