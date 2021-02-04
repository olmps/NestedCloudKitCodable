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

    @IBOutlet private var resultLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var schoolRecord: CKRecord?

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

    private var school: School {
        var schoolObject = School()
        schoolObject.name = "School Name"
        schoolObject.location = CLLocation(latitude: 37.331274, longitude: -122.030397)
        schoolObject.students = students
        schoolObject.director = director
        schoolObject.books = books

        return schoolObject
    }

    private var database: CKDatabase {
        return CKContainer(identifier: "iCloud.com.nestedCloudKitCodable.Container").publicCloudDatabase
    }

    @IBAction private func encodeTapped(_ sender: UIButton) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        resultLabel.text = "Loading..."

        do {
            let encodedRecords = try CKRecordEncoder().encode(school)
            schoolRecord = encodedRecords.last

            let saveOperator = CKModifyRecordsOperation(recordsToSave: encodedRecords)
            saveOperator.modifyRecordsCompletionBlock = { (records, recordsIDs, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()

                    if let error = error {
                        print(error)
                        self.resultLabel.text = "Error: \(error.localizedDescription)"
                    } else {
                        self.resultLabel.text = "Successfully encoded school object!"
                    }
                }
            }

            database.add(saveOperator)
        } catch let error {
            let formattedError = error as! CKCodableError //swiftlint:disable:this force_cast
            resultLabel.text = "Error: \(formattedError.localizedDescription)"
        }
    }

    @IBAction private func decodeTapped(_ sender: UIButton) {
        guard let schoolRecord = schoolRecord else {
            resultLabel.text = "Please encode the object first"
            return
        }

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        resultLabel.text = "Loading..."

        CKRecordDecoder().decode(School.self,
                                 from: schoolRecord,
                                 referenceDatabase: database) { (decodedSchool, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()

                if let error = error {
                    print(error)
                    self.resultLabel.text = "Error: \(error.localizedDescription)"
                } else if let decodedSchool = decodedSchool {
                    self.resultLabel.text = "Successfully encoded school object!"
                    print(decodedSchool)
                }
            }
        }
    }
}
