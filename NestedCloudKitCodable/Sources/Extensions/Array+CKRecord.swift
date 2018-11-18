//
//  Array+CKRecord.swift
//  Hercules-iOS
//
//  Created by Guilherme Girotto on 12/11/18.
//  Copyright © 2018 Hercules. All rights reserved.
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
            let hasElement = uniqueElements.contains(where: { uniqueElement -> Bool in
                element.recordID.recordName == uniqueElement.recordID.recordName
            })
            if !hasElement {
                uniqueElements.append(element)
            }
        }
        return uniqueElements
    }
}
