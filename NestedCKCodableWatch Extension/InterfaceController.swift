//
//  InterfaceController.swift
//  NestedCKCodableWatch Extension
//
//  Created by Guilherme Girotto on 29/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import WatchKit
import Foundation
import NestedCloudKitCodable

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
