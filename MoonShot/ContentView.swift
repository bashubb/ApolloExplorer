//
//  ContentView.swift
//  MoonShot
//
//  Created by HubertMac on 07/10/2023.
//

import SwiftUI

struct ContentView: View {
    let astronauts = Bundle.main.decode("astronauts.json")
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(astronauts.count)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
