//
//  TransactionModel.swift
//  BudChallenge
//
//  Created by Fong Bao on 02/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import Foundation
import RealmSwift

enum CurrenyCode: Int {
    
    case GBP = 0
    case USD
    
    var code: String {
        switch self {
        case.GBP:
            return "GBP"
        case .USD:
            return "USD"
        }
    }
    
    var symbol: String {
        switch self {
        case.GBP:
            return "£"
        case .USD:
            return "$"
        }
    }
    
    static let count: Int = {
        var max: Int = 0
        while let _ = CurrenyCode(rawValue: max) { max += 1 }
        return max
    }()
    
}

@objcMembers class TransactionsData: Object {
    
    dynamic var amount: TransactionsAmount?
    dynamic var product: TransactionsProduct?
    dynamic var id: String?
    dynamic var dateString: String?
    dynamic var transactionDate: Date?
    dynamic var transactionDescription: String?
    dynamic var category: String?
    dynamic var currency: String?
    
    dynamic var icon: UIImage?
    
    convenience init(id: String, date: String, categoryId: Int) {
        self.init()
        self.id = id
        self.dateString = date
        
        var categoryDescription = ""
        
        switch categoryId {
        case 0:
            categoryDescription = "General"
        case 1:
            categoryDescription = "Bills"
        case 6:
            categoryDescription = "Food/Drink"
        case 7:
            categoryDescription = "Groceries"
        default:
            categoryDescription = "General"
        }
        
        self.category = categoryDescription

    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["icon"]
    }

    func fetchIconImage(position: Int, completion: @escaping (IconImage) -> Void) {
        if let iconPath = product?.iconPath {
            ServiceManager.fetchImageFor(icon: iconPath, completion: { [weak self] iconImage in
                if let iconImage = iconImage {
                    self?.icon = iconImage.image
                    completion(iconImage)
                } else {
                    completion(IconImage(image: UIImage(named: "") ?? UIImage(), imagePath: iconPath))
                }
            })
        } else {
            completion(IconImage(image: UIImage(), imagePath: ""))
        }
    }
}

extension TransactionsData {
    public struct properties {
        static let id = "id"
        static let date = "transactionDate"
    }
}

@objcMembers class TransactionsAmount: Object {
    
    dynamic var value = RealmOptional<Double>()
    dynamic var currencyIso: String?

    var currencyCode: CurrenyCode? {
        get {
            for cCode in 0...CurrenyCode.count {
                let currency = CurrenyCode(rawValue: cCode)
                if let code = currency?.code {
                    if (currencyIso?.caseInsensitiveCompare(code) == ComparisonResult.orderedSame) {
                        return currency
                    }
                }
            }
            return nil
        }
    }
    
    convenience init(value: Double, currencyIso: String) {
        self.init()
        self.value.value = value
        self.currencyIso = currencyIso
    }
    
}

@objcMembers class TransactionsProduct: Object {
    
    dynamic var id = RealmOptional<Int>()
    dynamic var title: String?
    dynamic var iconPath: String?
    
    
    convenience init(id: Int, title: String, iconPath: String) {
        self.init()
        self.id.value = id
        self.title = title
        self.iconPath = iconPath
    }
    

    
}

