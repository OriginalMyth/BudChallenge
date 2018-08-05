//
//  DatabaseManager.swift
//  BudChallenge
//
//  Created by Fong Bao on 02/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation
import RealmSwift

class DatabaseManager: DatabaseManagerProtocol {
    
    
    static let sharedInstance = DatabaseManager()
    
    private init(){}
    
    func getRealm() -> Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            print("Failed to get default Realm")
            return nil
        }
    }
    
    func persist(transactions: [TransactionsData], update: Bool) {
        guard let realm = getRealm() else {
            return
        }
        do {
            try realm.write {
                realm.add(transactions, update: update)
            }
        } catch {
            print("Persist Realm Error")
        }
    }
    
    func update(categoryName: String, transactions: [TransactionsData]) {
        guard let realm = getRealm() else {
            return
        }
        do {
            try realm.write {
                for ids in transactions {
                    ids.category = categoryName
                }
            }
        } catch {
            print("Update Realm Error")
        }
    }
    
    func delete(transactions: [TransactionsData]) {
        guard let realm = getRealm() else {
            return
        }
        do {
            try realm.write {
        realm.delete(transactions)
            }
        } catch {
            print("Delete Realm Error")
        }
    }
    
    
    


    
    
    
    
}
