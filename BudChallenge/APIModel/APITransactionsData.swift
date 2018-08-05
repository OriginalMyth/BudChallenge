//
//  APITransactionsData.swift
//  BudChallenge
//
//  Created by Fong Bao on 01/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation


struct APIData: Codable {
    
    let transactionsData: [APITransactionsData]?
    
    enum CodingKeys: String, CodingKey {
        case transactionsData = "data"
    }
}


struct APITransactionsData: Codable {
    
    let amount: APITransactionsAmount
    let product: APITransactionsProduct
    let id: String
    let date: String
    let description: String
    let categoryId: Int
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case amount
        case product
        case date
        case id
        case description
        case categoryId = "category_id"
        case currency
    }
}

struct APITransactionsAmount: Codable {
    
    let value: Double
    let currencyIso: String
    
    enum CodingKeys: String, CodingKey {
        case value
        case currencyIso = "currency_iso"
    }
}

struct APITransactionsProduct: Codable {

    let id: Int
    let title: String
    let iconPath: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case iconPath = "icon"
    }
}



