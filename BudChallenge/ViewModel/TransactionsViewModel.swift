//
//  TransactionsViewModel.swift
//  BudChallenge
//
//  Created by Fong Bao on 01/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionsViewModel: ViewModelProtocol {
    
    let serviceManager: ServiceManagerProtocol
    let databaseManager : DatabaseManagerProtocol?
    
    init() {
        serviceManager = ServiceManager()
        databaseManager = DatabaseManager.sharedInstance
    }
    
    func fetchTransactions(completion: @escaping (ServiceResult) -> Void) {
        
        serviceManager.fetchTransactions(urlString: Constants.mockyUrlString, completion: { data, result in
            
            //print("*** data is... \(data)")
            
            
            guard let data = data, let transactionsData = data.transactionsData else {
                return
            }
            
            let realm = self.databaseManager?.getRealm()

            let transIds = transactionsData.compactMap { //cellsSelected -> TransactionsData in
                realm?.object(ofType: TransactionsData.self, forPrimaryKey: $0.id)
                }
            
            print("*** transIds ... \(transIds)")
            
            let filteredTransactions = transactionsData.filter {

                var isMatch = true
                for ids in transIds {
                    if $0.id == ids.id {
                        isMatch = false
                    }
                }
                return isMatch
            }
            
            print("*** filteredTransactions ... \(filteredTransactions)")

            DispatchQueue.global(qos: .background).async {
               // let fetchedTransactions = transactionsData.map { transaction -> TransactionsData in
                    let fetchedTransactions = filteredTransactions.map { transaction -> TransactionsData in
                    
                    let transData = TransactionsData(id: transaction.id, date: transaction.date, categoryId: transaction.categoryId)
                    
                    transData.amount = TransactionsAmount(value: transaction.amount.value, currencyIso: transaction.amount.currencyIso)
                    transData.product = TransactionsProduct(id: transaction.product.id, title: transaction.product.title, iconPath: transaction.product.iconPath)
                    transData.currency = transaction.currency
                    transData.transactionDate = transaction.date.dateFromString()
                    transData.transactionDescription = transaction.description

                    return transData
                    
                }
                //print("**** fetchedTransactions... \(fetchedTransactions) ")
                print("**** fetchedTransactions count... \(fetchedTransactions.count) ")
                
                //let realm = try! Realm()
//                try! realm.write {
//                    realm.add(fetchedTransactions, update: true)
//                }
                
                
                self.databaseManager?.persist(transactions: fetchedTransactions, update: true)
                
            }

            completion(result)
            
            
        })
        
    }
    
}
