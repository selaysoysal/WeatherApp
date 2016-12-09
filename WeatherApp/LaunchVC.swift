//
//  LaunchVC.swift
//  WeatherApp
//
//  Created by Selay Soysal on 04/12/2016.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit
import CoreLocation

class LaunchVC: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    var fahreneit : Bool?

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        defaults.set(1, forKey: "main")
        defaults.set(false, forKey: "coordinates")
        defaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func fahreneit(_ sender: Any) {
        defaults.set(true, forKey: "fahreneit")
        defaults.set(1, forKey: "main")
        defaults.synchronize()
        performSegue(withIdentifier: "segueMainScreen", sender: nil)
    }
    @IBAction func celsius(_ sender: Any) {
        defaults.set(false, forKey: "fahreneit")
        defaults.set(1, forKey: "main")
        defaults.synchronize()
        performSegue(withIdentifier: "segueMainScreen", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
