//
//  ViewModelProtocol.swift
//  BudChallenge
//
//  Created by Fong Bao on 01/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation


protocol ViewModelProtocol {
    
    func fetchTransactions(completion: @escaping (ServiceResult) -> Void) 
    
}
