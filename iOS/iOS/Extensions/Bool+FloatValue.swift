//
//  Bool+FloatValue.swift
//  iOS
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

extension Bool {
    var floatValue: CGFloat {
        return self ? 1 : 0
    }
}
