//
//  ValidationResult.swift
//  GitHubSignup-Example
//
//  Created by 佐藤賢 on 2018/09/25.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//

import RxCocoa

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

// CustomStringConvertibleプロトコルはstructとかenum、classの文字列の出力の形をカスタマイズしたいときに指定します。
extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message: message):
            return message
        case .empty:
            return ""
        case .validating:
            return "Validating ..."
        case let .failed(message: message):
            return message
        }
    }
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.failedColor
        }
    }
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let failedColor = UIColor.red
}

