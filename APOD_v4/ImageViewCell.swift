//
//  ImageViewCell.swift
//  APOD_v4
//
//  Created by 王祥旭 on 2019/7/23.
//  Copyright © 2019 Hsiang-Hsu Wang. All rights reserved.
//

protocol CellButtonDelegate {
    func Tapped(_ button: UIButton, with indexPath: IndexPath)
}

import UIKit

class ImageViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var photoView: UIImageView!
    var delegate: CellButtonDelegate?
    var indexPath: IndexPath?
    var favorite: Bool = false {
        didSet{
            favoriteButton.setTitle(favorite ? "♥️":"♡", for: .normal)
        }
    }
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func heartButton(_ sender: UIButton) {
        //print("\(dateLabel.text!) click")
        delegate?.Tapped(sender, with: indexPath!)
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
