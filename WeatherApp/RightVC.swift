//
//  RightVC.swift
//  WeatherApp
//
//  Created by Selay Soysal on 30/11/16.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RightVC: UIViewController,UITableViewDataSource, UITableViewDelegate{
    
    
    var place = [NSManagedObject]()
    let defaults = UserDefaults.standard
    var fahreneit: Bool?
    
    @IBOutlet weak var tableView: UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        fahreneit = defaults.bool(forKey: "fahreneit") as Bool
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            place = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return place.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = place[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = name.value(forKey: "cityName") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let city = place [indexPath.row]
        defaults.set(true, forKey: "coordinates")
        let lat = city.value(forKey: "latitude") as! Int
        let lon = city.value(forKey: "longitude") as! Int
        defaults.set(lat, forKey: "lat")
        defaults.set(lon, forKey: "lon")
        defaults.synchronize()
        self.performSegue(withIdentifier: "segueBackFromRight", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // remove the deleted item from the model
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.delete(place[indexPath.row] )
            place.remove(at: indexPath.row)
            do {
                try context.save()
            } catch _ {
            }
            
            // remove the deleted item from the `UITableView`
            self.tableView.deleteRows(at: [indexPath], with: .fade)}
        else{return}
    }
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                // go to left page
                print("Swiped right")
                self.performSegue(withIdentifier: "segueBackFromRight", sender: nil)
                
            default:
                break
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
