//
//  CKKeyedEncoder.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import Foundation

protocol CKKeyedEncoder {
    var generatedRecord: CKRecord { get }
}
