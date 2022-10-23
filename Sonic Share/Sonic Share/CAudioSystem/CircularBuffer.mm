//
//  CircularBuffer.cpp
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

#import "CircularBuffer.hpp"
#import <memory>
#import <Accelerate/Accelerate.h>

template<class T> CircularBuffer<T>::CircularBuffer(int size): size(size), buffer((T *)malloc(sizeof(T) * size)) {
	nextRead = 0;
	nextWrite = 0;
};

template<class T> CircularBuffer<T>::~CircularBuffer() {
	free(buffer);
};

template<class T> void CircularBuffer<T>::reset() {
	nextRead = 0;
	nextWrite = 0;
};

template<class T> void CircularBuffer<T>::write(T * newBuffer, int size) {
	int nextWrite = this->nextWrite;
	const int firstCopySize = std::min(nextWrite + size, this->size) - nextWrite;
	memcpy(buffer + nextWrite, newBuffer, firstCopySize * sizeof(T));
	nextWrite = (nextWrite + firstCopySize) % this->size;
	if (firstCopySize == size) {
		this->nextWrite = nextWrite;
		return;
	};
	const int secondCopySize = size - firstCopySize;
	memcpy(buffer, newBuffer + firstCopySize, secondCopySize * sizeof(T));
	this->nextWrite = secondCopySize;
};

template<class T> int CircularBuffer<T>::preview(T * newBuffer, int maxSize) const {
	int nextRead = this->nextRead;
	const int nextWrite = this->nextWrite;
	if (nextRead == nextWrite) return 0;
	int sizeToRead = std::min(nextWrite - nextRead + ((nextWrite > nextRead) ? 0 : this->size), maxSize);
	const int firstCopySize = std::min(nextRead + sizeToRead, this->size ) - nextRead;
	memcpy(newBuffer, buffer + nextRead, firstCopySize * sizeof(T));
	nextRead = (nextRead + firstCopySize) % this->size;
	if (firstCopySize == sizeToRead) {
		return sizeToRead;
	};
	const int secondCopySize = sizeToRead - firstCopySize;
	memcpy(newBuffer + firstCopySize, buffer, secondCopySize * sizeof(T));
	return sizeToRead;
};

template<class T> int CircularBuffer<T>::read(T * newBuffer, int maxSize) {
	int readSize = preview(newBuffer, maxSize);
	this->nextRead = (this->nextRead + readSize) % this->size;
	return readSize;
};

template<class T> int CircularBuffer<T>::unreadSize() {
	const int nextRead = this->nextRead;
	const int nextWrite = this->nextWrite;
	if (nextRead == nextWrite) return 0;
	return nextWrite - nextRead + ((nextWrite > nextRead) ? 0 : this->size);
};

template<class T> int CircularBuffer<T>:: purge(int maxSize) {
	const int purgeAmount = std::min(unreadSize(), maxSize);
	nextRead = (nextRead + purgeAmount) % size;
	return purgeAmount;
};
