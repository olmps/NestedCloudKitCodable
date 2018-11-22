//
//  ViewController.swift
//  NestedCKCodableExamples
//
//  Created by Guilherme Girotto on 22/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CloudKit
import UIKit
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
        let book1 = Book(id: UUID().uuidString,
                         title: "First Book Title",
                         pages: 300,
                         available: true)
        
        let book2 = Book(id: UUID().uuidString,
                         title: "Second Book Title",
                         pages: 500,
                         available: true)
        
        return [book1, book2]
    }
    
    private var database: CKDatabase {
        return CKContainer.default().publicCloudDatabase
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
        } catch let error as CKCodableError {
            print(error)
        } catch { }
        
    }
    
    private func decodeSchool(_ schoolRecord: CKRecord) {
        CKRecordDecoder().decode(School.self,
                                 from: schoolRecord,
                                 referenceDatabase: database) { (decodedSchool, error) in
            if let decodedSchool = decodedSchool {
                print(decodedSchool)
            }
        }
    }

}

