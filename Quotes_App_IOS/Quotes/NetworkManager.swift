//
//  NetworkManager.swift
//  Quotes
//
//  Created by Alon Rozmarin on 18/10/2023.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkManager")
    @Published var isConnected = true
    
    var connectionDescription: Bool {
        if isConnected {
            return true
        } else {
            return false
        }
    }
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }

        monitor.start(queue: queue)
    }
}
