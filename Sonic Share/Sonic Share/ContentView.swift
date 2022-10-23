//
//  ContentView.swift
//  Sonic Share
//
//  Created by Yuanda Liu on 10/19/22.
//

import SwiftUI

struct ContentView: View {
	
	@StateObject var audioSystem = AudioSystem()
	
	var body: some View {
		TabView {
			ReceiveView(audioSystem: audioSystem)
				.tabItem {
					Label("Received", systemImage: "phone.connection")
				}
			
			SendView(audioSystem: audioSystem)
				.tabItem {
					Label("Send", systemImage: "dot.radiowaves.left.and.right")
				}
		}
		.task {
			audioSystem.setup()
		}
	}
}

struct CircleButton: View {
	
	var systemImage: String
	var completion: ()->Void
	
	var body: some View {
		Button {
			completion()
		} label: {
			ZStack {
				Image(systemName: systemImage)
					.frame(width: 40, height: 40, alignment: .center)
					.font(.system(size: 25, weight: .regular, design: .rounded))
					.foregroundColor(.accentColor)


				Circle()
					.strokeBorder(lineWidth: 2)
					.foregroundColor(.accentColor)
					.opacity(0.3)
			}
			.frame(width: 50, height: 50)
		}
	}
}

struct CircleToggle: View {
	
	@Binding var isOn: Bool
	var systemImage: String
	
	var body: some View {
		Button {
			isOn.toggle()
		} label: {
			ZStack {
				if isOn {
					Circle()
						.foregroundColor(.accentColor)
					
					Image(systemName: systemImage)
						.frame(width: 40, height: 40, alignment: .center)
						.font(.system(size: 25, weight: .bold, design: .rounded))
						.foregroundColor(Color(.systemBackground))
				} else {
					Image(systemName: systemImage)
						.frame(width: 40, height: 40, alignment: .center)
						.font(.system(size: 25, weight: .regular, design: .rounded))
						.foregroundColor(.accentColor)
						
					
					Circle()
						.strokeBorder(lineWidth: 2)
						.foregroundColor(.accentColor)
						.opacity(0.3)
				}
			}
			.frame(width: 50, height: 50)
		}
		.frame(width: 50, height: 50)
	}
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.previewLayout(PreviewLayout.fixed(width: 1000, height: 600))
	}
}
