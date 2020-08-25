//
//  ViewController.swift
//  NestedCloudKitCodable
//
//  Created by ggirotto on 08/25/2020.
//  Copyright (c) 2020 ggirotto. All rights reserved.
//

import UIKit
import CloudKit
import NestedCloudKitCodable

class ViewController: UIViewController {

    private var director: Person {
        return Person(name: "Director", birthDate: Date())
    }

    private var students: [Person] {
        let studentObject1 = Person(name: "Student1", birthDate: Date())
        let studentObject2 = Person(name: "Student2", birthDate: Date())

        return [studentObject1, studentObject2]
    }

    private var books: [Book] {
        let book1 = Book(identifier: UUID().uuidString,
                         title: "First Book Title",
                         pages: 300,
                         available: true)

        let book2 = Book(identifier: UUID().uuidString,
                         title: "Second Book Title",
                         pages: 500,
                         available: true)

        return [book1, book2]
    }

    private var database: CKDatabase {
        return CKContainer(identifier: "iCloud.com.nestedCloudKitCodable.Container").publicCloudDatabase
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var schoolObject = School()
        schoolObject.name = "School Name"
        schoolObject.location = CLLocation(latitude: 37.331274, longitude: -122.030397)
        schoolObject.students = students
        schoolObject.director = director
        schoolObject.books = books

        do {
            let encodedRecords = try CKRecordEncoder().encode(schoolObject)

            let saveOperator = CKModifyRecordsOperation(recordsToSave: encodedRecords)
            saveOperator.modifyRecordsCompletionBlock = { (records, recordsIDs, error) in
                if let error = error {
                    print(error)
                } else {
                    self.decodeSchool(encodedRecords.last!)
                }
            }

            database.add(saveOperator)
        } catch let error {
            let formattedError = error as! CKCodableError //swiftlint:disable:this force_cast
            print(formattedError)
        }
    }

    private func decodeSchool(_ schoolRecord: CKRecord) {
        CKRecordDecoder().decode(School.self,
                                 from: schoolRecord,
                                 referenceDatabase: database) { (decodedSchool, error) in
            if let error = error {
                print(error)
            } else if let decodedSchool = decodedSchool {
                print(decodedSchool)
            }
        }
    }
}
