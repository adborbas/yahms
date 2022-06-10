//
//  DetailTextField.swift
//  yahms
//

import SwiftUI

struct DetailTextField: View {
    private let label: String
    private let placeholder: String
    private var value: Binding<String>
    private let isSecure: Bool
    
    init(_ label: String,
         placeholder: String = "",
         value: Binding<String>,
         isSecure: Bool = false) {
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.isSecure = isSecure
    }
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(label))
            if isSecure {
                SecureField(placeholder, text: value)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            }
            else {
                TextField(placeholder, text: value)
                    .multilineTextAlignment(.trailing)
                    .truncationMode(.head)
            }
            
        }
    }
}

struct DetailTextField_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DetailTextField("Name", value: Binding.mock(""))
        }
    }
}
