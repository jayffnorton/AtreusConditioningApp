//
//  orientation_info.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//

import SwiftUI

import Foundation
class OrientationInfo: ObservableObject {
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc func orientationChanged() {
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape {
            isLandscape = true
        } else if orientation.isPortrait {
            isLandscape = false
        }
    }
}
