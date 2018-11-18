//
//  BoxedArray.swift
//  Hercules-iOS
//
//  Created by Guilherme Girotto on 14/11/18.
//  Copyright © 2018 Hercules. All rights reserved.
//

import Foundation

internal class BoxedArray<T> {
    
    var array: Array<T> = [T]()
    
    init() {}
    
    func append(_ element: T) {
        array.append(element)
    }
}
