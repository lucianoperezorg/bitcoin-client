//
//  Collection+Safe.swift
//  Domain
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
