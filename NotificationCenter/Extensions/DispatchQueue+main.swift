//
//  DispatchQueue+main.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 23.01.2026.
//

import Foundation

extension DispatchQueue {
    static func runOnMain(_ block: @escaping ()->()) {
        DispatchQueue.main.async(execute: block)
    }
}
