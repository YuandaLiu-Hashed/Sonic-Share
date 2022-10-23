//
//  SendView.swift
//  Sonic Share
//
//  Created by Yuanda Liu on 10/22/22.
//

import SwiftUI

struct SendView: View {
	@Environment(\.colorScheme) var colorScheme
	
	@ObservedObject var audioSystem: AudioSystem
	
	var body: some View {
		VStack(spacing: 50) {
			Spacer()
			
			Text("SEND BOX")
				.font(.system(size: 10, weight: .bold, design: .monospaced))
			
			TextField("Message", text: $audioSystem.sendingString)
				.multilineTextAlignment(.center)
				.font(.system(size: 30, weight: .regular, design: .monospaced))
			
			HStack {
				CircleToggle(isOn: $audioSystem.loopMode, systemImage: "arrow.triangle.2.circlepath")
				
				CircleButton(systemImage: "paperplane") {
					audioSystem.send()
				}
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
			if audioSystem.sending {
				GeometryReader { geo in
					let cornSize = sqrt(pow(geo.size.width, 2) + pow(geo.size.height, 2))
					ZStack {
						let color: Color = .orange//colorScheme == .dark ? .white : .black
						let gradientStops: [Gradient.Stop] = [.init(color: color.opacity(0.15), location: 0),
															  .init(color: color.opacity(0.2), location: 0.8),
															  .init(color: color.opacity(0.3), location: 1)]
						Circle()
							.fill(RadialGradient(stops: gradientStops, center: .center, startRadius: 0, endRadius: cornSize / 2))
							.frame(width: cornSize, height: cornSize)
					}
					.frame(width: geo.size.width, height: geo.size.height)
				}
				.aspectRatio(contentMode: .fill)
				.transition(.asymmetric(insertion: .scale, removal: .opacity))
			}
			
			if !audioSystem.sending {
				GeometryReader { geo in
					let cornSize = sqrt(pow(geo.size.width, 2) + pow(geo.size.height, 2))
					ZStack {
						Circle()
							.foregroundColor(Color(.systemBackground))
							.frame(width: cornSize, height: cornSize)
					}
					.frame(width: geo.size.width, height: geo.size.height)
				}
				.aspectRatio(contentMode: .fill)
				.transition(.asymmetric(insertion: .scale, removal: .identity))
			}
		}
		.animation(.easeOut(duration: 0.5), value: audioSystem.sending)
	}
}
