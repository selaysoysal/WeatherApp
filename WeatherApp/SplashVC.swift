//
//  SplashVC.swift
//  WeatherApp
//
//  Created by Selay Soysal on 09/12/2016.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    let defaults = UserDefaults.standard
    @IBOutlet weak var sunImg: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        if defaults.integer(forKey: "main") == 1{
            performSegue(withIdentifier: "segueSplashToMain", sender: nil)
        }else{
            performSegue(withIdentifier: "segueToLaunch", sender: nil)
        }
        
        defaults.set(false, forKey: "coordinates")
        defaults.synchronize()
        self.rotateView(targetView: sunImg)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func rotateView(targetView: UIImageView, duration: Double = 1.0) {
        UIImageView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(M_PI))
        }){ finished in
            self.rotateView(targetView: targetView, duration: duration)
        }
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
