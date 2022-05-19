//
//  DetectableScrollView.swift
//  SwiftUI Dynamic Scroll View
//
//  Created by Vinnie Liu on 19/5/2022.
//

import Combine
import SwiftUI

struct DetectableScrollView<Content: View>: View {
    private let contentView: Content
    private let direction: Axis.Set
    private let showsIndicators: Bool
    private let onScrollEnded: () -> Void
    private let detector: CurrentValueSubject<CGFloat, Never> = .init(0)
    private let publisher: AnyPublisher<CGFloat, Never>
    
    init(
        direction: Axis.Set = .horizontal,
        showsIndicators: Bool = false,
        scrollDetectionDelay: CGFloat = 0.2,
        @ViewBuilder contentView: () -> Content,
        onScrollEnded: @escaping () -> Void
    ) {
        self.direction = direction
        self.showsIndicators = showsIndicators
        self.contentView = contentView()
        self.onScrollEnded = onScrollEnded
        
        publisher = detector
            .debounce(for: .seconds(scrollDetectionDelay), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        ScrollView(direction, showsIndicators: showsIndicators) {
            contentView
                .modifier(OriginValueModifier(direction: direction))
                .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
        }
        .coordinateSpace(name: OriginValueModifier.coordinateSpaceName)
        .onReceive(publisher) { _ in onScrollEnded() }
    }
}

fileprivate struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

fileprivate struct OriginValueModifier: ViewModifier {
    let direction: Axis.Set
    static var coordinateSpaceName: String = "scrollView"
    var sizeView: some View {
        GeometryReader {
            Color.clear.preference(
                key: ViewOffsetKey.self,
                value: direction == .horizontal
                ? -$0.frame(in: .named(OriginValueModifier.coordinateSpaceName)).origin.x
                : -$0.frame(in: .named(OriginValueModifier.coordinateSpaceName)).origin.y
            )
        }
    }
    
    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

