//
//  ViewController.swift
//  APOD_v4
//
//  Created by 王祥旭 on 2019/7/23.
//  Copyright © 2019 Hsiang-Hsu Wang. All rights reserved.
//

import UIKit
import MobileCoreServices

enum ItemLabel{
    case title, description, url, hdurl, date, copyright, mediaType
}

class ListViewController: UITableViewController {
    var initLoadCount = 15
    var imageArray = [ImageRecord]()
    let urlBaseString = "http://sprite.phys.ncku.edu.tw/astrolab/mirrors/apod"
    //let urlBaseString = "https://apod.nasa.gov/apod"
    var isFetchInProgress: Bool = false {
        didSet{
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.isFetchInProgress
            }
            if initLoadCount > 0 {
                initLoadCount = initLoadCount - 1
                loadMoreData()
                loadImagesForOnScreenCells()
                resumeAllOperations()
            }
        }
    }
    var lastDateFromNow = 0
    var dateStep = 1
    let dateFormatter = DateFormatter()
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        //title="Astronomy Picture of the Day"
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "每日一天文圖"
        let urlString = imageArray.isEmpty ? urlBaseString+"/apod.html" : ""
        //let urlString = imageArray.isEmpty ? urlBaseString+"/astropix.html" : ""
        isFetchInProgress = true
        fetchHTML(from: urlString)
        //loadMoreData()
        
    }
    
    func loadMoreData(){
        if !isFetchInProgress {
            isFetchInProgress = true
            for _ in 0..<dateStep {
                lastDateFromNow += 1
                fetchHTML(from: newFetchURLString())
            }
        }
    }
    
    func newFetchURLString() -> String {
        let dateString = dateFormatter.string(from: Date(timeIntervalSinceNow: Double(-lastDateFromNow)*(86400.0)))
        let urlString = urlBaseString + "/ap" + dateString + ".html"
        print(urlString)
        return urlString
    }

    func fetchHTML(from url: String) {
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            
            let alertController = UIAlertController(title: "Oops!", message: "Error fetching image details", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)

            if error != nil {
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)

                }
                print("fetch error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                DispatchQueue.main.async{
                    self.present(alertController, animated: true)

                }
                print("server error!")
                return
            }
        
            if let data = data {
                let fetchString = String(data: data, encoding: .utf8) ?? ""
                if let url = self.extract(.url, from: fetchString) {
                    let title = self.extract(.title, from: fetchString) ?? ""
                    let date = self.extract(.date, from: fetchString) ?? ""
                    let description = self.extract(.description, from: fetchString) ?? ""
                    let copyright = self.extract(.copyright, from: fetchString) ?? ""
                    let imageRecord = ImageRecord(title: title, date: date, description: description, url: url, hdurl: "", copyright: copyright, mediaType: "")
                    
//                    let encoder = JSONEncoder()
//                    encoder.outputFormatting = .prettyPrinted
//                    let data = try! encoder.encode(imageRecord)
//                    print(String(data: data, encoding: .utf8)!)
//                    let decoder = JSONDecoder()
//                    let newRecord = try! decoder.decode(ImageRecord.self, from: data)                    
//                    print("This is \(newRecord.state)")
                    
                    
                    DispatchQueue.main.async {
                        self.imageArray.append(imageRecord)  // This line need to be in the main thread to make sure the array.append happens before the tableView.reloadData
                        self.tableView.reloadData()
                    }
                }
            }
        self.isFetchInProgress = false
        }
        task.resume()
    }
    
    func extract(_ item: ItemLabel, from string: String) -> String? {
        switch item {
        case .url:
            if let rangeHead = string.range(of: "IMG SRC=\"") {
                let start = rangeHead.upperBound
                let end = string.index(string.endIndex, offsetBy: 0)
                let subString1 = String(string[start ..< end])
                if let rangeTail = subString1.firstIndex(of: "\"") {
                    let subString2 = String(subString1[subString1.startIndex ..< rangeTail])
                    print("urlurlurl: \(subString2)")
                    return subString2.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return nil
            }
            
        case .description:
            if let rangeHead = string.range(of: "<b> 說明: </b>") {
                let start = rangeHead.upperBound
                let end = string.index(string.endIndex, offsetBy: 0)
                let subString1 = String(string[start ..< end])
                if let rangeTail = subString1.range(of: "<p>") {
                    let end2 = rangeTail.lowerBound
                    let subString2 = String(subString1[subString1.startIndex ..< end2])
                    return subString2.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return nil
            }
            
        case .title:
            if let rangeHead = string.range(of: "style=\"max-width:100%\"></a>") {
                let start = rangeHead.upperBound
                let end = string.index(string.endIndex, offsetBy: 0)
                let subString1 = String(string[start ..< end])
                if let rangeHead2 = subString1.range(of: "<center>") {
                    let start2 = rangeHead2.upperBound
                    let end2 = subString1.index(subString1.endIndex, offsetBy: 0)
                    let subString2 = String(subString1[start2 ..< end2])
                    if let rangeHead3 = subString2.range(of: "<b>") {
                        let start3 = rangeHead3.upperBound
                        let end3 = subString2.index(subString2.endIndex, offsetBy: 0)
                        let subString3 = String(subString2[start3 ..< end3])
                        if let rangeTail = subString3.range(of: "</b>") {
                            let end4 = rangeTail.lowerBound
                            let subString4 = String(subString3[subString3.startIndex ..< end4])
                            return subString4.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
                return nil
            }
            
        case .date:
            if let rangeHead = string.range(of: "迷人的宇宙。") {
                let start = rangeHead.upperBound
                let end = string.index(string.endIndex, offsetBy: 0)
                let subString1 = String(string[start ..< end])
                if let rangeHead2 = subString1.range(of: "<p>") {
                    let start2 = rangeHead2.upperBound
                    let end2 = subString1.index(subString1.endIndex, offsetBy: 0)
                    let subString2 = String(subString1[start2 ..< end2])
                    if let rangeTail = subString2.range(of: "<br>") {
                        let end3 = rangeTail.lowerBound
                        let subString3 = String(subString2[subString2.startIndex ..< end3])
                        return subString3.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                return nil
            }
        case .copyright:
            if let rangeHead = string.range(of: "版權:") {
                let start = rangeHead.upperBound
                let end = string.index(string.endIndex, offsetBy: 0)
                let subString1 = String(string[start ..< end])
                
                if let rangeTail = subString1.range(of: "</center>") {
                    let end2 = rangeTail.lowerBound
                    let subString2 = String(subString1[subString1.startIndex ..< end2])
                    return subString2.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                return nil
            }
 
        default:
            break
        }
        return nil
    }

}

extension ListViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
        let imageDetails = imageArray[indexPath.row]
        cell.dateLabel.text = imageDetails.date
        cell.titleLabel.text = imageDetails.title
        cell.indexPath = indexPath
        cell.delegate = self
        cell.favorite = imageDetails.favorite
        
        if imageDetails.image != nil {
            cell.photoView.image = imageDetails.image
        } else {
            cell.photoView.image = nil
        }
        
        switch (imageDetails.state) {
        case .downloaded:
            cell.indicator.stopAnimating()
            break
        case .failed:
            cell.indicator.stopAnimating()
            cell.dateLabel.text = "Fail to load"
        case .new:
            cell.indicator.startAnimating()
            startDownload(for: imageDetails, at: indexPath)
        }
        
        return cell
    }
    

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = tableView.frame.size.height
        let contentYOffset = tableView.contentOffset.y
        let distanceToBottom = tableView.contentSize.height - contentYOffset
        if distanceToBottom < height {
            initLoadCount = 10
            loadMoreData()
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadImagesForOnScreenCells()
        resumeAllOperations()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnScreenCells()
        resumeAllOperations()
    }
    
    
    func suspendAllOperations(){
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations(){
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnScreenCells(){
        DispatchQueue.main.async {
            if let pathsArray = self.tableView.indexPathsForVisibleRows {
                let allPendingOperations = Set(self.pendingOperations.downloadInProgress.keys)
                var toBeCancelled = allPendingOperations
                let visiblePaths = Set(pathsArray)
                toBeCancelled.subtract(visiblePaths)
                
                var toBeStarted = visiblePaths
                toBeStarted.subtract(allPendingOperations)
                
                for indexPath in toBeCancelled {
                    if let pendingDownload = self.pendingOperations.downloadInProgress[indexPath] {
                        pendingDownload.cancel()
                    }
                    self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                }
                
                for indexPath in toBeStarted {
                    let recordToProcess = self.imageArray[indexPath.row]
                    if recordToProcess.state == .new {
                        self.startDownload(for: recordToProcess, at: indexPath)
                    }
                }
            }
        }
        
    }
    
    func startDownload(for imageDetails: ImageRecord, at indexPath: IndexPath){
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        
        //print("startDownload: downloading \(indexPath.row) ....")
        
        let downloader = ImageDownloader(imageDetails)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.downloadInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController {
            if imageArray[indexPath.row].image != nil {
            vc.photoRecord = imageArray[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            } else {
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            imageArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .insert:
            break
        default:
            break
        }
    }
    
    
}

extension ListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard !imageArray.isEmpty else { return [] }
        let imageRecord = imageArray[indexPath.row]
        
        let itemProvider = NSItemProvider(object: imageRecord)
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        return [dragItem]
    }
}

extension ListViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if coordinator.session.hasItemsConforming(toTypeIdentifiers: [kUTTypeData as String]) {
            coordinator.session.loadObjects(ofClass: ImageRecord.self){ (items) in
                guard let imageRecord = items.first as? ImageRecord else { return }
                
                var updatedIndexPaths = [IndexPath]()
                
                switch (coordinator.items.first?.sourceIndexPath, coordinator.destinationIndexPath) {
                case (.some(let sourceIndexPath), .some(let desinationIndexPath)):
                    if sourceIndexPath.row < desinationIndexPath.row {
                        updatedIndexPaths = (sourceIndexPath.row ... desinationIndexPath.row).map{IndexPath(item: $0, section: 0)}
                    } else if sourceIndexPath.row > desinationIndexPath.row {
                        updatedIndexPaths = (desinationIndexPath.row ... sourceIndexPath.row).map{IndexPath(item: $0, section: 0)}
                    }
                    self.tableView.beginUpdates()
                    self.imageArray.remove(at: sourceIndexPath.row)
                    self.imageArray.insert(imageRecord, at: desinationIndexPath.row)
                    self.tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
                    self.tableView.endUpdates()
                    self.loadImagesForOnScreenCells()
                    self.resumeAllOperations()
                    
                default:
                    break
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    
}

extension ListViewController: CellButtonDelegate {

    func Tapped(_ button: UIButton, with indexPath: IndexPath) {
        imageArray[indexPath.row].favorite = !imageArray[indexPath.row].favorite
        button.setTitle(imageArray[indexPath.row].favorite ? "♥️":"♡", for: .normal)
    }
    
    

}


