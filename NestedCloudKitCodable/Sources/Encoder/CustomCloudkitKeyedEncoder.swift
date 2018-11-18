//
//  CustomCloudkitKeyedEncoder.swift
//  Hercules-iOS
//
//  Created by Guilherme Girotto on 14/11/18.
//  Copyright © 2018 Hercules. All rights reserved.
//

import CloudKit
import Foundation

protocol CustomCloudkitKeyedEncoder {
    var generatedRecord: CKRecord { get }
}
