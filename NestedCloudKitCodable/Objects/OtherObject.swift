//
//  OtherObject.swift
//  CloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation

struct OtherObject: CustomCloudKitCodable {
    
    var cloudKitRecordType: String {
        return "OtherObject"
    }
    
    var cloudKitIdentifier: String {
        return id
    }
    
    private let id = UUID().uuidString
    var name: String
}
