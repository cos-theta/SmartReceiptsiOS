//
//  WBReceipt.swift
//  SmartReceipts
//
//  Created by Jaanus Siim on 29/05/16.
//  Copyright © 2016 Will Baumann. All rights reserved.
//

import Foundation

private let JustDecimalFormatterKey = "JustDecimalFormatterKey"

extension WBReceipt {
    @objc func targetPrice() -> Price {
        if canExchange(), let exchanged = exchangedPrice() {
            return exchanged
        }
        
        return price()
    }
    
    @objc func targetTax() -> Price? {
        if canExchange(), let exchanged = exchangedTax() {
            return exchanged
        }
        
        return tax()
    }
    
    var attachemntType: ReceiptAttachmentType {
        get {
            if hasPDF() {
                return .pdf
            } else if hasImage() {
                return .image
            } else {
                return .none
            }
        }
    }
}

@objc
extension WBReceipt: Priced {
    
    func price() -> Price {
        return Price(amount: priceAmount, currency: currency)
    }
    
    func priceAsString() -> String {
        return price().amountAsString()
    }
    
    func formattedPrice() -> String {
        return price().currencyFormattedPrice()
    }
}

@objc
extension WBReceipt: Exchanged {
    func exchangeRateAsString() -> String {
        if !canExchange() {
            return WBReceipt.exchangeRateFormatter().string(from: 1)!
        }
        
        guard let number = exchangeRate, number.compare(NSDecimalNumber.zero) == .orderedDescending else {
            return LocalizedString("undefined")
        }
        
        return WBReceipt.exchangeRateFormatter().string(from: number)!
    }
    
    var targetCurrency: Currency {
        return trip.defaultCurrency
    }
    
    class func exchangeRateFormatter() -> NumberFormatter {
        if let formatter = Thread.cachedObject(NumberFormatter.self, key: JustDecimalFormatterKey) {
            return formatter
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = SmartReceiptExchangeRateDecimalPlaces
        formatter.minimumIntegerDigits = 1
        Thread.cacheObject(formatter, key: JustDecimalFormatterKey)
        return formatter
    }
    
    fileprivate func canExchange() -> Bool {
        return targetCurrency != currency
    }
}

@objc
extension WBReceipt: ExchangedPriced {
    func exchangedPrice() -> Price? {
        if !canExchange() {
            return price()
        }
        
        guard let rate = exchangeRate, rate.isPositiveAmount() else {
            return nil
        }
        
        let exchangedValue = priceAmount.multiplying(by: rate)
        
        return Price(amount: exchangedValue, currency: targetCurrency)
    }
    
    func exchangedPriceAsString() -> String {
        guard let exchanged = exchangedPrice() else {
            return LocalizedString("undefined")
        }
        
        return exchanged.amountAsString()
    }
    
    func formattedExchangedPrice() -> String {
        guard let exchanged = exchangedPrice() else {
            return LocalizedString("undefined")
        }
        
        return exchanged.currencyFormattedPrice()
    }
}

@objc
extension WBReceipt: Taxed {
    func tax() -> Price? {
        return Price(amount: taxAmount ?? 0, currency: currency)
    }
    
    func taxAsString() -> String {
        guard let taxValue = tax() else {
            return ""
        }
        
        return taxValue.amountAsString()
    }
    
    func formattedTax() -> String {
        guard let taxValue = tax() else {
            return ""
        }
        
        return taxValue.currencyFormattedPrice()
    }
}

@objc
extension WBReceipt: ExchangedTaxed {
    func exchangedTax() -> Price? {
        if !canExchange() {
            return tax()
        }

        guard let rate = exchangeRate, let tax = taxAmount, rate.isPositiveAmount() else {
            return nil
        }
        
        let exchangedTax = tax.multiplying(by: rate)
        
        return Price(amount: exchangedTax, currency: targetCurrency)
    }
    
    func exchangedTaxAsString() -> String {
        guard let tax = exchangedTax() else {
            return LocalizedString("undefined")
        }
        
        return tax.amountAsString()
    }
    
    func formattedExchangedTax() -> String {
        guard let tax = exchangedTax() else {
            return ""
        }
        
        return tax.currencyFormattedPrice()
    }
}

// MARK: - totals
@objc
extension WBReceipt {
    func netPrice() -> Price {
        let receiptPrice = price()
        let priceAmount = receiptPrice.amount!
        let taxAmount: NSDecimalNumber
        if WBPreferences.enteredPricePreTax() {
            taxAmount = tax()?.amount ?? .zero
        } else {
            taxAmount = .zero
        }
        
        let totalAmount = priceAmount.adding(taxAmount)
        return Price(amount: totalAmount, currency: receiptPrice.currency)
    }
    
    func netPriceAsString() -> String {
        return netPrice().amountAsString()
    }
    
    func formattedNetPrice() -> String {
        return netPrice().currencyFormattedPrice()
    }

    func exchangedNetPrice() -> Price? {
        if !canExchange() {
            return netPrice()
        }
        
        guard let rate = exchangeRate, rate.isPositiveAmount() else {
            return nil
        }

        let net = netPrice()
        let exchanged = net.amount.multiplying(by: rate)
        return Price(amount: exchanged, currency: targetCurrency)
    }
    
    func exchangedNetPriceAsString() -> String {
        guard let net = exchangedNetPrice() else {
            return LocalizedString("undefined")
        }

        return net.amountAsString()
    }
    
    func formattedExchangedNetPrice() -> String {
        guard let net = exchangedNetPrice() else {
            return ""
        }
        
        return net.currencyFormattedPrice()
    }
    
    func priceMinusTax() -> Price {
        guard let tax = tax(), !WBPreferences.enteredPricePreTax() else {
            return price()
        }
        return Price(amount: price().amount.subtracting(tax.amount), currency: currency)
    }
    
    func priceMinusTaxExchanged() -> Price? {
        if let exchangedPrice = exchangedPrice(), let exchangedTax = exchangedTax() {
            if WBPreferences.enteredPricePreTax() {
                return Price(amount: exchangedPrice.amount, currency: currency)
            }
            return Price(amount: exchangedPrice.amount.subtracting(exchangedTax.amount), currency: currency)
        }
        return nil
    }

}


extension WBReceipt: SyncState {
    func getSyncId(provider: SyncProvider) -> String? {
        return provider == .googleDrive ? syncId : nil
    }
    
    func isSynced(syncProvider: SyncProvider) -> Bool {
        return syncProvider == .googleDrive ? isSynced : false
    }
    
    func isMarkedForDeletion(syncProvider: SyncProvider) -> Bool {
        return syncProvider == .googleDrive ? isMarkedForDeletion : false
    }
}
