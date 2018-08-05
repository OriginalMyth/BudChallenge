//
//  TransactionsViewController.swift
//  BudChallenge
//
//  Created by Fong Bao on 01/08/2018.
//  Copyright © 2018 Duncan. All rights reserved.
//

import UIKit
import RealmSwift

class TransactionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var transactionId: String?
    
}

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var transactionsTable: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    
    @IBAction func editClicked(_ sender: UIBarButtonItem) {
        
        isEditingTransaction = !isEditingTransaction
        isEditingTransaction ? (editButton.title = "Done") : (editButton.title = "Edit")

        if !isEditingTransaction {
            if !cellsEditing.isEmpty {
                showPrimeAlert()
            }
        }
        
//        cellsEditing.first?.isSelected = false
    }
    
    private var cellsEditing = [TransactionsTableViewCell]()
    private var isEditingTransaction = false
    var databaseManager : DatabaseManagerProtocol?
    
    var viewModel: ViewModelProtocol?
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    let cellIdentifier = "transactionCell"
    
    private var transactions: Results<TransactionsData>?
    private var transactionsToken: NotificationToken?
    
    
    func clearSelected(cells: [TransactionsTableViewCell]) {
        for cell in cells {
            
            let alphaValue: CGFloat = 1
            cell.name.alpha = alphaValue
            cell.imageView?.alpha = alphaValue
            cell.priceLabel.alpha = alphaValue
            cell.productCategory.alpha = alphaValue
            cell.isSelected = false
            
            transactionsTable.reloadData()
            
        }
        cellsEditing.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = TransactionsViewModel()
        databaseManager = DatabaseManager.sharedInstance
        
       // let realm = try! Realm()

        transactions = databaseManager?.getRealm()?.objects(TransactionsData.self)
            .sorted(byKeyPath: TransactionsData.properties.date, ascending: false)


        

        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        editButton.tintColor = .white
        
        
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.color = UIColor(red: 0.23, green: 0.79, blue: 1.00, alpha: 1.00)
        
        //Get rid of empty rows
        transactionsTable.tableFooterView = UIView()
        transactionsTable.allowsMultipleSelection = true
 
        self.activityIndicator.startAnimating()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        transactionsToken = transactions!.observe { [weak self] _ in
            self?.transactionsTable.reloadData()
        }
        
        viewModel?.fetchTransactions(completion: { _ in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionsToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension TransactionsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = transactions?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TransactionsTableViewCell else {
            return UITableViewCell()
        }
        
        if let transDetail = transactions?[indexPath.row] {
        
        cell.name.text = transDetail.transactionDescription
        //cell.productCategory
        cell.transactionId = transDetail.id
        cell.productCategory.text = transDetail.category
            
            if let price = transDetail.amount?.value.value {
                
                cell.priceLabel.text = String(format: "\(transDetail.amount?.currencyCode?.symbol ?? "") %.2f", price)
                //cell.priceLabel.text = String(format: "%.2f", price)
                
                print("**** symbol \(transDetail.amount?.currencyCode?.symbol)")
                
            }
            
            cell.productImage.layer.borderWidth = 1
            cell.productImage.layer.masksToBounds = false
            cell.productImage.layer.borderColor = UIColor.lightGray.cgColor
            cell.productImage.layer.cornerRadius = cell.productImage.frame.height/2
            cell.productImage.clipsToBounds = true
            
            if transDetail.icon != nil {
                cell.productImage.image = transDetail.icon
            } else {
                
                transDetail.fetchIconImage(position: indexPath.row, completion: { iconImage in
                    if iconImage.imagePath == transDetail.product?.iconPath {
                        DispatchQueue.main.async {
                            cell.productImage.image = iconImage.image
                        }
                    }

                })
                    
            }
        
            //cell.productCategory.text = t.amount?.currencyCode?.symbol
           // print("**** cell.isEditing \(cell.name.text) ... \(cell.isEditing) .... \(cell.cellIsSelected)")
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: 0.93, green: 0.53, blue: 0.52, alpha: 1.00)//UIColor.red
            cell.selectedBackgroundView = backgroundView
            

            
        }
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TransactionsTableViewCell else {
            return
        }
        
        if isEditingTransaction {
            let alphaValue: CGFloat = 0.5
            cell.name.alpha = alphaValue
            cell.imageView?.alpha = alphaValue
            cell.priceLabel.alpha = alphaValue
            cell.productCategory.alpha = alphaValue
            cellsEditing.append(cell)
        } else {
            transactionsTable.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TransactionsTableViewCell else {
            return
        }
        
        let alphaValue: CGFloat = 1
        cell.name.alpha = alphaValue
        cell.imageView?.alpha = alphaValue
        cell.priceLabel.alpha = alphaValue
        cell.productCategory.alpha = alphaValue
        
        if let index = cellsEditing.index(of: cell) {
            cellsEditing.remove(at: index)
        }
        
        print("*** cellsEditing count \(cellsEditing.count)")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    
    func showPrimeAlert() {
        let alertController = UIAlertController(title: "Amend Transactions", message: nil, preferredStyle: .alert)
        let editButton = UIAlertAction(title: "Edit", style: .default, handler: { (action) -> Void in
            self.showEditAlert()
        })
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            
            //let realm = try! Realm()
            let transIds = self.cellsEditing.compactMap { //cellsSelected -> TransactionsData in
                self.databaseManager?.getRealm()?.object(ofType: TransactionsData.self, forPrimaryKey: $0.transactionId)
            }
            
//            try! realm.write {
//                realm.delete(transIds)
//            }
            
            self.databaseManager?.delete(transactions: transIds)
            
            self.clearSelected(cells: self.cellsEditing)
            
        })

        alertController.addAction(editButton)
        alertController.addAction(deleteButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showEditAlert() {

        let alertController = UIAlertController(title: "Category Edit", message: "Change selected rows category", preferredStyle: .alert)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            self.clearSelected(cells: self.cellsEditing)
        })

        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter new category name"
            
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let editTextField = alertController.textFields![0] as UITextField
            
           // let realm = try! Realm()
            let transIds = self.cellsEditing.compactMap { //cellsSelected -> TransactionsData in
                self.databaseManager?.getRealm()?.object(ofType: TransactionsData.self, forPrimaryKey: $0.transactionId)
            }
//            let realm = try! Realm()
//            try! realm.write {
//                for ids in transIds {
//                    ids.category = editTextField.text
//                }
//            }
            
            if let newText = editTextField.text {
                self.databaseManager?.update(categoryName: newText, transactions: transIds)
            }
             self.clearSelected(cells: self.cellsEditing)
            
        })

        alertController.addAction(saveAction)
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true, completion: nil)
    }
    



    
}
