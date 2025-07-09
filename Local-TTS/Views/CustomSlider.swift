//
//  CustomSlider.swift
//  Local-TTS


import SwiftUI

// https://github.com/christianselig/JunoSlider
struct JunoSlider: View {
    @Binding var sliderValue: CGFloat
    let maxSliderValue: CGFloat
    let baseHeight: CGFloat
    let expandedHeight: CGFloat
    let label: String
    let editingChanged: ((Bool) -> Void)?
    
    @State private var isGestureActive: Bool = false
    @State private var startingSliderValue: CGFloat?
    @State private var sliderWidth = 10.0
    @State private var isAtTrackExtremity = false
    

    public init(sliderValue: Binding<Float>, maxSliderValue: CGFloat, baseHeight: CGFloat = 9.0, expandedHeight: CGFloat = 20.0, label: String, editingChanged: ((Bool) -> Void)? = nil) {
        self._sliderValue = .init(get: {
            return CGFloat(sliderValue.wrappedValue)
        }, set: { value in
            sliderValue.wrappedValue = Float(value)
        })
        
        self.maxSliderValue = maxSliderValue
        self.baseHeight = baseHeight
        self.expandedHeight = expandedHeight
        self.label = label
        self.editingChanged = editingChanged
    }
    
    public var body: some View {
        ZStack {
            Color.orange.opacity(0.0001)
                .frame(height: 40.0)
            
            Capsule()
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                sliderWidth = proxy.size.width
                            }
                    }
                }
                .frame(height: isGestureActive ? expandedHeight : baseHeight)
                .foregroundStyle(
                    Color(white: 0.1, opacity: 0.5)
                        .shadow(.inner(color: .black.opacity(0.3), radius: 3.0, y: 2.0))
                )
                .shadow(color: .white.opacity(0.2), radius: 1, y: 1)
                .overlay(alignment: .leading) {
                    Capsule()
                        .overlay(alignment: .trailing) {
                            Circle()
                                .foregroundStyle(Color.white)
                                .shadow(radius: 1.0)
                                .padding(innerCirclePadding)
                                .opacity(isGestureActive ? 1.0 : 0.0)
                        }
                        .foregroundStyle(Color(white: isGestureActive ? 0.85 : 1.0))
                        .frame(width: calculateProgressWidth(), height: isGestureActive ? expandedHeight : baseHeight)
                }
                .clipShape(.capsule)
                .contentShape(.hoverEffect, .capsule)
        }
        .gesture(DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                if startingSliderValue == nil {
                    startingSliderValue = sliderValue
                    isGestureActive = true
                    editingChanged?(true)
                }
                
                let percentagePointsIncreased = value.translation.width / sliderWidth
                let initialPercentage = (startingSliderValue ?? sliderValue) / maxSliderValue
                let newPercentage = min(1.0, max(0.0, initialPercentage + percentagePointsIncreased))
                sliderValue = newPercentage * maxSliderValue
                
                if newPercentage == 0.0 && !isAtTrackExtremity {
                    isAtTrackExtremity = true
                } else if newPercentage == 1.0 && !isAtTrackExtremity {
                    isAtTrackExtremity = true
                } else if newPercentage > 0.0 && newPercentage < 1.0 {
                    isAtTrackExtremity = false
                }
            }
            .onEnded { value in
                if value.translation.width == 0.0 {
                    let newPercentage = value.location.x / sliderWidth
                    
                    withAnimation {
                        sliderValue = newPercentage * maxSliderValue
                    }
                }
                
                startingSliderValue = nil
                isGestureActive = false
                editingChanged?(false)
            }
        )
        .hoverEffect(.highlight)
        .animation(.default, value: isGestureActive)
        .accessibilityRepresentation {
            Slider(value: $sliderValue, in: 0.0 ... maxSliderValue, label: {
                Text(label)
            }, onEditingChanged: { editingChanged in
                self.editingChanged?(editingChanged)
            })
        }
    }
    
    private var innerCirclePadding: CGFloat { expandedHeight * 0.15 }
    
    private func calculateProgressWidth() -> CGFloat {
        let minimumWidth = isGestureActive ? expandedHeight : baseHeight
        let calculatedWidth = (sliderValue / maxSliderValue) * sliderWidth
        
        return max(minimumWidth, calculatedWidth)
    }
}
