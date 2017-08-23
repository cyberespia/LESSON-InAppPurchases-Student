//
//  ViewController.swift
//  InAppSWIFT
//
//  Created by Taylor Mott on 02-Aug-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import UIKit

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adViewHeightContstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        StorePurchaseController.shared.loadStore()
        subscribeToPurchaseNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateAdContraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAdContraints() {
        let adsShown = !PurchasedDataController.shared.adsRemoved
        
        view.layoutIfNeeded()
        
        if adsShown {
            adViewHeightContstraint.constant = 44
        } else {
            adViewHeightContstraint.constant = 0
        }
        
        UIView.animate(withDuration: 2.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorePurchaseController.shared.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        let product = StorePurchaseController.shared.products[indexPath.row]
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = product.priceLocale
        
        cell.textLabel?.text = product.localizedTitle
        cell.detailTextLabel?.text = priceFormatter.string(from: product.price)
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        do {
            try StorePurchaseController.shared.purchaseOption(at: indexPath.row)
        } catch {
            print("\(error)")
        }
    }
    
    // MARK: - Purchase Notifications
    
    func subscribeToPurchaseNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(purchasedContentUpdated), name: kPurchasedContentUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productsFetched), name: kInAppPurchasesFetchedNotification, object: nil)
    }
    
    @objc func purchasedContentUpdated() {
        updateAdContraints()
    }
    
    @objc func productsFetched() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Restore
    
    @IBAction func restorePurchasesButtonTapped() {
        StorePurchaseController.shared.restorePurchases()
    }
}
