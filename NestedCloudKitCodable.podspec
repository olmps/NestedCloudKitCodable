Pod::Spec.new do |s|

  s.name         = "NestedCloudKitCodable"
  s.version      = "1.0.1"
  s.summary      = "Nested encoder and decoder for CKRecords."
  s.description  = <<-DESC
  					NestedCloudKitCodable is a library to help you encode your custom objects to CloudKit CKRecord format
  					and decode they back to their original type.
                   DESC

  s.homepage     = "https://github.com/ggirotto/NestedCloudkitCodable"
  s.license      = "BS2D-2-Clause"
  s.author             = { "Guilherme Girotto" => "guiga741@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_version = '4.2'
  s.source       = { :git => "https://github.com/ggirotto/NestedCloudkitCodable.git", :tag => s.version.to_s }
  s.source_files  = "NestedCloudKitCodable/Sources/**/*.swift"
  s.ios.frameworks = "CloudKit", "Foundation"

end
