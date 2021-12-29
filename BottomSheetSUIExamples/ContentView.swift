//
//  ContentView.swift
//  BottomSheetSUIExamples
//
//  Created by Aitor Pagán on 1/12/21.
//

import SwiftUI
import BottomSheetSUI

struct ContentView: View {
    @State var detent: SheetDetent = .small
    var body: some View {
        VStack {
            Button {
                self.detent = .large
            } label: {
                Text("Large")
            }
            Button {
                self.detent = .medium
            } label: {
                Text("Medium")
            }
            Button {
                self.detent = .small
            } label: {
                Text("Small")
            }
        }

        BottomSheetView(detent: self.$detent) {
            Text("This is an example content")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
