//
//  TrainMap.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import SwiftUI

struct TrainMap: View {
    @State var scale: CGFloat = 1.0
    @State var isTapped: Bool = false
    @State var pointTapped: CGPoint = CGPoint.zero
    @State var draggedSize: CGSize = CGSize.zero
    @State var previousDragged: CGSize = CGSize.zero
    
    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 12) {
                Text("MRT Map")
                    .bold()
                    .font(.largeTitle)
                    .frame(alignment: .leading)
                Image("sgtrainmap")
                    .resizable()
                    .scaledToFit()
                    .animation(.default)
                    .offset(x: self.draggedSize.width, y: self.draggedSize.height)
                    .scaleEffect(self.scale)
                    .scaleEffect(self.isTapped ? 2 : 1, anchor: UnitPoint(x: self.pointTapped.x / reader.frame(in: .global).maxX, y: self.pointTapped.y / reader.frame(in: .global).maxY))
                    .gesture(TapGesture(count: 2).onEnded({
                        self.isTapped = !self.isTapped
                    }).simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged({(val) in
                        self.pointTapped = val.startLocation
                        self.draggedSize = CGSize(width: val.translation.width + self.previousDragged.width, height: val.translation.height + self.previousDragged.height)
                    }).onEnded({ (val) in
                        let offsetWidth = (reader.frame(in: .global).maxX * self.scale - reader.frame(in: .global).maxX) / 2
                        let newDraggedWidth = self.draggedSize.width * self.scale
                        if (newDraggedWidth > offsetWidth) {
                            self.draggedSize = CGSize(width: offsetWidth / self.scale, height: val.translation.height + self.previousDragged.height)
                        } else if (newDraggedWidth < -offsetWidth) {
                            self.draggedSize = CGSize(width: -offsetWidth / self.scale, height: val.translation.height + self.previousDragged.height)
                        } else {
                            self.draggedSize = CGSize(width: val.translation.width + self.previousDragged.width, height: val.translation.height + self.previousDragged.height)
                        }
                        self.previousDragged = self.draggedSize
                    })))
                    .gesture(MagnificationGesture().onChanged({ (scale) in
                        self.scale = scale.magnitude
                    }).onEnded({ (scaleFinal) in
                        self.scale = scaleFinal.magnitude
                    }))
            }
        }
            
    }
}

