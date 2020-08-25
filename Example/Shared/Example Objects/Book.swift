//
//  Book.swift
//  CloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation
import NestedCloudKitCodable

struct Book: CKCodable {
    var cloudKitRecordType: String { "Book" }
    var cloudKitIdentifier: String { identifier }

    var identifier = UUID().uuidString
    var title: String
    var pages: Int
    var available: Bool
}
