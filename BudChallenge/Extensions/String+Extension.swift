//
//  String+Extension.swift
//  ForecastChallenge
//
//  Created by Fong Bao on 01/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation


extension String {
    
    func urlEncode() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    func dateFromString() -> Date {
        let dateFormat = "yyyy-MM-dd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
    
}
