//
//  ContentView.swift
//  styleflip
//
//  Created by me on 11/4/22.
//

import SwiftUI

var grid = GridItem(.flexible(), spacing: 1)

struct Styler: View {
    @State var p: prof = prof(bg: col(h: 0.9, s: 0.0, b: 1.0), txt: col(h: 0.9, s: 0.0, b: 0.0), inp: col(h: 0.9, s: 0.0, b: 1.0), shad: col(h: 0.9, s: 0.0, b: 0.0), corners: 10.0, size: 16.0, rads: 3.0, weight: "Light", des: "Monospaced")
    var body: some View {
        ZStack {
            Color(hue: p.bg.h, saturation: p.bg.s, brightness: p.bg.b).ignoresSafeArea()
            VStack {
                StyleHeader(p: $p)
                ChooseColor(title: "Background", profs: $p)
                ChooseColor(title: "Text", profs: $p)
                ChooseColor(title: "Input", profs: $p)
                ChooseColor(title: "Shadow", profs: $p)
                Spacer()
            }
        }
    }
}

struct StyleFont: View {
    @Binding var p: prof
    var body: some View {
        let txt = Color(hue: p.txt.h, saturation: p.txt.s, brightness: p.txt.b)
        let de = fontdesignmap[p.des]!
        let we = fontweightmap[p.weight]!
        Group {
            VStack(spacing: 10) {
                HStack {
                    Text("Font")
                        .font(.system(size: p.size-1, design: de))
                        .foregroundColor(txt)
                        .fontWeight(we)
                    Spacer()
                    Text("Monospaced")
                        .font(.system(size: p.size, design: .monospaced))
                        .foregroundColor(txt)
                        .fontWeight(we)
                        .onTapGesture {
                            withAnimation {
                                p.des = "Monospaced"
                            }
                        }
                    Text("Serif")
                        .font(.system(size: p.size, design: .serif))
                        .foregroundColor(txt)
                        .fontWeight(we)
                        .onTapGesture {
                            withAnimation {
                                p.des = "Serif"
                            }
                        }
                    Text("Rounded")
                        .font(.system(size: p.size, design: .default))
                        .foregroundColor(txt)
                        .fontWeight(we)
                        .onTapGesture {
                            withAnimation {
                                p.des = "Rounded"
                            }
                        }
                }
                HStack {
                    Text("Weight")
                        .font(.system(size: p.size-1, design: de))
                        .foregroundColor(txt)
                        .fontWeight(we)
                    Spacer()
                    HStack(spacing: 10) {
                        Text("Light")
                            .font(.system(size: p.size-2, design: de))
                            .foregroundColor(txt)
                            .fontWeight(.light)
                            .onTapGesture {
                                withAnimation {
                                    p.weight = "Light"
                                }
                            }
                        Text("Regular")
                            .font(.system(size: p.size-2, design: de))
                            .foregroundColor(txt)
                            .fontWeight(.regular)
                            .onTapGesture {
                                withAnimation {
                                    p.weight = "Medium"
                                }
                            }
                        Text("Bold")
                            .font(.system(size: p.size-2, design: de))
                            .foregroundColor(txt)
                            .fontWeight(.bold)
                            .onTapGesture {
                                withAnimation {
                                    p.weight = "Bold"
                                }
                            }
                    }
                }
                HStack {
                    Text("Size **\(Int(p.size))**")
                        .font(.system(size: p.size-1, design: de))
                        .foregroundColor(txt)
                        .fontWeight(we)
                    Slider(value: $p.size, in: 10...20, step: 1).accentColor(txt)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(hue: p.inp.h, saturation: p.inp.s, brightness: p.inp.b))
            .cornerRadius(p.corners)
            .shadow(color: Color(hue: p.shad.h, saturation: p.shad.s, brightness: p.shad.b), radius: p.rads, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

struct StyleHeader: View {
    @Binding var p: prof
    var body: some View {
        let txt = Color(hue: p.txt.h, saturation: p.txt.s, brightness: p.txt.b)
        VStack {
            StyleFont(p: $p)
            VStack (spacing: 0) {
                HStack {
                    Text("Corners")
                        .font(.system(size: p.size-1, design: fontdesignmap[p.des]!))
                        .foregroundColor(txt)
                        .fontWeight(fontweightmap[p.weight]!)
                    Slider(value: $p.corners, in: 0...25, step: 1).accentColor(txt)
                }
                HStack {
                    Text("Radius")
                        .font(.system(size: p.size-1, design: fontdesignmap[p.des]!))
                        .foregroundColor(txt)
                        .fontWeight(fontweightmap[p.weight]!)
                    Slider(value: $p.rads, in: 0.0...25.0, step: 1.0).accentColor(txt)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ChooseColor: View {
    var title: String
    @Binding var profs: prof
    @State var on = false
    @State var txterr = ""
    @State var inperr = ""
    @State var bgerr = ""
    @State var forcetxt = false
    // s = 0, b = 0, = black
    // s = 0, b = 1, = white
    // we don't match on hue and so don't use the equatable extension
    func equalbw(c1: col, c2: col) -> Bool {
        return c1.s == c2.s && c1.b == c2.b
    }
    func txtsel(cos: col) {
        if profs.bg == cos {
            withAnimation { txterr = "Cannot match Background" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    txterr = ""
                }
            }
            return
        }
        if profs.inp == cos {
            withAnimation { txterr = "Cannot match Input" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    txterr = ""
                }
            }
            return
        }
        if cos.iswhite() && profs.bg.iswhite() {
            withAnimation { profs.bg.b = 0.0 }
        }
        if cos.isblack() && profs.bg.isblack() {
            withAnimation { profs.bg.b = 1.0 }
        }
        withAnimation { profs.txt = cos }
    }
    func inpsel(cos: col) {
        if profs.txt == cos || (cos.iswhite() && profs.txt.iswhite()) || (cos.isblack() && profs.txt.isblack()) {
            inperr = "Cannot match Text"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation { inperr = "" }
            }
            return
        }
        withAnimation { profs.inp = cos }
    }
    func shadsel(cos: col) {
        withAnimation { profs.shad = cos }
    }
    func bgsel(cos: col) {
        if profs.txt == cos {
            bgerr = "Cannot match Text"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation { bgerr = "" }
            }
            return
        }
        if cos.iswhite() {
            if profs.txt.iswhite() {
                withAnimation { profs.txt.b = 0.0 }
            }
            if profs.shad.iswhite() {
                withAnimation { profs.shad.b = 0.0 }
            }
            if !profs.insame {
                if profs.inp.iswhite() {
                    withAnimation { profs.inp.b = 0.0 }
                }
            }
        }
        if cos.isblack() {
            if profs.txt.isblack() {
                withAnimation { profs.txt.b = 1.0 }
            }
            if profs.shad.isblack() {
                withAnimation { profs.shad.b = 1.0 }
            }
            if !profs.insame {
                if profs.inp.isblack() {
                    withAnimation { profs.inp.b = 1.0 }
                }
            }
        }
        if profs.insame {
            withAnimation { profs.inp = cos }
        }
        withAnimation { profs.bg = cos }
    }
    var body: some View {
        let fc = Color(hue: profs.txt.h, saturation: profs.txt.s, brightness: profs.txt.b)
        let de = fontdesignmap[profs.des]!
        let we = fontweightmap[profs.weight]!
        VStack {
            if on {
                Divider().padding(1)
            }
            HStack {
        HStack {
            Text(title)
                .font(.system(size: profs.size-1, design: de))
                .foregroundColor(fc)
                .fontWeight(on ? .bold : we)
                .onTapGesture{
                    withAnimation{ on.toggle() }
                }
            if title == "Text" && !txterr.isEmpty {
                    Text(txterr)
                        .font(.system(size: profs.size-6, design: de))
                        .foregroundColor(fc)
                        .fontWeight(we)
            }
            if title == "Background" && !bgerr.isEmpty {
                    Text(bgerr)
                        .font(.system(size: profs.size-6, design: de))
                        .foregroundColor(fc)
                        .fontWeight(we)
            }
            if title == "Input" && !on {
                if !inperr.isEmpty {
                    Text(inperr)
                        .font(.system(size: profs.size-5, design: de))
                        .foregroundColor(fc)
                        .fontWeight(we)
                }
            }
            Spacer()
            if on {
            HStack(spacing: 1) {
                ForEach(rainbow, id: \.self) { cos in
                    let co = Color(hue: cos.h, saturation: cos.s, brightness: cos.b)
                    co.scaledToFit()
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                        .onTapGesture {
                            if title == "Shadow" {
                                shadsel(cos: cos)
                            }
                            if title == "Input" {
                                inpsel(cos: cos)
                            }
                            if title == "Text" {
                                txtsel(cos: cos)
                            }
                            
                            if title == "Background" {
                                bgsel(cos: cos)
                            }
                        }
                    }
                }
            }
            Image(systemName: "chevron.right")
                .font(.system(size: profs.size))
                .foregroundColor(fc).rotationEffect(Angle(degrees: on ? 90 : 0))
                .padding(.horizontal)
                .onTapGesture{
                    withAnimation{ on.toggle() }
                }
        }
        }
            .padding(.horizontal)
            if !on {
        HStack{
            HStack(spacing: 1) {
                ForEach(rainbow, id: \.self) { cos in
                    let co = Color(hue: cos.h, saturation: cos.s, brightness: cos.b)
                    co.scaledToFit()
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                    .onTapGesture {
                            if title == "Shadow" {
                                shadsel(cos: cos)
                            }
                            if title == "Input" {
                                inpsel(cos: cos)
                            }
                            if title == "Text" {
                                txtsel(cos: cos)
                            }
                            if title == "Background" {
                                bgsel(cos: cos)
                            }
                        }
                    }
                }
            }
            }
            if on {
                VStack(spacing: 0) {
                    HStack {
                        Text("Hue")
                            .font(.system(size: profs.size-1, design: de))
                            .foregroundColor(fc)
                            .fontWeight(we)
                        Slider(value: title == "Background" ? $profs.bg.h : (title == "Input" ? $profs.inp.h : (title == "Text" ? $profs.txt.h : $profs.shad.h)), in: 0...1, step: 0.01).accentColor(fc).onChange(of: title == "Background" ? profs.bg.h : (title == "Input" ? profs.inp.h : (title == "Text" ? profs.txt.h : profs.shad.h))) { hu in
                            if title == "Shadow" {
                                profs.shad.h = hu
                            }
                            if title == "Input" {
                                profs.inp.h = hu
                            }
                            if title == "Text" {
                                profs.txt.h = hu
                            }
                            if title == "Background" {
                                profs.bg.h = hu
                            }
                        }
                    }
                    HStack {
                        Text("Saturation")
                            .font(.system(size: profs.size-1, design: de))
                            .foregroundColor(fc)
                            .fontWeight(we)
                        Slider(value: title == "Background" ? $profs.bg.s : (title == "Input" ? $profs.inp.s : (title == "Text" ? $profs.txt.s : $profs.shad.s)), in: 0...1, step: 0.01).accentColor(fc).onChange(of: title == "Background" ? profs.bg.s : (title == "Input" ? profs.inp.s : (title == "Text" ? profs.txt.s : profs.shad.s))) { hu in
                            if title == "Shadow" {
                                profs.shad.s = hu
                            }
                            if title == "Input" {
                                profs.inp.s = hu
                                if profs.inp.iswhite() {
                                    if profs.txt.iswhite() {
                                        withAnimation { profs.txt.b = 0.0 }
                                    }
                                }
                                if profs.inp.isblack() {
                                    if profs.txt.isblack() {
                                        withAnimation { profs.txt.b = 1.0 }
                                    }
                                }
                            }
                            if title == "Text" {
                                profs.txt.s = hu
                                if profs.txt.iswhite() {
                                    if profs.bg.iswhite() {
                                        withAnimation { profs.bg.b = 0.0 }
                                    }
                                }
                                if profs.txt.isblack() {
                                    if profs.bg.isblack() {
                                        withAnimation { profs.bg.b = 1.0 }
                                    }
                                }
                            }
                            if title == "Background" {
                                profs.bg.s = hu
                                if profs.bg.iswhite() {
                                    if profs.txt.iswhite() {
                                        withAnimation { profs.txt.b = 0.0 }
                                    }
                                }
                                if profs.bg.isblack() {
                                    if profs.txt.isblack() {
                                        withAnimation { profs.txt.b = 1.0 }
                                    }
                                }
                            }
                        }
                    }
                    HStack {
                        Text("Brightness")
                            .font(.system(size: profs.size-1, design: de))
                            .foregroundColor(fc)
                            .fontWeight(we)
                        Slider(value: title == "Background" ? $profs.bg.b : (title == "Input" ? $profs.inp.b : (title == "Text" ? $profs.txt.b : $profs.shad.b)), in: 0...1, step: 0.01).accentColor(fc).onChange(of: title == "Background" ? profs.bg.b : (title == "Input" ? profs.inp.b : (title == "Text" ? profs.txt.b : profs.shad.b))) { hu in
                            if title == "Shadow" {
                                profs.shad.b = hu
                            }
                            if title == "Input" {
                                profs.inp.b = hu
                                if profs.inp.iswhite() {
                                    if profs.txt.iswhite() {
                                        withAnimation { profs.txt.b = 0.0 }
                                        if profs.bg.isblack() {
                                            withAnimation { profs.bg.b = 1.0 }
                                        }
                                    }
                                }
                                if profs.inp.isblack() {
                                    if profs.txt.isblack() {
                                        withAnimation { profs.txt.b = 1.0 }
                                        if profs.bg.iswhite() {
                                            withAnimation { profs.bg.b = 0.0 }
                                        }
                                    }
                                }
                            }
                            if title == "Text" {
                                profs.txt.b = hu
                                if profs.txt.iswhite() {
                                    if profs.bg.iswhite() {
                                        withAnimation { profs.bg.b = 0.0 }
                                    }
                                    if profs.inp.iswhite() {
                                        withAnimation { profs.inp.b = 0.0 }
                                    }
                                }
                                if profs.txt.isblack() {
                                    if profs.bg.isblack() {
                                        withAnimation { profs.bg.b = 1.0 }
                                    }
                                    if profs.inp.isblack() {
                                        withAnimation { profs.inp.b = 1.0 }
                                    }
                                }
                            }
                            if title == "Background" {
                                profs.bg.b = hu
                                if profs.bg.iswhite() {
                                    if profs.txt.iswhite() {
                                        withAnimation { profs.txt.b = 0.0 }
                                        if profs.inp.isblack() {
                                            withAnimation { profs.inp.b = 1.0 }
                                        }
                                    }
                                }
                                if profs.bg.isblack() {
                                    if profs.txt.isblack() {
                                        withAnimation { profs.txt.b = 1.0 }
                                        if profs.inp.iswhite() {
                                            withAnimation { profs.inp.b = 0.0 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct Styler_Previews: PreviewProvider {
    static var previews: some View {
        Styler()
    }
}
