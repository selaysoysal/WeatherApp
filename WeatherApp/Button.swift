//
//  Button.swift
//  WeatherApp
//
//  Created by Selay Soysal on 30/11/16.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit

class Button: UIButton {
    override func awakeFromNib() {
        
        layer.cornerRadius = 12.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(red: 0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        backgroundColor = UIColor.clear
        setTitleColor(UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: UIControlState())
    }
}
