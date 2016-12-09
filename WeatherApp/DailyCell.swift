//
//  DailyCell.swift
//  WeatherApp
//
//  Created by Selay Soysal on 30/11/16.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit

class DailyCell: UITableViewCell {
    
    @IBOutlet weak var weatherIconImg: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var highDegreeLbl: UILabel!
    @IBOutlet weak var lowDegreeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
   
}
