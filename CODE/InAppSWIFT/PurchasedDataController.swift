//
//  PurchasedDataController.swift
//  InAppSWIFT
//
//  Created by Taylor Mott on 02-Aug-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import Foundation

let kPurchasedContentUpdated = Notification.Name("kPurchasedContentUpdated")

class PurchasedDataController {
    
    static let kPurchasedDataKey = "PurchasedDataKey"
    static let shared = PurchasedDataController()
    
    init() {
        loadFromDefaults()
        registerForNotifications()
    }
    
    //variable to mark if successfully purchased
    var adsRemoved: Bool = false
    
    //key constants for variables
    let kAdsRemovedKey = "AdsRemoved"
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(processPurchase(notification:)), name: kInAppPurchasesCompletedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPurchase(notification:)), name: kInAppPurchasesRestoredNotification, object: nil)
    }
    
    
    func loadFromDefaults() {
        if let dictionaryRepresentation = UserDefaults.standard.dictionary(forKey: PurchasedDataController.kPurchasedDataKey) as? [String : Bool] {
            self.adsRemoved = dictionaryRepresentation[kAdsRemovedKey] ?? false
        }
    }
    
    func storeInDefaults() {
        var dictionaryRepresentation = [String : Bool]()
        dictionaryRepresentation[kAdsRemovedKey] = adsRemoved
        
        UserDefaults.standard.set(dictionaryRepresentation, forKey: PurchasedDataController.kPurchasedDataKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Purchase Notifications
    
    @objc func processPurchase(notification: Notification) {
        guard let productIdentifier = notification.userInfo?[kProductIdentifierKey] as? String else { return }
        
        switch productIdentifier {
        case Store.adsRemovedID:
            adsRemoved = true
        default:
            break
        }
        
        storeInDefaults()
        NotificationCenter.default.post(name: kPurchasedContentUpdated, object: self)
    }
}
