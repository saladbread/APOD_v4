//
//  ImageRecord.swift
//  APOD_v4
//
//  Created by 王祥旭 on 2019/7/23.
//  Copyright © 2019 Hsiang-Hsu Wang. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

enum ImageRecordState: String, Codable {
    case new, downloaded, failed
}

final class ImageRecord: NSObject, Codable, NSItemProviderWriting, NSItemProviderReading {

    
    var explanation: String
    var title: String
    var date: String
    var copyright: String
    var mediaType: String
    var image: UIImage?
    var url: String
    var hdurl: String
    var state: ImageRecordState = .new
    var favorite: Bool = false
    
    init(title: String = "", date: String = "", description: String = "", url: String = "", hdurl: String = "", copyright: String = "", mediaType: String = "") {
        self.title = title
        self.date = date
        self.url = url
        self.hdurl = hdurl
        self.explanation = description
        self.copyright = copyright
        self.mediaType = mediaType
    }
    
    private enum CodingKeys : String, CodingKey {
        case title, date, url, hdurl, description, copyright, mediaType, favorite
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(url, forKey: .url)
        try container.encode(hdurl, forKey: .hdurl)
        try container.encode(explanation, forKey: .description)
        try container.encode(copyright, forKey: .copyright)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encode(favorite, forKey: .favorite)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(String.self, forKey: .date)
        url = try container.decode(String.self, forKey: .url)
        hdurl = try container.decode(String.self, forKey: .hdurl)
        explanation = try container.decode(String.self, forKey: .description)
        copyright = try container.decode(String.self, forKey: .copyright)
        mediaType = try container.decode(String.self, forKey: .mediaType)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        image = nil
        state = .new
        
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount:  100)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ImageRecord {
        let decoder = JSONDecoder()
        do {
            let myJason = try decoder.decode(ImageRecord.self, from: data)
            return myJason
        } catch {
            fatalError("Err")
        }
    }
    
    
}
