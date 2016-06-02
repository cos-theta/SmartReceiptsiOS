//
//  EditReceiptViewController.swift
//  SmartReceipts
//
//  Created by Jaanus Siim on 02/06/16.
//  Copyright © 2016 Will Baumann. All rights reserved.
//

import Foundation

extension EditReceiptViewController: CurrencyExchangeServiceHandler {
    func triggerExchangeRateUpdate(cell: ExchangeRateCell, base: String, target: String) {
        Log.debug("Trigger update")
        
        let loading = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loading.startAnimating()
        loading.color = WBCustomization.themeColor()
        cell.accessoryView = loading
        
        exchangeRate(base, target: target, onDate: NSDate()) {
            status, rate in
            
            guard status == .Success else {
                return
            }
            
            onMainThread() {
                cell.accessoryView = nil
                
                cell.entryField.text = WBReceipt.exchangeRateFormatter().stringFromNumber(rate!)
            }
        }
    }
}