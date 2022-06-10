//
//  ContentView.swift
//  yahms
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            HostListView(presenter: MainResolver.shared.resolveHostListPresenter())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
