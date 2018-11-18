//
//  Object.swift
//  CloudKitCodable
//
//  Created by Guilherme Girotto on 18/11/18.
//  Copyright © 2018 Guilherme Girotto. All rights reserved.
//

import CoreLocation
import UIKit

struct Object: CustomCloudKitCodable {
    
    var cloudKitRecordType: String {
        return "Object"
    }
    var cloudKitIdentifier: String {
        return id
    }
    
    private let id = UUID().uuidString
    var asset: UIImage!
    var assets: [UIImage]!
    var date: Date!
    var dates: [Date]!
    var double: Double!
    var doubles: [Double]!
    var int: Int!
    var ints: [Int]!
    var location: CLLocation!
    var locations: [CLLocation]!
    var string: String!
    var strings: [String]!
    var reference: OtherObject!
    var references: [OtherObject]!
    
    init() { }
    
    func ignoredProperties() -> [String] {
        return ["asset"]
    }
    
    private enum CodingKeys: String, CodingKey {
        case asset, assets, date, dates, double, doubles,
            int, ints, location, locations, string, strings,
            reference, references
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dataAsset = try container.decode(Data.self, forKey: .asset)
        asset = UIImage(data: dataAsset)!
        
        let dataAssets = try container.decode([Data].self, forKey: .assets)
        assets = dataAssets.map { UIImage(data: $0)! }
        
        date = try container.decode(Date.self, forKey: .date)
        dates = try container.decode([Date].self, forKey: .dates)
        
        double = try container.decode(Double.self, forKey: .double)
        doubles = try container.decode([Double].self, forKey: .doubles)
        
        int = try container.decode(Int.self, forKey: .int)
        ints = try container.decode([Int].self, forKey: .ints)
        
        let locationValue = try container.decode(String.self, forKey: .location)
        let locationLatLong = locationValue.split(separator: ";")
        location = CLLocation(latitude: Double(locationLatLong[0])!, longitude: Double(locationLatLong[1])!)
        
        let locationsValues = try container.decode([String].self, forKey: .locations)
        let locationsLatLong = locationsValues.map { $0.split(separator: ";") }
        var locationsDecoded = [CLLocation]()
        locationsLatLong.forEach {
            let location = CLLocation(latitude: Double($0[0])!, longitude: Double($0[1])!)
            locationsDecoded.append(location)
        }
        locations = locationsDecoded
        
        string = try container.decode(String.self, forKey: .string)
        strings = try container.decode([String].self, forKey: .strings)
        
        reference = try container.decode(OtherObject.self, forKey: .reference)
        references = try container.decode([OtherObject].self, forKey: .references)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(asset.pngData()!, forKey: .asset)
        
        let assetsValues = assets.map { $0.pngData()! }
        try container.encode(assetsValues, forKey: .assets)
        
        try container.encode(date, forKey: .date)
        try container.encode(dates, forKey: .dates)
        
        try container.encode(double, forKey: .double)
        try container.encode(doubles, forKey: .doubles)
        try container.encode(int, forKey: .int)
        try container.encode(ints, forKey: .ints)
        
        let locationValue = "\(location.coordinate.latitude);\(location.coordinate.longitude)"
        try container.encode(locationValue, forKey: .location)
        
        var locationValues = [String]()
        locations.forEach {
            let locationValue = "\($0.coordinate.latitude);\($0.coordinate.longitude)"
            locationValues.append(locationValue)
        }
        try container.encode(locationValues, forKey: .locations)
        
        try container.encode(string, forKey: .string)
        try container.encode(strings, forKey: .strings)
        
        try container.encode(reference, forKey: .reference)
        try container.encode(references, forKey: .references)
    }
}
