//
//  Audio System.swift
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

import Foundation
import AVFAudio
import Combine
import AVFoundation

class AudioSystem: ObservableObject {
	
	private var cAudioSystem: CAudioSystem?
	private let audioSession = AVAudioSession.sharedInstance()
	private var fetchingTimer: Timer?
	private var fetchingBuffer = ContiguousArray<UInt8>(repeating: 0, count: 2048)
	
	@Published var sendingString: String = ""
	@Published var sending: Bool = false
	@Published var loopMode: Bool = false
	
	@Published var receivedString: String = "---"
	var urlString: String? = nil
	@Published var isReceiving: Bool = false
	
	init() {
		cAudioSystem = CAudioSystem()
		do {
			try audioSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: [.defaultToSpeaker])
		} catch {
			print("Failed to set audio session category with error: \(error)")
		}
	}
	
	func setup() {
		audioSession.requestRecordPermission { successful in
			if !successful {
				print("requestRecordPermission is unsuccessful")
			}
			self.start()
		}
		
		fetchingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: fetchCycle)
	}
	
	func start() {
		do {
			try audioSession.setActive(true)
		} catch {
			print("Failed to activate audio session with error: \(error)")
			return
		}
		
		cAudioSystem = CAudioSystem()
		
		cAudioSystem!.start()
	}
	
	private func fetchCycle(_ timer: Timer) {
		guard let cAudioSystem = cAudioSystem else { return }
		
		let isListening = cAudioSystem.isListening()
		if isListening != isReceiving { isReceiving = isListening }
		
		let size = fetchingBuffer.withUnsafeMutableBufferPointer { ptr in
			cAudioSystem.readBytes(ptr.baseAddress!)
		}
		
		if size > 0 {
			let bytes = [UInt8](fetchingBuffer.prefix(Int(size)))
			receivedString = String(bytes: bytes, encoding: .utf8) ?? "Bad Encoding"
			urlString = detectURL(input: receivedString)
			print("Received: \(receivedString)")
		}
	}
	
	func stop() {
		guard let cAudioSystem = cAudioSystem else { return }
		try! audioSession.setActive(false)
		cAudioSystem.stop()
		fetchingTimer?.invalidate()
	}
	
	func send() {
		guard let cAudioSystem = cAudioSystem else { return }
		let msg = sendingString
		guard msg.count > 0 else { return }
		
		sending = true
		var bytes = [UInt8](msg.utf8)
		cAudioSystem.sendBytes(&bytes, size: Int32(msg.count));
		
		let msgTickSize: Int = (msg.count + 2) * 8 + 1
		Timer.scheduledTimer(withTimeInterval: Double(msgTickSize) / 150, repeats: false) { [weak self] _ in
			self?.sending = false
			
			if self?.loopMode == true {
				Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
					if self?.loopMode == true {
						self?.send()
					}
				}
			}
		}
	}
}

func detectURL(input: String) -> String? {
	let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
	let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
	for match in matches {
		guard let range = Range(match.range, in: input) else { continue }
		let url = input[range]
		return String(url)
	}
	return nil
}
