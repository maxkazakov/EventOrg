//
//  BillImageCollectionViewCell.swift
//  EventOrg
//
//  Created by Максим Казаков on 20/02/2017.
//  Copyright © 2017 Максим Казаков. All rights reserved.
//

import UIKit

class BillImageCollectionViewCell: UICollectionViewCell {
    
    func setImage(_ image: UIImage){
        self.imageView.image = image
        setDefaultBorder()
    }
    
    // MARK: - Helpers
    func setSelectedBorder(){
        self.imageView.layer.borderWidth = 1.5
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.borderColor = UIColor.black.cgColor
    }
    func setDefaultBorder(){
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    
}
