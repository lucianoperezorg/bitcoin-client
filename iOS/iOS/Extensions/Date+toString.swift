//
//  Date+toString.swift
//  iOS
//
//  Created by Luciano Perez on 04/12/2022.
//

import Foundation

extension Date {
    func toString(dateFormat: String = "dd-MM-YYYY") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
