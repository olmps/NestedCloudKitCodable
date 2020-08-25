//
//  Array+CKRecord.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import Foundation

extension Array where Element: CKRecord {
    /*
        Filter the current Array removing duplicate CKRecords.
     */
    func filteredByUniqueIds() -> [Element] {
        var uniqueElements = [Element]()
        for element in self {
            let hasElement = uniqueElements.contains { element.recordID.recordName == $0.recordID.recordName }
            if !hasElement {
                uniqueElements.append(element)
            }
        }
        return uniqueElements
    }
}
