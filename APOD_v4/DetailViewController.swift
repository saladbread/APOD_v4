//
//  DetailViewController.swift
//  APOD_v2
//
//  Created by 王祥旭 on 2018/9/21.
//  Copyright © 2018年 Hsiang-Hsu Wang. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var photoRecord: ImageRecord! // this variable should be here, since it breaks the MVC structure
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard photoRecord != nil else { fatalError("DetailViewContriller: data does not exist!") }
        let imageWidth = photoRecord.image?.size.width
        let imageHeight = photoRecord.image?.size.height
        //navigationController?.hidesBarsOnTap = true
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth!, height: imageHeight!))
        imageView.image = photoRecord.image
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.6))
        
        scrollView.contentSize = imageView.bounds.size
        scrollView.backgroundColor = UIColor.black
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.indicatorStyle = .white
        scrollView.delegate = self
        
        webView = WKWebView(frame: CGRect(x: 0, y: view.bounds.height * 0.6, width: view.bounds.width, height: view.bounds.height * 0.4))
        
        print(photoRecord.copyright)
        title = photoRecord.date
        let descriptionString = "<center><b><font size=\"20\">" + photoRecord.title +
            "</font></b><font size=\"10\"></br> credit: "+photoRecord.copyright+" </center><br></font>" + "<html><body><font size=\"12\"><p align=\"justify\">"+photoRecord.explanation + "</p></font></body></html>"
        
        webView.loadHTMLString(descriptionString, baseURL: nil)
        
        
        
        setZoomScale()
        
        setGestureRecognizer()
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        view.addSubview(webView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setZoomScale(){
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(heightScale, widthScale)
        scrollView.zoomScale = 1.0
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.6)
        webView.frame = CGRect(x: 0, y: view.bounds.height * 0.6, width: view.bounds.width, height: view.bounds.height * 0.4)
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.6, height: view.bounds.height)
            webView.frame = CGRect(x: view.bounds.width * 0.6, y: 0, width: view.bounds.width * 0.4, height: view.bounds.height)
        }
        setZoomScale()
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centeredImageView(scrollView)
    }
    
    func setGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
        
        centeredImageView(scrollView)
    }
    
    func centeredImageView(_ scrollView: UIScrollView){
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.frame.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
