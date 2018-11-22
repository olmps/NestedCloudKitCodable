//
//  BoxedArray.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation

internal class BoxedArray<T> {
    
    var array: Array<T> = [T]()
    
    init() {}
    
    func append(_ element: T) {
        array.append(element)
    }
}
