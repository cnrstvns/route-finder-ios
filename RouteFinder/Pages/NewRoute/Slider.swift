//
//  Slider.swift
//  RouteFinder
//
//  Created by Connor Stevens on 11/22/24.
//

import Foundation
import SwiftUI
import Combine

//SliderValue to restrict double range: 0.0 to 1.0
@propertyWrapper
struct SliderValue {
    var value: Double
    
    init(wrappedValue: Double) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Double {
        get { value }
        set { value = min(max(0.0, newValue), 1.0) }
    }
}

class SliderHandle: ObservableObject {
    //Slider Size
    @Published var sliderWidth: CGFloat
    @Published var sliderHeight: CGFloat
    
    //Slider Range
    let sliderValueStart: Double
    let sliderValueRange: Double
    
    //Slider Handle
    var diameter: CGFloat = 32
    var startLocation: CGPoint
    
    //Current Value
    @Published var currentPercentage: SliderValue
    
    //Slider Button Location
    @Published var onDrag: Bool
    @Published var currentLocation: CGPoint
        
    init(sliderWidth: CGFloat, sliderHeight: CGFloat, sliderValueStart: Double, sliderValueEnd: Double, startPercentage: SliderValue) {
        self.sliderWidth = sliderWidth
        self.sliderHeight = sliderHeight
        
        self.sliderValueStart = sliderValueStart
        self.sliderValueRange = sliderValueEnd - sliderValueStart
        
        self.startLocation = CGPoint(
            x: CGFloat(startPercentage.wrappedValue) * sliderWidth,
            y: sliderHeight / 2
        )
        
        self.currentLocation = startLocation
        self.currentPercentage = startPercentage
        
        self.onDrag = false
    }
    
    lazy var sliderDragGesture: _EndedGesture<_ChangedGesture<DragGesture>>  = DragGesture()
        .onChanged { value in
            self.onDrag = true
            
            let dragLocation = value.location
            
            //Restrict possible drag area
            self.restrictSliderBtnLocation(dragLocation)
            
            //Get current value
            self.currentPercentage.wrappedValue = Double(self.currentLocation.x / self.sliderWidth)
            
        }.onEnded { _ in
            self.onDrag = false
        }
    
    private func restrictSliderBtnLocation(_ dragLocation: CGPoint) {
        //On Slider Width
        if dragLocation.x > CGPoint.zero.x && dragLocation.x < sliderWidth {
            calcSliderBtnLocation(dragLocation)
        }
    }
    
    private func calcSliderBtnLocation(_ dragLocation: CGPoint) {
        if dragLocation.y != sliderHeight/2 {
            currentLocation = CGPoint(x: dragLocation.x, y: sliderHeight/2)
        } else {
            currentLocation = dragLocation
        }
    }
    
    //Current Value
    var currentValue: Double {
        return sliderValueStart + currentPercentage.wrappedValue * sliderValueRange
    }
}

class CustomSlider: ObservableObject {
    // Slider Size (Dynamic)
    let lineWidth: CGFloat = 8
    @Published var width: CGFloat = 0 // Dynamically set width
    
    // Slider value range from valueStart to valueEnd
    let valueStart: Double
    let valueEnd: Double
    
    // Slider Handles
    @Published var highHandle: SliderHandle
    @Published var lowHandle: SliderHandle
    
    // Handle start percentage (also for starting point)
    @SliderValue var highHandleStartPercentage = 1.0
    @SliderValue var lowHandleStartPercentage = 0.0

    var anyCancellableHigh: AnyCancellable?
    var anyCancellableLow: AnyCancellable?
    
    init(start: Double, end: Double, width: CGFloat) {
        self.valueStart = start
        self.valueEnd = end
        self.width = width
        
        _lowHandleStartPercentage = SliderValue(wrappedValue: (1.0 - start) / (end - start)) // 1 hour
        _highHandleStartPercentage = SliderValue(wrappedValue: (4.0 - start) / (end - start)) // 4 hours

        highHandle = SliderHandle(
            sliderWidth: width,
            sliderHeight: lineWidth,
            sliderValueStart: valueStart,
            sliderValueEnd: valueEnd,
            startPercentage: _highHandleStartPercentage
        )
        
        lowHandle = SliderHandle(
            sliderWidth: width,
            sliderHeight: lineWidth,
            sliderValueStart: valueStart,
            sliderValueEnd: valueEnd,
            startPercentage: _lowHandleStartPercentage
        )
        
        anyCancellableHigh = highHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        anyCancellableLow = lowHandle.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }
    
    // Percentages between high and low handles
    var percentagesBetween: String {
        return String(format: "%.2f", highHandle.currentPercentage.wrappedValue - lowHandle.currentPercentage.wrappedValue)
    }
    
    // Value between high and low handles
    var valueBetween: String {
        return String(format: "%.2f", highHandle.currentValue - lowHandle.currentValue)
    }
}

struct SliderView: View {
    @ObservedObject var slider: CustomSlider
    
    var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width
            
            RoundedRectangle(cornerRadius: slider.lineWidth)
                .fill(Color.gray.opacity(0.2))
                .frame(width: sliderWidth, height: slider.lineWidth)
                .overlay(
                    ZStack {
                        // Path between both handles
                        SliderPathBetweenView(slider: slider)
                        
                        // Low Handle
                        SliderHandleView(handle: slider.lowHandle)
                            .highPriorityGesture(slider.lowHandle.sliderDragGesture)
                        
                        // High Handle
                        SliderHandleView(handle: slider.highHandle)
                            .highPriorityGesture(slider.highHandle.sliderDragGesture)
                    }
                ).onAppear {
                    slider.width = sliderWidth
                    slider.highHandle.sliderWidth = sliderWidth
                    slider.lowHandle.sliderWidth = sliderWidth
                    
                    // Update handle positions based on current percentages
                    slider.highHandle.currentLocation = CGPoint(
                        x: CGFloat(slider.highHandle.currentPercentage.wrappedValue) * sliderWidth,
                        y: slider.highHandle.sliderHeight / 2
                    )
                    slider.lowHandle.currentLocation = CGPoint(
                        x: CGFloat(slider.lowHandle.currentPercentage.wrappedValue) * sliderWidth,
                        y: slider.lowHandle.sliderHeight / 2
                    )
                }
        }
        .frame(maxHeight: slider.lineWidth + slider.lowHandle.diameter)
    }
}

struct SliderHandleView: View {
    @ObservedObject var handle: SliderHandle
    
    var body: some View {
        Circle()
            .frame(width: handle.diameter, height: handle.diameter)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
            .contentShape(Rectangle())
            .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
    }
}

struct SliderPathBetweenView: View {
    @ObservedObject var slider: CustomSlider
    
    var body: some View {
        Path { path in
            path.move(to: slider.lowHandle.currentLocation)
            path.addLine(to: slider.highHandle.currentLocation)
        }
        .stroke(.blue, lineWidth: slider.lineWidth)
    }
}

struct SliderPreview: View {
    @StateObject private var slider = CustomSlider(start: 0, end: 20, width: UIScreen.main.bounds.width)

    var body: some View {
        VStack {
            Text("Custom Slider Preview")
                .font(.headline)
                .padding(.bottom, 16)
            
            SliderView(slider: slider)
                .background(.red)
            
            Text("Selected Range: \(String(format: "%.1f", slider.lowHandle.currentValue)) - \(String(format: "%.1f", slider.highHandle.currentValue)) hours")
                .padding(.top, 16)
                .font(.subheadline)
        }
        .padding()
        .onAppear {
            slider.width = UIScreen.main.bounds.width - 40 // Adjust for padding
        }
    }
}

#Preview {
    SliderPreview()
}
