//
//  ContentView.swift
//  catpredict
//
//  Created by me on 10/1/22.
//

import SwiftUI

struct ChoosePic: View {
    @State var show = false
    @State var have: [UIImage] = []
    let pp: prodpred = prodpred()
    @State var labels: [String] = []
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    show = true
                }
            }, label: {
                Image(systemName: "photo")
                    .padding()
            }).sheet(isPresented: $show) {
                PhotoPicker(pickerResult: $have, isPresented: $show)
                    .onDisappear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if !have.isEmpty {
                                labels = pp.predict(image: have[0])
                            }
                        }
                    }
            }
            if !have.isEmpty {
                Image(uiImage: have[0])
                    .resizable()
                    .scaledToFit()
            }
            
            if !labels.isEmpty {
                ForEach(labels, id: \.self) { l in
                    Text(l)
                }
            }
            
            Spacer()
        }
    }
}
