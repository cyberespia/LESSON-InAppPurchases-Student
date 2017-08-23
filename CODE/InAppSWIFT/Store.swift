//
//  Store.swift
//  InAppSWIFT
//
//  Created by Taylor Mott on 16-Aug-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import Foundation

struct Store {
    //Product IDs
    static let adsRemovedID = "com.devmtn.inapp_purchase_swift.removeAds"
    
    //All Products IDs
    static var productIdentifiers: Set<String> {
        return Set<String>([adsRemovedID])
    }
    
    /* * * * * * * *
     * If you wanted to load your products from a bundled json file.
     
     static var bundledProducts: Set<String> {
     
     guard let productsURL = Bundle.main.url(forResource: "Products", withExtension: "json") else {
     
     print("error finding file")
     return Set<String>() }
     
     do {
     let bundleProductsData = try Data(contentsOf: productsURL)
     
     guard let bundleProductsArray = try JSONSerialization.jsonObject(with: bundleProductsData, options: []) as? [String]  else { return Set<String>() }
     
     for string in bundleProductsArray {
     print("Bundled Products")
     print(string)
     }
     
     return Set<String>(bundleProductsArray)
     
     } catch {
     print("Unable to convert Products.json")
     return Set<String>()
     }
     }
     * * * * * * * */
}
