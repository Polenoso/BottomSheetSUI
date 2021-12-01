//
//  SwiftUIView.swift
//
//
//  Created by Aitor Pagán on 28/11/21.
//
//  Copyright ® Granted

import SwiftUI

public enum SheetDetent: Comparable {
    case small
    case medium
    case large
}

public struct BottomSheetView<Content: View>: View {
    let content: Content
    @State var currentDetent: SheetDetent = .small
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    private var detents: Set<SheetDetent>
    @State private var lastDetent: SheetDetent = .small
    public init(detents: [SheetDetent] = [.small, .medium, .large],
                @ViewBuilder content: () -> Content) {
        self.detents = Set(detents.sorted())
        self.content = content()
        self.lastDetent = detents.min() ?? .small
        self.currentDetent = detents.min() ?? .small
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let height = proxy.frame(in: .global).height
            ZStack {
                Color.secondary
                    .clipShape(CustomCorner(corners: [.topLeft, .topRight],
                                            radius: 30))
                VStack {
                    Capsule()
                        .fill(Color.primary)
                        .frame(width: 60, height: 4)
                        .padding(.top)
                        .onTapGesture {
                            self.nextDetent(for: height)
                        }
                    
                    content
                        .padding(.top)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .offset(y: height - minHeight(height))
            .offset(y: offset)
            .gesture(DragGesture()
                        .updating($gestureOffset,
                                  body: { value, out, transaction in
                out = value.translation.height
                self.onChange()
            })
                        .onEnded({ value in
                self.setDetent(for: height)
                lastOffset = offset
            }))
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func minHeight(_ height: CGFloat) -> CGFloat {
        switch detents.min() ?? .small {
        case .small:
            return 100
        case .medium:
            return height / 2
        case .large:
            return height
        }
    }
    
    private func maxHeight(_ height: CGFloat) -> CGFloat {
        switch detents.max() ?? .large {
        case .small:
            return 100
        case .medium:
            return (height / 2) - 100
        case .large:
            return height - 100
        }
    }
    
    private func onChange() {
        DispatchQueue.main.async {
            self.offset = self.gestureOffset + self.lastOffset
        }
    }
    
    private func setDetent(for height: CGFloat) {
        withAnimation {
            for detent in detents {
                if thresholdForDetent(height, detent).contains(-offset) {
                    setFinalHeightForDetent(height, detent)
                    return
                }
            }
            
            if -offset <= thresholdForDetent(height, detents.min() ?? .small).lowerBound {
                setFinalHeightForDetent(height, detents.min() ?? .small)
                return
            }
            
            if -offset >= thresholdForDetent(height, detents.max() ?? .small).upperBound {
                setFinalHeightForDetent(height, detents.max() ?? .large)
                return
            }
            
            if -offset > -(lastOffset + 200) {
                if let nextDetent = detents.first(where: { $0 > currentDetent }) {
                    setFinalHeightForDetent(height, nextDetent)
                } else {
                    setFinalHeightForDetent(height, currentDetent)
                }
                return
            }
            if -offset < -(lastOffset + 200) {
                if let nextDetent = detents.first(where: { $0 < currentDetent }) {
                    setFinalHeightForDetent(height, nextDetent)
                } else {
                    setFinalHeightForDetent(height, currentDetent)
                }
                return
            }
        }
    }
    
    private func thresholdForDetent(_ height: CGFloat, _ detent: SheetDetent) -> ClosedRange<CGFloat> {
        switch detent {
        case .small:
            return -100...200
        case .medium:
            let mid = height / 2
            return (mid-200)...(mid+200)
        case .large:
            return (height-100)...(height+100)
        }
    }
    
    private func setFinalHeightForDetent(_ containerHeight: CGFloat, _ detent: SheetDetent) {
        let maxHeight = containerHeight - minHeight(containerHeight)
        let oldDetent = currentDetent
        switch detent {
        case .small:
            offset = 0
            currentDetent = .small
        case .medium:
            offset = -maxHeight / 2
            currentDetent = .medium
        case .large:
            offset = -maxHeight
            currentDetent = .large
        }
        lastDetent = currentDetent == detent ? oldDetent : lastDetent
    }
    
    private func nextDetent(for height: CGFloat) {
        withAnimation {
            switch currentDetent {
            case .small:
                let remainingDetents = detents.filter({ $0 != currentDetent })
                guard !remainingDetents.isEmpty else { return }
                let nextDetent = remainingDetents.min() ?? .medium
                setFinalHeightForDetent(height, nextDetent)
            case .medium:
                if lastDetent == .small && detents.max() != currentDetent {
                    let nextDetent = detents.max() ?? .large
                    setFinalHeightForDetent(height, nextDetent)
                } else if lastDetent == .large && detents.min() != currentDetent {
                    let nextDetent = detents.min() ?? .small
                    setFinalHeightForDetent(height, nextDetent)
                } else {
                    setFinalHeightForDetent(height, lastDetent)
                }
            case .large:
                let remainingDetents = detents.filter({ $0 != currentDetent })
                guard !remainingDetents.isEmpty else { return }
                let nextDetent = remainingDetents.max() ?? .medium
                setFinalHeightForDetent(height, nextDetent)
            }
            lastOffset = offset
        }
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}
