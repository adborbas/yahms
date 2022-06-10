//
//  HostListView.swift
//  yahms
//

import SwiftUI

struct HostListView: View {
    @ObservedObject private var viewModel: HostListViewModel
    private let presenter: HostListPresenter
    private let resolver: MainResolver
    
    @State var editMode: EditMode = .inactive
    @State private var showingDeleteAlert = false
    @State private var isShowingAddHostSheet = false
    @State private var isShowingEditHostSheet = false
    
    init(presenter: HostListPresenter) {
        self.viewModel = presenter.viewModel
        self.presenter = presenter
        self.resolver = MainResolver.shared
    }
    
    init(presenter: HostListPresenter, viewModel: HostListViewModel, resolver: MainResolver) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.resolver = resolver
    }
    
    var body: some View {
        List(viewModel.hosts, selection: $viewModel.selection) { host in
            NavigationLink(destination: row(for: host), tag: host.id, selection: $viewModel.lastSelectedHostId) {
                HostRowView(viewModel: host)
            }
        }
        .overlay(
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        )
        .overlay(
            emptyView
                .opacity(viewModel.hosts.isEmpty ? 1 : 0)
        )
        .navigationBarTitle("host_list_title", displayMode: .large)
        .toolbar { toolBarContent }
        .environment(\.editMode, $editMode.animation(.default))
        .sheet(isPresented: $isShowingAddHostSheet) {
            AddHostView(presenter: resolver.resolveAddHostPresenter(mode: .add))
        }
        .sheet(isPresented: $isShowingEditHostSheet) {
            if let selectedHost = viewModel.selectedHost {
                AddHostView(presenter: resolver.resolveAddHostPresenter(mode: .edit(selectedHost)))
            }
        }
        .onChange(of: isShowingAddHostSheet) { newValue in
            if newValue == false {
                presenter.loadHosts()
            }
        }
        .onChange(of: isShowingEditHostSheet) { newValue in
            if newValue == false {
                endEditing()
                presenter.loadHosts()
            }
        }
        .onAppear {
            presenter.viewAppeared()
        }
    }
    
    @ToolbarContentBuilder
    private var toolBarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !viewModel.hosts.isEmpty {
                if editMode == .inactive {
                    Button {
                        isShowingAddHostSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        toggleEditMode()
                    } label: {
                        Text("edit_button")
                    }
                } else {
                    Button {
                        endEditing()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if editMode == .active && viewModel.selection != nil {
                Button {
                    isShowingEditHostSheet.toggle()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                Button {
                    showingDeleteAlert.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .actionSheet(isPresented: $showingDeleteAlert, content: {
                    ActionSheet(title: Text("Do you really want to delete \(viewModel.selectedHostName ?? "")?"),
                                message: Text("This won't have any effect on your qBittorrent client or your torrents."),
                                buttons: [
                                    .destructive(Text("Delete")) {
                                        presenter.deleteSelectedHost()
                                        endEditing()
                                    },
                                    .cancel()
                                ])
                })
            }
        }
    }
    
    private var emptyView: some View {
        VStack {
            Image(systemName: "menucard")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                .foregroundColor(.secondary)
            Text("There are no qBittorrent hosts 🙊 ")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("You can add one 👇")
                .foregroundColor(.secondary)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 64, trailing: 0))
            Button {
                isShowingAddHostSheet.toggle()
            } label: {
                Text("Add a host")
                    .frame(minWidth: 150)
                    .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
            }
        }
    }
    
    private func toggleEditMode() {
        withAnimation {
            editMode.toggle()
        }
    }
    
    private func endEditing() {
        toggleEditMode()
        viewModel.selection = nil
    }
    
    private func row(for host: HostRowViewModel) -> TorrentList {
        let presenter = resolver.resolveTorrentsListPresenter(host: host.host)
        return TorrentList(presenter: presenter)
    }
}

struct HostListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HostListViewModel()
        viewModel.hosts = Preview.HostPreviewData.allIcons()
        
        return Group {
            HostListView(presenter: MainResolver.preview.resolveHostListPresenter(), viewModel: viewModel, resolver: MainResolver.preview)
            
            HostListView(presenter: MainResolver.preview.resolveHostListPresenter(), viewModel: HostListViewModel(), resolver: MainResolver.preview)
        }
    }
}
