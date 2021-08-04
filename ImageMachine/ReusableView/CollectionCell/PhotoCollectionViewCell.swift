//
//  PhotoCollectionViewCell.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 05/08/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 
    func setupView(item: ImageModel) {
        let image = UIImage(data: item.img ?? Data())
        if let img = image {
            imageView.image = img
        }
    }

}
