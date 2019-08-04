//
//  PendingOperations.swift
//  APOD_v3
//
//  Created by 王祥旭 on 2019/7/19.
//  Copyright © 2019 Hsiang-Hsu Wang. All rights reserved.
//

import Foundation

class PendingOperations{
    lazy var downloadInProgress = [IndexPath: Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
