//
//  AddTorrentView.swift
//  yahms
//

import SwiftUI
import UniformTypeIdentifiers

struct AddTorrentView: View {
    @Environment(\.presentationMode) var mode
    
    @ObservedObject private var model: AddTorrentViewModel
    @State private var isImporting: Bool = false
    
    private let presenter: AddTorrentPresenter
    
    init(presenter: AddTorrentPresenter) {
        self.model = presenter.viewModel
        self.presenter = presenter
        presenter.loadProperites()
    }
    
    var body: some View {
        NavigationView {
            List {
                torrentSelectorSection
                managementSection
                propertiesSection
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("add_torrent_title")
            .toolbar { toolBarContent }
            .fileImporter(isPresented: $isImporting,
                          allowedContentTypes: [UTType(filenameExtension: "torrent")!]) { result in
                switch result {
                case .success(let file):
                    model.torrentPath = file
                case .failure(let error):
                    print("Failed to import file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private var torrentSelectorSection: some View {
        Section(content: {
            torrentSelectorContent
        }, header: {
            Text("add_torrent_torrent_section_title")
        })
    }
    
    private var managementSection: some View {
        Section(content: {
            Toggle(isOn: $model.autoManagement) { Text("add_torrent_auto_management_toggle") }
            if model.autoManagement {
                Picker("add_torrent_category_picker", selection: $model.selectedCategory, content: {
                    ForEach(model.categories, id: \.self) { category in
                        Text(category.name).tag(category.name)
                    }
                })
                if !model.categorySavePath.isEmpty {
                    HStack {
                        locationText
                        Spacer()
                        Text(model.categorySavePath)
                            .foregroundColor(.secondary)
                            .truncationMode(.head)
                    }
                }
            }
            else {
                DetailTextField("add_torrent_text", value: $model.savePath)
            }
        }, header: {
            Text("add_torrent_management_section_title")
        })
    }
    
    private var locationText: Text {
        Text("add_torrent_text")
    }
    
    private var propertiesSection: some View {
        Section(content: {
            Toggle(isOn: $model.sequentialDownload) { Text("add_torrent_seq_download_toggle") }
            Toggle(isOn: $model.firstLastPiecePrio) { Text("add_torrent_first_last_prio_toggle") }
            Toggle(isOn: $model.startTorrent) { Text("add_torrent_start_torrent_toggle") }
        }, header: {
            Text("add_torrent_properties_section_title")
        })
    }
    
    private var torrentSelectorContent: some View {
        HStack {
            if model.torrentName.isEmpty {
                Button {
                    isImporting = true
                } label: {
                    Text("add_torrent_select_torrent_button")
                }
            }
            else {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .onTapGesture {
                        model.torrentPath = nil
                    }
                Text(model.torrentName)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolBarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("cancel_button") {
                self.mode.wrappedValue.dismiss()
            }.disabled(model.isAddLoading)
        }
        ToolbarItem(placement: .primaryAction) {
            ZStack {
                Button("add_button") {
                    presenter.addTorrent() { success in
                        if success {
                            self.mode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(!model.isAddValid)
                .opacity(model.isAddLoading ? 0 : 1)
                
                ProgressView()
                    .opacity(model.isAddLoading ? 1 : 0)
            }
        }
    }
}

struct AddTorrentView_Previews: PreviewProvider {
    static var previews: some View {
        AddTorrentView(presenter: MainResolver.preview.resolveAddTorrentPresenter())
    }
}
