//
//  CKRecord.swift
//  Hercules-iOS
//
//  Created by Guilherme Girotto on 13/11/18.
//  Copyright © 2018 Hercules. All rights reserved.
//

import CloudKit
import Foundation

extension CKRecord {
    /**
        Returns all references associated with this CKRecord.
     */
    var references: [CKRecord.Reference] {
        var references = [CKRecord.Reference]()
        for (_, value) in self {
            if let value = value as? CKRecord.Reference {
                references.append(value)
            } else if let values = value as? [CKRecord.Reference] {
                references.append(contentsOf: values)
            }
        }
        return references
    }
}
