//
//  ContentView.swift
//  BottomSheetSUIExamples
//
//  Created by Aitor Pagán on 1/12/21.
//

import SwiftUI
import BottomSheetSUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
        BottomSheetView {
            Text("This is an example content")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
