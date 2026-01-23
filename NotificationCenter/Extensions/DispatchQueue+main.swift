//
//  DispatchQueue+main.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 23.01.2026.
//

import Foundation

func runOnMain(_ block: @escaping ()->()) {
    DispatchQueue.main.async {
        block()
    }
}
