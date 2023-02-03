//
//  Constants.swift
//  Note
//
//  Created by Ян Нурков on 29.01.2023.
//

import Foundation
import UIKit

// MARK: - Colors

struct Colors {
    static let backgroundView = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.00)
    static let lightBlue = UIColor(red: 0.23, green: 0.40, blue: 0.58, alpha: 1.00)
    static let selectCell = UIColor(red: 0.82, green: 0.07, blue: 0.17, alpha: 1.00)
    static let boarderCell = UIColor(red: 0.54, green: 0.54, blue: 0.55, alpha: 1.00).cgColor
    static let navigationTint = UIColor(red: 0.11, green: 0.24, blue: 0.44, alpha: 1.00)
}

// MARK: - Metric

struct Metric {
    static let left = 16
    static let right = -16
    static let top = 16
    static let bottom = -16
    static let cellTop = 6
    static let cellBottom = -6
    static let flagWidthAndHeight = 20
}
