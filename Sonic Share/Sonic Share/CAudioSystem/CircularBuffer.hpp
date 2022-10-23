//
//  CircularBuffer.hpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import <stdio.h>
#import <atomic>

template<class T> struct CircularBuffer {
private:
	T * const buffer;
	const int size;
	std::atomic<int> nextWrite;
	std::atomic<int> nextRead;
	
public:
	CircularBuffer(int size);
	~CircularBuffer();
	
	void reset();
	void write(T * newBuffer, int size);
	int unreadSize();
	int read(T * newBuffer, int maxSize);
	int preview(T * newBuffer, int maxSize) const;
	int purge(int maxSize);
};

#import "CircularBuffer.mm"
