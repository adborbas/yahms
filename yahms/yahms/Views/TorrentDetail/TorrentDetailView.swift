//
//  TorrentDetailView.swift
//  yahms
//

import SwiftUI
import Combine

struct TorrentDetailView: View {
    // MARK: - Properties
    private let presenter: TorrentDetailPresenter
    private let resolver: MainResolver
    private let contentPresenter: TorrentContentPresenter
    
    @ObservedObject private var viewModel: TorrentDetailViewModel
    @State private var showingDeleteAlert = false
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common)
    @State private var connectedTimer: Cancellable?
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Init
    init(presenter: TorrentDetailPresenter) {
        self.init(presenter: presenter, viewModel: presenter.viewModel, resolver: MainResolver.shared)
    }
    
    init(presenter: TorrentDetailPresenter,
         viewModel: TorrentDetailViewModel,
         resolver: MainResolver) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.resolver = resolver
        
        let path = TorrentDirectoryPath(TorrentContentDirectory.rootDirectoryName)
        self.contentPresenter = resolver.resolveTorrentContentPresenter(torrentHash: viewModel.torrentHash,
                                                                            contentDirectoryPath: path)
    }
    
    // MARK: - Body
    var body: some View {
        List {
            header
            general
            content
            management
            connection
            actions
        }
        .navigationBarTitle("torrent_detail_title", displayMode: .inline)
        .onAppear() {
            instantiateTimer()
        }
        .onReceive(timer) { _ in
            presenter.reloadData()
        }
        .onDisappear {
            cancelTimer()
        }
        .refreshable {
            presenter.reloadData()
        }
    }
    
    private func instantiateTimer() {
        timer = Timer.publish(every: 2, on: .main, in: .common)
        connectedTimer = timer.connect()
    }
    
    private func cancelTimer() {
        connectedTimer?.cancel()
    }
    
    // MARK: - Sections
    private var header: some View {
        Section {
            VStack {
                HStack {
                    CircularProgressView(progress: $viewModel.progress, showsText: true)
                        .frame(width: 50, height: 50, alignment: .leading)
                        .padding(.trailing)
                    Text(viewModel.name)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    NetworkSpeedView(speed: $viewModel.downloadSpeed,
                                     direction: .download)
                    Spacer()
                    NetworkSpeedView(speed: $viewModel.uploadSpeed,
                                     direction: .upload)
                }
            }
            .padding(.top)
        }
    }
    
    private var content: some View {
        Section(header: Text("torrent_detail_section_content_title")) {
            NavigationLink("torrent_detail_content_navigation_link", destination: TorrentContentView(presenter: contentPresenter))
        }
    }
    
    private var general: some View {
        Section(header: Text("torrent_detail_section_general_title")) {
            DetailTextRow(title: "torrent_detail_state_title", detail: .localised(viewModel.state.localisedKey))
            DetailTextRow(title: "torrent_detail_size_title", detail: viewModel.size.sizeString)
            DetailTextRow(title: "torrent_detail_remaining", detail: viewModel.remaining.sizeString)
            DetailTextRow(title: "torrent_detail_eta", detail: "\(viewModel.eta.etaString)")
            DetailTextRow(title: "torrent_detail_date_added", detail: "\(viewModel.dateAdded.addedOnString)")
        }
    }
    
    private var management: some View {
        Section(header: Text("torrent_detail_section_management_title")) {
            DetailTextRow(title: "torrent_detail_category", detail: viewModel.category)
            DetailTextRow(title: "torrent_detail_location", detail: viewModel.location)
        }
    }
    
    private var connection: some View {
        Section(header: Text("torrent_detail_section_connection_title")) {
            DetailTextRow(title: "torrent_detail_seeds", detail: "\(viewModel.seeds) (\(viewModel.seedsTotal))")
            DetailTextRow(title: "torrent_detail_peers", detail: "\(viewModel.peers) (\(viewModel.peersTotal))")
            DetailTextRow(title: "torrent_detail_download_avg", detail: viewModel.downloadSpeedAvg.speedString)
            DetailTextRow(title: "torrent_detail_upload_avg", detail: viewModel.uploadSpeedAvg.speedString)
        }
    }
    
    private var actions: some View {
        Section(header: Text("torrent_detail_menu_actions")) {
            Button {
                showingDeleteAlert.toggle()
            } label: {
                HStack {
                    Text("delete_button")
                    Spacer()
                    Image(systemName: "trash.fill")
                }
                .foregroundColor(.red)
            }
            .actionSheet(isPresented: $showingDeleteAlert, content: {
                ActionSheet(title: Text("Do you really want to delete \(viewModel.name)?"),
                            buttons: [
                                .destructive(Text("Delete only torrent")) {
                                    deleteTorrent(deleteFiles: false)
                                },
                                .destructive(Text("Delete torrent and files")) {
                                    deleteTorrent(deleteFiles: true)
                                },
                                .cancel()
                            ])
            })
        }
    }
    
    // MARK: - Functions
    private func deleteTorrent(deleteFiles: Bool) {
        presenter.deleteTorrent(deleteFiles: deleteFiles) { success in
            if success {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct TorrentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let torrentInfo = Preview.TorrentInfoData.stalledUP
        let viewModel = TorrentDetailViewModel(torrentInfo: torrentInfo)
        viewModel.downloadSpeed = 14_567_000
        viewModel.uploadSpeed = 10
        
        viewModel.size = 32_000_000
        viewModel.eta = 600
        
        viewModel.location = "/Downloads/series/"
        
        viewModel.seeds = 10
        viewModel.seedsTotal = 109
        viewModel.peers = 7
        viewModel.peersTotal = 45
        
        viewModel.downloadSpeedAvg = 14_567_000
        viewModel.uploadSpeedAvg = 1800
        return NavigationView {
            TorrentDetailView(presenter: MainResolver.preview.resolveTorrentDetailPresenter(torrentInfo: torrentInfo),
                              viewModel: viewModel,
                              resolver: MainResolver.preview)
        }
    }
}
