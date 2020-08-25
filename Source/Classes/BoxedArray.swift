//
//  BoxedArray.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation

/// Encapsulates an array to pass it by reference
internal class BoxedArray<T> {

    var array: [T] = [T]()

    init() {}

    func append(_ element: T) {
        array.append(element)
    }
}
