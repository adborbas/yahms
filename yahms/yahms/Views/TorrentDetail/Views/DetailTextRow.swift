//
//  DetailTextRow.swift
//  yahms
//

import SwiftUI
import Alamofire

struct DetailTextRow: View {
    enum DetailText {
        case localised(String)
        case raw(String)
    }

    var title = ""
    var detail: DetailText = .raw("")
    
    
    init(title: String, detail: DetailText) {
        self.title = title
        self.detail = detail
    }
    
    init(title: String, detail: String) {
        self.init(title: title, detail: .raw(detail))
    }

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
            Spacer()
            detailText
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    private var detailText: Text {
        switch detail {
        case .localised(let key):
            return Text(LocalizedStringKey(key))
        case .raw(let string):
            return Text(string)
        }
    }
}

struct DetailTextRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DetailTextRow(title: "Title", detail: .raw("Detail"))
            DetailTextRow(title: "Title", detail: .raw("Very long text"))
            DetailTextRow(title: "Title", detail: .raw("Very long text Very long text Very long text Very long text"))
        }
    }
}
