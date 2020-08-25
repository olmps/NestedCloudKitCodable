//
//  Person.swift
//  NestedCloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import Foundation
import NestedCloudKitCodable
import UIKit

struct Person: CKCodable {
    var cloudKitRecordType: String { "Person" }
    var cloudKitIdentifier: String { identifier }

    var identifier = UUID().uuidString
    var picture: UIImage
    var name: String
    var birthDate: Date

    init(name: String, birthDate: Date) {
        self.picture = UIImage(named: "default-user")! //swiftlint:disable:this force_unwrapping
        self.name = name
        self.birthDate = birthDate
    }

    private enum CodingKeys: String, CodingKey {
        case identifier, picture, name, birthDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let dataPicture = try container.decode(Data.self, forKey: .picture)
        self.picture = UIImage(data: dataPicture)! //swiftlint:disable:this force_unwrapping

        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.name = try container.decode(String.self, forKey: .name)
        self.birthDate = try container.decode(Date.self, forKey: .birthDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let pictureDate = picture.pngData()! //swiftlint:disable:this force_unwrapping
        try container.encode(pictureDate, forKey: .picture)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encode(birthDate, forKey: .birthDate)
    }
}
