//
//  InfoDownloader.swift
//  APOD_v4
//
//  Created by 王祥旭 on 2019/7/24.
//  Copyright © 2019 Hsiang-Hsu Wang. All rights reserved.
//

import Foundation
import UIKit

class InfoDownloader: Operation {
    let imageRecord: ImageRecord
    
    init(_ imageRecord: ImageRecord){
        self.imageRecord = imageRecord
    }
    
    override func main() {

        var newURLString = "http://sprite.phys.ncku.edu.tw/astrolab/mirrors/apod"
        //        let urlString = String(imageRecord.url)
        //        var stringArray = urlString.components(separatedBy: "/")
        //        for index in stringArray.count-3...stringArray.count-1 {
        //            print(stringArray[index])
        //            newURLString += "/"
        //            newURLString += stringArray[index]
        //        }
        
        newURLString += "/" + imageRecord.url
        print("ImageDownloader: urlString= \(newURLString)")
        
        //guard let imageData = try? Data(contentsOf: URL(string: imageRecord.url)!) else {
        guard let imageData = try? Data(contentsOf: URL(string: newURLString)!) else {  //get images from NCKU
            imageRecord.state = .failed
            imageRecord.image = UIImage(named: "Placeholder")!
            return
            
        }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            imageRecord.image = UIImage(data: imageData) ?? UIImage(named: "Placeholder")!
            imageRecord.state = .downloaded
        } else {
            imageRecord.state = .failed
            imageRecord.image = UIImage(named: "Placeholder")!
        }
    }
}
