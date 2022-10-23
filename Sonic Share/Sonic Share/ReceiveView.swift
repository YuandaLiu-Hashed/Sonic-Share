//
//  ReceiveView.swift
//  Sonic Share
//
//  Created by Yuanda Liu on 10/22/22.
//

import SwiftUI

struct ReceiveView: View {
	@Environment(\.colorScheme) var colorScheme
	
	@ObservedObject var audioSystem: AudioSystem
	
	var body: some View {
		VStack(spacing: 50) {
			Spacer()
			
			VStack {
				Text("RECEIVED MESSAGE")
					.font(.system(size: 10, weight: .bold, design: .monospaced))
				Text(audioSystem.receivedString)
					.multilineTextAlignment(.center)
					.font(.system(size: 30, weight: .regular, design: .monospaced))
					.contentTransition(.interpolate)
			}
			
			HStack {
//				CircleToggle(isOn: $toggle, systemImage: "square")
				
				CircleButton(systemImage: "xmark") {
					audioSystem.receivedString = "---"
				}
				
				if (audioSystem.receivedString != "---") {
					CircleButton(systemImage: "doc.on.doc") {
						UIPasteboard.general.string = audioSystem.receivedString
					}
					.transition(.scale)
				}
				
				if (audioSystem.receivedString != "---" && audioSystem.urlString != nil) {
					CircleButton(systemImage: "arrow.forward") {
						if let urlString = audioSystem.urlString {
							if let url = URL(string: urlString) {
								UIApplication.shared.open(url)
							}
						}
					}
					.transition(.scale)
				}
			}
			
			HStack {
				Spacer()
			}
			
			Spacer()
		}
		.padding()
		.background {
			background
		}
	}
	
	var background: some View {
		ZStack(alignment: .center) {
			if audioSystem.isReceiving {
				GeometryReader { geo in
					let cornSize = sqrt(pow(geo.size.width, 2) + pow(geo.size.height, 2))
					ZStack {
						let bg: Color = .orange
						let gradientStops: [Gradient.Stop] = [.init(color: bg.opacity(0), location: 0),
															  .init(color: bg.opacity(0.1), location: 0.5),
															  .init(color: bg.opacity(0.2), location: 1)]
						Circle()
							.fill(RadialGradient(stops: gradientStops, center: .center, startRadius: 0, endRadius: cornSize / 2))
							.frame(width: cornSize, height: cornSize)
					}
					.frame(width: geo.size.width, height: geo.size.height)
				}
				.aspectRatio(contentMode: .fill)
				.transition(.asymmetric(insertion: .opacity, removal: .opacity))
			}
		}
		.animation(.easeOut(duration: 0.5), value: audioSystem.isReceiving)
	}
}
