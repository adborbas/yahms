//
//  TorrentContentRowView.swift
//  yahms
//

import SwiftUI

struct TorrentContentRowView: View {
    @Binding var viewModel: TorrentContentRowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                if viewModel.isDirectory {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                }
                Text(viewModel.name)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Text(viewModel.totalAndRemainingText)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
                TorrentContentPriorityBadge(priority: $viewModel.priority)
            }
        }
    }
}

struct TorrentContentRowView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            List {
                TorrentContentRowView(viewModel: .constant(TorrentContentRowViewModel(index: [0],
                                                                            name: "Very.long.name.Very.long.name.Very.long.name.Very.long.name.Very.long.name",
                                                                            isDirectory: false,
                                                                            size: 3391980674,
                                                                            progress: 0.7,
                                                                            priority: .skip)))
                TorrentContentRowView(viewModel: .constant(TorrentContentRowViewModel(index: [0],
                                                                            name: "Short name",
                                                                            isDirectory: true,
                                                                            size: 3391980674,
                                                                            progress: 0.7,
                                                                            priority: .mixed)))
                NavigationLink(destination: Text("")) {
                    TorrentContentRowView(viewModel: .constant(TorrentContentRowViewModel(index: [0],
                                                                                name: "Other long name Other long name Other long name.mkv",
                                                                                isDirectory: true,
                                                                                size: 3391980674,
                                                                                progress: 0.7,
                                                                                priority: .maximum)))
                }
                TorrentContentRowView(viewModel: .constant(TorrentContentRowViewModel(index: [0],
                                                                            name: "Short name",
                                                                            isDirectory: false,
                                                                            size: 3391980674,
                                                                            progress: 0.7,
                                                                            priority: .normal)))
            }
        }
    }
}

extension Binding {
    static func mock(_ value: Value) -> Self {
        var value = value
        return Binding(get: { value }, set: { value = $0 })
    }
}
