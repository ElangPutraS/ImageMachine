//
//  Ext+Date.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import Foundation

extension Date {
    var yyyyMMdd: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let resultString = inputFormatter.string(from: self)
        return resultString
    }
}
