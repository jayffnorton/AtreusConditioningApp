//
//  SplashView.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 20/09/2025.
//

import SwiftUI

struct splash_view: View {
    private let imageName = "splashImage"

    var body: some View {
        ZStack {
            // Optional: background color
            Color.black
                .ignoresSafeArea()

            // Centered image
            Image("AtreusLogo1Inverted")
                .resizable()          // allow scaling
                .scaledToFit()        // maintain aspect ratio
                .frame(width: 200, height: 200) // adjust size
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        splash_view()
    }
}
