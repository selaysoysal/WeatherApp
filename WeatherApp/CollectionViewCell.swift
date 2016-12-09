//
//  CollectionViewCell.swift
//  WeatherApp
//
//  Created by Selay Soysal on 04/12/2016.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var degreeLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
