//
//  ProView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import SwiftUI

struct ProView: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
        
            VStack {
                Text("Pro subscription page.")
                    .foregroundColor(Color("TextColor"))
            }
        }
    }
}

#Preview {
    ProView()
}
