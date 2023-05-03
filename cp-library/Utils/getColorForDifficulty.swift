//
//  getColorForDifficulty.swift
//  cp-library
//
//  Created by OnjoujiToki on 4/18/23.
//

import SwiftUI

func getColorForDifficulty(_ difficulty: Int) -> Color {
    switch difficulty {
    case 0..<1200:
        return Color.gray
    case 1200..<1400:
        return Color.green
    case 1400..<1600:
        return Color.cyan
    case 1600..<1800:
        return Color.blue
    case 1800..<2000:
        return Color.purple
    case 2000..<2200:
        return Color.yellow
    case 2200..<2400:
        return Color.orange
    case 2400..<4000:
        return Color.red
    default:
        return Color.black
    }
}
