//
//  HeroCardView.swift
//  Local-TTS
    

import SwiftUI

struct HeroCardView: View {
    private let systemIcon: String = "rectangle.3.offgrid.bubble.left.fill"
    private let color: Color = .blue
    private let iconRotation: Double = 40
    
    var body: some View {
        Section {
            HStack {
                Image(systemName: systemIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white, color)
                    .frame(width: 50, height: 50)
                    .background(color.quaternary, in: .rect(cornerRadius: 12))
            
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Text To Speech")
                        .font(.title.bold().smallCaps()).fontDesign(.rounded)
                    
                    Text("On your device")
                        .textScale(.secondary)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 30) // to center it
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background {
                color
                    .frame(maxWidth: .infinity, maxHeight: 14)
                    .blur(radius: 50)
            }
            .background(alignment: .bottomTrailing) {
                Image(systemName: systemIcon)
                    .font(.system(size: 270))
                    .foregroundStyle(.gray.opacity(0.06))
                    .rotationEffect(.degrees(iconRotation))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .listRowSeparator(.hidden, edges: .bottom)
    }
}
