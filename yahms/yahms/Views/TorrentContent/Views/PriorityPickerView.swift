//
//  PriorityPickerView.swift
//  yahms
//

import SwiftUI

struct PriorityPickerView: View {
    @Binding var selectedPriority: TorrentContentPriority
    
    var body: some View {
        Picker("Priority", selection: $selectedPriority) {
            Text(TorrentContentPriority.skip.text).tag(TorrentContentPriority.skip)
            Text(TorrentContentPriority.normal.text).tag(TorrentContentPriority.normal)
            Text(TorrentContentPriority.high.text).tag(TorrentContentPriority.high)
            Text(TorrentContentPriority.maximum.text).tag(TorrentContentPriority.maximum)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct PriorityPickerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedPriority: TorrentContentPriority = .mixed
        
        return VStack {
            PriorityPickerView(selectedPriority: $selectedPriority)
        }
    }
}
