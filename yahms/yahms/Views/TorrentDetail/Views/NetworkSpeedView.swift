//
//  NetworkSpeedView.swift
//  yahms
//

import SwiftUI

struct NetworkSpeedView: View {
    enum Direction {
        case download
        case upload
        
        var imageName: String {
            switch self {
            case .download:
                return "arrow.down.circle.fill"
            case .upload:
                return "arrow.up.circle.fill"
            }
        }
    }
    
    @Binding var speed: Int64
    @State var direction: Direction = .download
    
    var body: some View {
        HStack {
            Image(systemName: direction.imageName)
            Text(speed.speedString)
        }
        .foregroundColor(.blue)
    }
}

struct NetworkSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            NetworkSpeedView(speed: .constant(1450000), direction: .download)
            NetworkSpeedView(speed: .constant(140000), direction: .upload)
        }
    }
}
