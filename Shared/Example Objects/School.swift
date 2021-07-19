//
//  School.swift
//  CloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CoreLocation
import NestedCloudKitCodable
import UIKit
import CloudKit

// swiftlint:disable implicitly_unwrapped_optional
struct School: CKCodable {
    var cloudKitRecordType: String { "School" }
    var cloudKitIdentifier: String { identifier }

    var identifier = UUID().uuidString
    var name: String!
    var location: CLLocation!
    var students: [Person]!
    var director: Person!
    var books: [Book]!

    init() { }

    private enum CodingKeys: String, CodingKey {
        case name, location, students, director, books
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)

        let stringLocation = try container.decode(String.self, forKey: .location)
        let splitedLocation = stringLocation.split(separator: ";")

        // swiftlint:disable force_unwrapping
        let latitude = Double(splitedLocation[0])!
        let longitude = Double(splitedLocation[1])!
        // swiftlint:enable force_unwrapping

        let schoolLocation = CLLocation(latitude: latitude, longitude: longitude)
        self.location = schoolLocation

        self.students = try container.decode([Person].self, forKey: .students)
        self.director = try container.decode(Person.self, forKey: .director)
        self.books = try container.decode([Book].self, forKey: .books)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let formattedLocation = "\(location.coordinate.latitude);\(location.coordinate.longitude)"
        try container.encode(formattedLocation, forKey: .location)

        try container.encode(students, forKey: .students)
        try container.encode(director, forKey: .director)
        try container.encode(books, forKey: .books)
    }
    
    func cloudKitReferenceActions() -> [String : CKRecord.Reference.Action] {
        return [
            "students": .deleteSelf,
            "director": .deleteSelf,
            "books": .none
        ]
    }
}
