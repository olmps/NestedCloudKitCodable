//
//  Person.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import UIKit
import Foundation

struct Person: CKCodable {
    
    var cloudKitRecordType: String {
        return "Person"
    }
    
    var cloudKitIdentifier: String {
        return identifier
    }
    
    var id = UUID().uuidString
    var picture: UIImage
    var identifier: String
    var name: String
    var birthDate: Date
    
    init(name: String, birthDate: Date) {
        self.picture = UIImage(named: "userImage")!
        self.identifier = UUID().uuidString
        self.name = name
        self.birthDate = birthDate
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier, picture, name, birthDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dataPicture = try container.decode(Data.self, forKey: .picture)
        self.picture = UIImage(data: dataPicture)!
        
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.name = try container.decode(String.self, forKey: .name)
        self.birthDate = try container.decode(Date.self, forKey: .birthDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let pictureDate = picture.pngData()!
        try container.encode(pictureDate, forKey: .picture)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encode(birthDate, forKey: .birthDate)
    }
}
