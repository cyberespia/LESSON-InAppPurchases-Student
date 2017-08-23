//
//  StorePurchaseController.swift
//  InAppSWIFT
//
//  Created by Taylor Mott on 02-Aug-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import Foundation
import StoreKit

let kInAppPurchasesFetchedNotification = Notification.Name("kInAppPurchasesFetchedNotification")
let kInAppPurchasesCompletedNotification = Notification.Name("kInAppPurchasesCompletedNotification")
let kInAppPurchasesRestoredNotification = Notification.Name("kInAppPurchasesRestoredNotification")

let kProductIdentifierKey = "productIdentifier"

class StorePurchaseController: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    enum StorePurchaseError: Error {
        case noProducts
        case unableToMakePurchases
        case invalidIndex
    }
    
    static let shared = StorePurchaseController()
    
    var products: [SKProduct] = []
    var productsRequest: SKProductsRequest?
    var productRequested: Bool = false
    
    
    // MARK: - Store Methods
    
    /**
     Your app calls this method to add the StorePurchaseController shared instance as a payment queue observer and start the products request
     */
    func loadStore() {
        SKPaymentQueue.default().add(self)
        requestProducts()
    }
    
    /**
     Starts to retrieve localized information about the list of products in ```Products.json``` from the Apple App Store.
     */
    func requestProducts() {
        if productsRequest == nil { //grab product IDS
            productsRequest = SKProductsRequest(productIdentifiers: Store.productIdentifiers)
            productsRequest?.delegate = self
        }
        
        if !productRequested {
            productsRequest?.start()
            productRequested = true
        }
    }
    
    
    
    // MARK: - User Actions
    
    /**
     Your application calls this method to restore transactions that were previously finished so that you can process them again.
     */
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /**
     Purchases producted at indicated index by adding product to payment queue
     
     - parameter index: index of desired product to purchase
     
     - throws: `StorePurchaseError.noProducts` if there are no products. `StorePurchaseError.unableToMakePurchases` if user is restricted from making purchases. `StorePurchaseError.invalidIndex` if an invalid index as been passed in
     */
    func purchaseOption(at index: Int) throws {
        if products.count == 0 {
            throw StorePurchaseError.noProducts
        } else if !SKPaymentQueue.canMakePayments() {
            throw StorePurchaseError.unableToMakePurchases
        } else if !products.indices.contains(index) {
            throw StorePurchaseError.invalidIndex
        } else {
            let payment = SKPayment(product: products[index])
            SKPaymentQueue.default().add(payment)
        }
    }
    
    
    
    // MARK: - SKProductRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productRequested = false
        
        products = response.products
        
        for validProduct in products {
            print("Found Product ID: \(validProduct.productIdentifier)")
        }
        
        for invalidProductID in response.invalidProductIdentifiers {
            print("Invaild Product ID: \(invalidProductID)")
        }
        
        NotificationCenter.default.post(name: kInAppPurchasesFetchedNotification, object: nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        NSLog("Payment Queue method called")
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                NSLog("payment purchasing")
            case .purchased:
                complete(transaction)
                NSLog("payment purchased")
            case .failed:
                failed(transaction)
                NSLog("payment failed")
            case .restored:
                restore(transaction)
                NSLog("payment restored")
            case .deferred:
                NSLog("payment defered")
            }
        }
    }
    
    
    
    
    
    // MARK: - Transaction Methods
    
    /**
     Notifies app that purchase succeeded and passes the product identifier.
     
     - parameter transaction: The transaction associated with the successful purchase
     */
    func complete(_ transaction: SKPaymentTransaction) {
        let productIdentifier =  transaction.payment.productIdentifier
        NotificationCenter.default.post(name: kInAppPurchasesCompletedNotification, object: self, userInfo: [kProductIdentifierKey : productIdentifier])
        finish(transaction)
    }
    
    /**
     This method removes the transaction from the payment queue and allows for custom error handling on failure
     
     - parameter transaction: The transaction associated with the successful purchase
     - parameter success: Indicates if the transaction was successful and the user has unlocked the purchased functionality. Default value of ```true```.
     */
    func finish(_ transaction: SKPaymentTransaction, success: Bool = true) {
        SKPaymentQueue.default().finishTransaction(transaction)
        
        if !success {
            /*...YOUR CODE HERE...*/
        }
    }
    
    /**
     Restores a previous transaction for non-consuable/subscriptions.
     
     - parameter transaction: The transaction associated with the item being restored
     */
    func restore(_ transaction: SKPaymentTransaction) {
        let productIdentifer: String
        if let originalProductIdentifier = transaction.original?.payment.productIdentifier {
            productIdentifer = originalProductIdentifier
        } else {
            productIdentifer = transaction.payment.productIdentifier
        }
        
        NotificationCenter.default.post(name: kInAppPurchasesRestoredNotification, object: self, userInfo: [kProductIdentifierKey : productIdentifer])
        finish(transaction)
    }
    
    /**
     Closes failed transaction and logs the error
     
     - parameter transaction: The failed transaction
     */
    func failed(_ transaction: SKPaymentTransaction) {
        
        if let transactionError = transaction.error as? NSError {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                NSLog("ERROR -- Failed Transaction: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
        
        finish(transaction, success: false)
    }
    
    
    
}
