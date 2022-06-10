//
//  HostRowView.swift
//  yahms
//

import SwiftUI

struct HostRowView: View {
    let viewModel: HostRowViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.icon.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: UIConstants.hostDeviceIconSize, height: UIConstants.hostDeviceIconSize)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .lineLimit(1)
                Text(viewModel.address)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

struct HostRowView_Previews: PreviewProvider {
    static var previews: some View {
        
        List {
            ForEach(Preview.HostPreviewData.allIcons()) { HostRowView(viewModel: $0) }
        }
    }
}
