//
//  DatabaseManagerProtocol.swift
//  BudChallenge
//
//  Created by Fong Bao on 05/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation
import RealmSwift

protocol DatabaseManagerProtocol {
    
    func getRealm() -> Realm?
    func persist(transactions: [TransactionsData], update: Bool)
    func delete(transactions: [TransactionsData])
    func update(categoryName: String, transactions: [TransactionsData]) 

}
