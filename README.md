# NestedCloudkitCodable

Provides a simple way of Encoding and Decoding custom objects to/from Cloudkit through custom `Encoder` and `Decoder` which converts your structure to `CKRecord` and vice-versa. It can be used with nested objects.

Inspired by [CloudkitCodable](https://github.com/insidegui/CloudKitCodable).

## Installation

### CocoaPods

Add the following entry to your Podfile:

```rb
pod 'NestedCloudKitCodable'
```

Then run `pod install`.

### Carthage

Add the following entry to your `Cartfile`:

```
github "ggirotto/NestedCloudkitCodable"
```

Then run `carthage update`.

If this is your first time using Carthage in the project, see [Carthage docs](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for extra install steps.

### Manually

- Drag the **Sources** folder anywhere in your project.

## Usage

### `CKCodable` protocol

Implements `CustomCloudkitCodable` in the models that you want to convert to/from `CKRecord`. The protocol requires two properties to be implemented.

```swift
var cloudKitRecordType: String { get }
```
is the Record Type that represents that object in `CloudKit` container.  

```swift
var cloudKitIdentifier: String { get }
```
is the identifier from that object, which will be used as the identifier from the `CKRecord` when converting the object to a `CKRecord`.

**Important:** Use unique identifiers for your objects to avoid creating unecessary `CKRecords`.

This protocol also let you implement the function
```swift 
func ignoredProperties() -> [String]
```
which how its name suggests, let you ignore some properties from being encoded in the resultant `CKRecord`.

### CLLocation

`CLLocation` properties has a special behavior. Since they are primitive types for `CloudKit` but they are not for `Codable` protocol, it was necessary to create a workaround to encode/decode them.

Single `CLLocation` must be encoded in the format `"latitude;longitude"`, i.e, as a String splited by `;`.
Multiple `CLLocations` must follow the same pattern, and must be encoded/decoded as an array of `String` with each `CLLocation` splited using the same pattern described above

## Examples

### Encoding

Let `School` be your custom object as follows.

```swift
struct School: CKCodable {
    
    var cloudKitRecordType: String {
        return "School"
    }
    var cloudKitIdentifier: String {
        return id
    }
    
    var id = UUID().uuidString
    var name: String!
    var location: CLLocation!
    var students: [Person]!
    var director: Person!
    var books: [Book]!
}
```

To encode it, just use `CKRecordEncoder` to encode it, simple as follows.

```swift
let school = School()
        
do {
    let encodedRecords = try CKRecordEncoder().encode(school)
    ...
    // Save encodedRecords to your Cloudkit database
} catch let error as CKCodableError {
    // Handle errors
} catch { }
```

### Decoding

Consider the same `School` object, to `Decode` from its original `CKRecord` back to `School` object, use `CKRecordDecoder` as follows.

```swift
let schoolRecord = ... // Your school object CKRecord fetched from CloudKit
let referenceDatabase = CKContainer.default().publicCloudDatabase // Database where related CKRecords are stored

CKRecordDecoder().decode(School.self,
                         from: schoolRecord,
                         referenceDatabase: referenceDatabase) { (decodedSchool, error) in
    if let error = error {
        // Adds your error handling here
    }

    let schoolObject = decodedSchool as! School

    ...
}
```

Note that `decode` function is asynchronous. This is necessary because when your object has nested objects associated, the decode function fetch all `CKRecords` from these nested objects before decoding the original one. In the example above, the `decode` function will fetch all records from `students`,  `books` and `director` nested objects before decoding the main `School` object.

Also, it's necessary to send the `referenceDatabase` which these records will be looked for.

You can find this example objects [here](https://github.com/ggirotto/NestedCloudkitCodable/tree/master/Example/Shared/Example%20Objects)

## Feedback/Contribution

Thanks for using this library! If you are experiencing some trouble in its usage or have noticed some inconsistency or bug, please create an issue so I can investigate it.

Also feel free to contribute to the project by creating a PR :)
