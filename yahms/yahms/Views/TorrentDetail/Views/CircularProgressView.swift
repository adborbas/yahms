//
//  CircularProgressView.swift
//  yahms
//

import SwiftUI

struct CircularProgressView: View {
    @Binding var progress: Float
    var lineWidth: CGFloat = 6
    var showsText = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(.blue)
        
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: -90))
                .overlay(
                    Text(progress.progressString)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                        .opacity(showsText ? 1 : 0)
                )
        }
    }
}
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CircularProgressView(progress: .constant(0.0))
                .frame(width: 50, height: 50)
            CircularProgressView(progress: .constant(0.5))
                .frame(width: 50, height: 50)
            CircularProgressView(progress: .constant(0.1), showsText: true)
                .frame(width: 50, height: 50)
            CircularProgressView(progress: .constant(1.0), showsText: true)
                .frame(width: 50, height: 50)
        }
    }
}
