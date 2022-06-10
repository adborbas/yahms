//
//  AddHostView.swift
//  yahms
//

import SwiftUI

struct AddHostView: View {
    enum Mode: Equatable {
        case add
        case edit(Host)
    }
    
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    private var mode: Mode {
        return presenter.mode
    }
    
    @ObservedObject private var viewModel: AddHostViewModel
    private let presenter: AddHostPresenter
    
    init(presenter: AddHostPresenter) {
        self.viewModel = presenter.viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("add_host_scheme_picker")
                        Spacer()
                        Picker("add_host_scheme_picker", selection: $viewModel.selectedScheme) {
                            ForEach(AddHostViewModel.URLScheme.allCases) { scheme in
                                Text(scheme.rawValue).tag(scheme)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 130)
                    }
                    DetailTextField("add_host_server", value: $viewModel.server)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    DetailTextField("add_host_port",
                                    placeholder: "\(viewModel.defaultPort)",
                                    value: $viewModel.rawPort)
                        .keyboardType(.numberPad)
                } header: {
                    Text("add_host_section_address")
                }
                
                Section {
                    Toggle(isOn: $viewModel.isAuthenticationEnabled) { Text("Authentication") }
                    if viewModel.isAuthenticationEnabled {
                        DetailTextField("add_host_username", value: $viewModel.username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        DetailTextField("add_host_password", value: $viewModel.password, isSecure: true)
                            .textContentType(.password)
                            .autocapitalization(.none)
                    }
                } header: {
                    Text("add_host_section_authentication")
                }
                
                Section {
                    DetailTextField("add_host_name",
                                    placeholder: viewModel.server,
                                    value: $viewModel.name)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Picker("add_host_icon", selection: $viewModel.icon) {
                        ForEach(Host.Icon.allCases, id: \.self) { icon in
                            Image(systemName: icon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIConstants.hostDeviceIconSize, height: UIConstants.hostDeviceIconSize)
                                .foregroundColor(viewModel.icon == icon ? .blue : .secondary)
                        }
                    }
                } header: {
                    Text("add_host_section_customisation")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar { toolBarContent }
        }
    }
    
    private var title: LocalizedStringKey {
        switch mode {
        case .add:
            return LocalizedStringKey("add_host_title")
        case .edit:
            return LocalizedStringKey("edit_host_title")
        }
    }
    
    @ToolbarContentBuilder
    private var toolBarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("cancel_button") {
                self.presentationMode.wrappedValue.dismiss()
            }.disabled(viewModel.isAddLoading)
        }
        ToolbarItem(placement: .primaryAction) {
            ZStack {
                Button {
                    if presenter.mode == .add {
                        presenter.addHost() { handleAddEditMessage($0) }
                    } else {
                        presenter.editHost() { handleAddEditMessage($0) }
                    }
                } label: {
                    if presenter.mode == .add {
                        Text("add_button")
                    } else {
                        Text("done_button")
                    }
                }
                .disabled(!viewModel.isAddValid)
                .opacity(viewModel.isAddLoading ? 0 : 1)
                .alert(alertMessage, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
                
                ProgressView()
                    .opacity(viewModel.isAddLoading ? 1 : 0)
            }
        }
    }
    
    private func handleAddEditMessage(_ message: String?) {
        guard let message = message else {
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        showingAlert = true
        alertMessage = message
    }
}

struct AddHostView_Previews: PreviewProvider {
    static var previews: some View {
        AddHostView(presenter: MainResolver.preview.resolveAddHostPresenter(mode: .add))
    }
}
