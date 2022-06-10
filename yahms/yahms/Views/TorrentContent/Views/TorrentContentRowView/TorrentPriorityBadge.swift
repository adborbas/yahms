//
//  TorrentContentPriorityBadge.swift
//  yahms
//

import SwiftUI


struct TorrentContentPriorityBadge: View {
    @Binding var priority: TorrentContentPriority
    
    var body: some View {
        Text(priority.text)
            .font(.subheadline)
            .padding(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8))
            .background(Rectangle()
                            .fill(.gray)
                            .cornerRadius(10))
            .foregroundColor(.white)
    }
}

struct TorrentContentPriorityBadge_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TorrentContentPriorityBadge(priority: .constant(.skip))
            TorrentContentPriorityBadge(priority: .constant(.mixed))
            TorrentContentPriorityBadge(priority: .constant(.normal))
            TorrentContentPriorityBadge(priority: .constant(.high))
            TorrentContentPriorityBadge(priority: .constant(.maximum))
        }
    }
}
