//
//  TorrentInfoRowView.swift
//  yahms
//

import SwiftUI

struct TorrentInfoRowView: View {
    let viewModel: TorrentInfoRowViewModel
    @Binding var selectedSortCategory: TorrentSortProperties.InfoCategory.ID
    @Binding var displayAllDetails: Bool
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.iconName)
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(viewModel.iconColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.name)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    if displayAllDetails {
                        NetworkSpeedView2(speed: viewModel.downloadSpeed, direction: .download)
                        NetworkSpeedView2(speed: viewModel.uploadSpeed, direction: .upload)
                        separator
                    }
                    Text(viewModel.size.sizeString)
                    separator
                    Text(viewModel.progress.progressString)
                    separator
                    Text(viewModel.eta.etaString)
                    if displayAllDetails {
                        separator
                        Text(viewModel.dateAdded.addedOnString)
                    }
                    Spacer()
                }
                .lineLimit(1)
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private var separator: some View {
        return Text("·")
    }
}

struct TorrentInfoRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(Preview.TorrentInfoData.allState()) { viewModel in
                TorrentInfoRowView(viewModel: viewModel,
                                   selectedSortCategory: Binding.mock("name"),
                                   displayAllDetails: Binding.mock(Bool.random()))
            }
        }
    }
}

struct NetworkSpeedView2: View {
    enum Direction {
        case download
        case upload
        
        var imageName: String {
            switch self {
            case .download:
                return "arrow.down"
            case .upload:
                return "arrow.up"
            }
        }
    }
    
    @State var speed: Int64 = 0
    @State var direction: Direction = .download
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: direction.imageName)
            Text(speed.speedString)
        }
    }
}
