//
//  model-utils.swift
//  styleflip
//
//  Created by me on 11/4/22.
//

import SwiftUI

struct col: Hashable {
    var h: Double
    var s: Double
    var b: Double
}

// Need a maps for custom font choice, if we persist profiles to db we need to convert from string to swift type. "Light" -> .light.
var fontdesignmap = ["Serif": Font.Design.serif,
                     "Monospaced": Font.Design.monospaced,
                     "Rounded": Font.Design.rounded]

var fontweightmap = ["Light": Font.Weight.light,
                     "Medium": Font.Weight.regular,
                     "Bold": Font.Weight.bold]

struct prof: Hashable {
    var bg: col
    var txt: col
    var inp: col
    var shad: col
    var corners: Double
    var size: Double
    var rads: Double
    var weight: String
    var des: String
    var insame: Bool = true
}

var rainbow: [col] = [
    col(h: 0.0, s: 0.87, b: 0.73),
    col(h: 0.04, s: 0.92, b: 0.78),
    col(h: 0.11, s: 0.91, b: 0.97),
    col(h: 0.3, s: 0.79, b: 0.72),
    col(h: 0.39, s: 0.87, b: 0.48),
    col(h: 0.61, s: 0.86, b: 0.65),
    col(h: 0.77, s: 0.58, b: 0.57),
    col(h: 0.91, s: 0.64, b: 0.72),
    col(h: 0.9, s: 0.0, b: 1.0),
    col(h: 0.5, s: 0.1, b: 0.4),
    col(h: 0.9, s: 0.0, b: 0.0)
]

extension col: Equatable {
    static func == (lhs: col, rhs: col) -> Bool {
        return
            lhs.h == rhs.h &&
            lhs.s == rhs.s &&
            lhs.b == rhs.b
    }
    func isblack() -> Bool {
        return self.b == 0.0
    }
    func iswhite() -> Bool {
        return self.b == 1.0 && self.s == 0.0
    }
}

extension prof: Equatable {
    static func == (lhs: prof, rhs: prof) -> Bool {
        return
            lhs.bg == rhs.bg &&
            lhs.txt == rhs.txt &&
            lhs.inp == rhs.inp &&
            lhs.shad == rhs.shad &&
            lhs.corners == rhs.corners &&
            lhs.size == rhs.size &&
            lhs.rads == rhs.rads &&
            lhs.weight == rhs.weight &&
            lhs.des == rhs.des
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
