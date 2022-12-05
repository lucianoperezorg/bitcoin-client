//
//  Date+Yesterday.swift
//  DomainTests
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    
    private var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
   
    private var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
}
