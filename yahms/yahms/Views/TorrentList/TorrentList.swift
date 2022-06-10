//
//  TorrentList.swift
//  yahms
//

import SwiftUI
import qBittorrent

struct TorrentList: View {
    @ObservedObject private var viewModel: TorrentListViewModel
    private let presenter: TorrentsListPresenter
    private let resolver: MainResolver
    
    @State private var isShowingAddTorrentSheet = false
    @State var orientation = UIDevice.current.orientation
    @State var shouldDisplayAllDetails: Bool = false
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    init(presenter: TorrentsListPresenter) {
        self.viewModel = presenter.viewModel
        self.presenter = presenter
        self.resolver = MainResolver.shared
    }
    
    init(presenter: TorrentsListPresenter, viewModel: TorrentListViewModel, resolver: MainResolver) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.resolver = resolver
    }
    
    var body: some View {
        List(viewModel.torrents) { torrent in
            let presenter = resolver.resolveTorrentDetailPresenter(torrentInfo: torrent)
            NavigationLink(destination: TorrentDetailView(presenter: presenter)) {
                TorrentInfoRowView(viewModel: torrent,
                                   selectedSortCategory: $viewModel.selectedSortCategory,
                                   displayAllDetails: $shouldDisplayAllDetails)
            }
        }
        .overlay(
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        )
        .navigationBarTitle("torrent_list_title", displayMode: .inline)
        .sheet(isPresented: $isShowingAddTorrentSheet) {
        } content: {
            AddTorrentView(presenter: resolver.resolveAddTorrentPresenter())
        }
        .toolbar { toolBarContent }
        .onReceive(orientationChanged) { newOrientation in
            withAnimation {
                guard let newOrientation = (newOrientation.object as? UIDevice)?.orientation else { return }
                shouldDisplayAllDetails = newOrientation == .landscapeLeft || newOrientation == .landscapeRight
            }
        }
        .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        .onAppear {
            presenter.loadTorrents()
        }
    }
    
    @ToolbarContentBuilder
    private var toolBarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                isShowingAddTorrentSheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
            actionsMenu
        }
    }
    
    private var actionsMenu: some View {
        return Menu {
            Section {
                Picker(selection: $viewModel.selectedSortCategory) {
                    ForEach(viewModel.sortCategories) { category in
                        HStack{
                            Text(category.title)
                            Spacer()
                            if viewModel.selectedSortCategory == category.id {
                                Image(systemName: viewModel.selectedSortDirection.iconName)
                            }
                        }
                        .tag(category.id)
                    }
                } label: {
                    Text("sort_by_text")
                }
                
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.accentColor)
        }
    }
}

struct TorrentList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TorrentListViewModel(selectedSortCategory: "name",
                                             selectedSortDirection: .descending)
        viewModel.isLoading = false
        viewModel.torrents = Preview.TorrentListData.allState()
        let host = Host(id: "", name: "", url: URL(string: "http://blah.com:443")!, icon: .service, authentication: .bypassed)
        return TorrentList(presenter: MainResolver.preview.resolveTorrentsListPresenter(host: host), viewModel: viewModel, resolver: MainResolver.preview)
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
