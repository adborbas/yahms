//
//  TorrentContentView.swift
//  yahms
//

import SwiftUI

struct TorrentContentView: View {
    @ObservedObject private var viewModel: TorrentContentViewModel
    private let presenter: TorrentContentPresenter
    private let resolver: MainResolver
    
    @State var editMode: EditMode = .inactive
    @State var selectedPriority: TorrentContentPriority = .mixed
    
    init(presenter: TorrentContentPresenter) {
        self.viewModel = presenter.viewModel
        self.presenter = presenter
        self.resolver = MainResolver.shared
    }
    
    init(presenter: TorrentContentPresenter,
         viewModel: TorrentContentViewModel,
         resolver: MainResolver) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.resolver = resolver
    }
    
    var body: some View {
        List($viewModel.content, selection: $viewModel.selection) { torrentContent in
            if torrentContent.isDirectory.wrappedValue {
                NavigationLink(destination: rowForDirectory(named: torrentContent.name.wrappedValue)) {
                    TorrentContentRowView(viewModel: torrentContent)
                }
            } else {
                TorrentContentRowView(viewModel: torrentContent)
            }
        }
        .onAppear {
            presenter.viewAppear()
        }
        .onDisappear {
            presenter.viewDisappear()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar { toolBarContent }
        .environment(\.editMode, $editMode.animation(.default))
    }
    
    @ToolbarContentBuilder
    private var toolBarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(viewModel.parentDirectoryName)
                .font(.headline)
        }
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if isEditing {
                selectionToggleButton
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            if !isEditing {
                actionsMenu
            }
            else {
                doneButton
            }
        }
        ToolbarItem(placement: .bottomBar) {
            if isEditing {
                PriorityPickerView(selectedPriority: $selectedPriority)
                    .disabled(viewModel.selection.isEmpty)
                    .onChange(of: selectedPriority) { newValue in
                        guard newValue != .mixed else { return }
                        presenter.setPriority(newValue) { _ in
                            presenter.loadTorrentContent(isForced: true)
                        }
                        endEditing()
                    }
            }
        }
    }
    
    private var editPriorityButton: some View {
        Button {
            toggleEditMode()
        } label: {
            Text("Edit Priority")
        }
    }
    
    private var doneButton: some View {
        Button {
            endEditing()
        } label: {
            Text("Done")
        }
    }
    
    private var selectionToggleButton: some View {
        if viewModel.selection.count < viewModel.content.count {
            return Button {
                selectAll()
            } label: {
                Text("Select All")
            }
        }
        
        return Button {
            deselectAll()
        } label: {
            Text("Deselect All")
        }
    }
    
    private var sortByPicker: some View {
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
            Text("Sort By")
        }
    }
    
    private var actionsMenu: some View {
        return Menu {
            Section {
                editPriorityButton
            }
            
            Section {
                sortByPicker
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.accentColor)
        }
    }
    
    private var isEditing: Bool {
        return editMode == .active
    }
    
    private func endEditing() {
        toggleEditMode()
        deselectAll()
        selectedPriority = .mixed
    }
    
    private func selectAll() {
        viewModel.selectAll()
    }
    
    private func deselectAll() {
        viewModel.deselectAll()
    }
    
    private func toggleEditMode() {
        withAnimation {
            editMode.toggle()
        }
    }
    
    private func rowForDirectory(named: String) -> TorrentContentView {
        var mutatingDirectoryPath = presenter.contentDirectoryPath
        mutatingDirectoryPath.enqueue(named)
        let presenter = resolver.resolveTorrentContentPresenter(torrentHash: presenter.torrentHash,
                                                                          contentDirectoryPath: mutatingDirectoryPath)
        return TorrentContentView(presenter: presenter)
    }
}

struct TorrentContentView_Previews: PreviewProvider {
    static var previews: some View {
        let files = [
            TorrentContentRowViewModel(index: [0],
                                       name: "Very.long.name.Very.long.name.Very.long.name.Very.long.name.Very.long.name",
                                       isDirectory: true,
                                       size: 3391980674,
                                       progress: 0.7,
                                       priority: .skip),
            TorrentContentRowViewModel(index: [0],
                                       name: "Short name",
                                       isDirectory: true,
                                       size: 3391980674,
                                       progress: 0.7,
                                       priority: .mixed),
            TorrentContentRowViewModel(index: [0],
                                       name: "Other long name Other long name Other long name.mkv",
                                       isDirectory: false,
                                       size: 3391980674,
                                       progress: 0.7,
                                       priority: .maximum),
            TorrentContentRowViewModel(index: [0],
                                       name: "Short name",
                                       isDirectory: false,
                                       size: 3391980674,
                                       progress: 0.7,
                                       priority: .normal)
        ]
        
        let viewModel = TorrentContentViewModel(torrentHash: "",
                                                selectedSortCategory: TorrentSortProperties.ContentCategory.name.rawValue,
                                                selectedSortDirection: .descending)
        viewModel.content = files
        viewModel.parentDirectoryName = "Yolo"
        
        return NavigationView {
            TorrentContentView(presenter: MainResolver.preview.resolveTorrentContentPresenter(torrentHash: "",
                                                                                            contentDirectoryPath: TorrentDirectoryPath()),
                               viewModel: viewModel,
                               resolver: MainResolver.preview)
        }
        .preferredColorScheme(.dark)
    }
}

extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
