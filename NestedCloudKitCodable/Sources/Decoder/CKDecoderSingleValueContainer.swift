//
//  CKDecoderSingleValueContainer.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import Foundation

internal class CKDecoderSingleValueContainer: SingleValueDecodingContainer {
    
    var records: [CKRecord]
    var codingPath: [CodingKey]
    private let recordBeingAnalyzed: CKRecord
    
    init(records: [CKRecord], recordBeingAnalyzed: CKRecord, codingPath: [CodingKey]) {
        self.records = records
        self.codingPath = codingPath
        self.recordBeingAnalyzed = recordBeingAnalyzed
    }
}

extension CKDecoderSingleValueContainer {
    
    func decodeNil() -> Bool {
        return true
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = _CKRecordDecoder(records: records,
                                       recordBeingAnalyzed: recordBeingAnalyzed)
        return try T(from: decoder)
    }
    
}
