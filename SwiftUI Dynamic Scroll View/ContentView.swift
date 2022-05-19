//
//  ContentView.swift
//  SwiftUI Dynamic Scroll View
//
//  Created by Vinnie Liu on 19/5/2022.
//

import SwiftUI

struct ContentView: View {
    
    let colors: [Color] = [.red, .green, .blue]
    
    var body: some View {
        DetectableScrollView {
            HStack {
                ForEach(0..<10) { i in
                    Text("Block \(i)")
                        .frame(width: 300, height: 300)
                        .background(colors[i % colors.count])
                        .id(i)
                }
            }
        } onScrollEnded: {
            print("scroll ended")
        }
    }
}
