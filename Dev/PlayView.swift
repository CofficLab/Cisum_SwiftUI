//
//  PlayView.swift
//  Cisum
//
//  Created by Angel on 2024/4/14.
//

import SwiftUI

struct PlayView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onTapGesture {
                print("EEEE")
            }
        
        Button("OK", action: {
            print("OK")
        })
        
        Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
            print("Button")
        }
    }
}

#Preview {
    PlayView()
}
