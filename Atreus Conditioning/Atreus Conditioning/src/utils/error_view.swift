//
//  error_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 19/02/2026.
//

import Foundation
import SwiftUI

struct error_view: View {
    @State var errorMessage: String = "No Error"
    
    var body: some View {
        VStack {
            Section(header: Text("Error")) {
                Text(errorMessage)
                    .padding([.leading, .trailing], 10)
            }
        }
        .background(Color.red.opacity(0.3))
        .cornerRadius(12)
        .padding([.leading, .trailing], 5)
        
    }
}
