//
//  ReportGenerator.swift
//  SmartReceipts
//
//  Created by Bogdan Evsenev on 03/12/2017.
//  Copyright © 2017 Will Baumann. All rights reserved.
//

import Foundation

typealias CategoryReceipts = (category: WBCategory, receipts: [WBReceipt])

@objcMembers
class ReportGenerator: NSObject {
    private(set) var trip: WBTrip!
    private(set) var database: Database!
    
    init(trip: WBTrip, database: Database) {
        self.trip = trip
        self.database = database
    }

    func generateTo(path: String) -> Bool {
        abstractMethodError()
        return false
    }
    
    func receiptColumns() -> [ReceiptColumn] {
        abstractMethodError()
        return []
    }
    
    func categoryColumns() -> [CategoryColumn] {
        return CategoryColumn.allColumns()
    }
    
    func distanceColumns() -> [DistanceColumn] {
        return DistanceColumn.allColumns() as! [DistanceColumn]
    }
    
    func receipts() -> [WBReceipt] {
        var receipts = database.allReceipts(for: trip, ascending: true) as! [WBReceipt]
        receipts = receipts.filter { !$0.isMarkedForDeletion }
        return ReceiptIndexer.indexReceipts(receipts, filter: { WBReportUtils.filterOutReceipt($0) })
    }
    
    func distances() -> [Distance] {
        let distances = database.fetchedAdapterForDistances(in: trip, ascending: true)
        return distances?.allObjects() as! [Distance]
    }
    
    func receiptsByCategories() -> [CategoryReceipts] {
        var result = [WBCategory: [WBReceipt]]()
        let receipts = self.receipts()
        
        receipts.forEach {
            guard let category = $0.category else { return }
            if result[category] == nil {
                result[category] = []
            }
            result[category]?.append($0)
        }
        
        if WBPreferences.printDailyDistanceValues() {
            let dReceipts = DistancesToReceiptsConverter.convertDistances(distances()) as! [WBReceipt]
            if let category = dReceipts.first?.category {
                result[category] = dReceipts
            }
        }
        
        return result
            .filter { !$0.value.isEmpty }
            .sorted { $0.key.customOrderId < $1.key.customOrderId }
            .map { ($0.key, $0.value) }
    }
}

fileprivate func abstractMethodError() { fatalError("Abstract Method") }
