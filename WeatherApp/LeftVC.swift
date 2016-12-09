//
//  LeftVC.swift
//  WeatherApp
//
//  Created by Selay Soysal on 30/11/16.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class LeftVC: UIViewController, MKMapViewDelegate,UISearchBarDelegate {
   
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var defaults = UserDefaults.standard
    var wea: [Weather] = []
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func saveToFav(_ sender: Any) {
      
        
        let lat = defaults.integer(forKey: "lat")
        let lon = defaults.integer(forKey: "lon")
        var city: String = ""
        
        let alert = UIAlertController(title: "New Favorite Place",
                                      message: "Add a city name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",style: .default,handler: { (action:UIAlertAction) -> Void in
            
            let textField = alert.textFields!.first
            city = textField!.text!
            self.saveCity(name: city, lat: lat, lon: lon)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",style: .default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,animated: true,completion: nil)

    }
  
    @IBAction func goDetails(_ sender: Any) {
        defaults.set(true, forKey: "coordinates")
        defaults.synchronize()
        self.performSegue(withIdentifier: "segueLeftToMain", sender: nil)
        
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    var searchActive : Bool = false
    var fahreneit: Bool?
    
    var Places = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        // Init the zoom level
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 42, longitude: 28)
        let span = MKCoordinateSpanMake(2, 2)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        mapView.delegate = self
        fahreneit = defaults.bool(forKey: "fahreneit") as Bool
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        mapView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                self.performSegue(withIdentifier: "segueBackFromLeft", sender: nil)
            default:
                break
            }
        }
    }
    func handleTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        let info = CustomPointAnnotitation()
        var annotationView:MKPinAnnotationView!
        
        let location = gestureReconizer.location(in: mapView)
        mapView.removeAnnotations(mapView.annotations)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        info.coordinate = coordinate
        annotationView = MKPinAnnotationView(annotation: info, reuseIdentifier: "pin")
        self.mapView.addAnnotation(annotationView.annotation!)
        mapView.addAnnotation(info)
        let lat = Int(coordinate.latitude)
        let lon = Int(coordinate.longitude)
        
        let unit: String!
        if fahreneit == false {
            unit = "metric"
        }
        else{
            unit = "imperial"
        }
        
        
        self.currentWeatherData(lat: lat, lon: lon, unit: unit, completion: { success in
            
            DispatchQueue.main.async {
                self.jsonParserCurrent(json: success)
            }
        })
        if self.wea.count>0{
            let temp = Int(self.wea[0].temp!)
            info.title = "\(temp)"
        }
        self.defaults.set(lat, forKey: "lat")
        self.defaults.set(lon, forKey: "lon")
        self.defaults.synchronize()
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "pin"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "point.png")
        }
        
        return annotationView
    }
    
    
    func currentWeatherData(lat: Int,lon: Int,unit: String, completion: (([String: Any])->())?){
        
        let key = "ee84c2b1ee564cd8519c9551de58969d"
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=\(unit)&APPID=\(key)")
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!) { (data, response, error) in
            
            
            if error != nil {
                
                
            } else {
                do {
                    //debug
                    print("[DEBUG]")
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:[.mutableContainers, .allowFragments]) as? [String: Any]
                    print(json!)
                    completion?(json!)
                }
                catch {
                    print("[ERROR] [DEBUG] Something went wrong during data download from the server.")
                    completion?(["":0])
                }
            }
            
            
        }
        task.resume()
        
    }
    
    func jsonParserCurrent(json: [String:Any]){
        let resp = Weather()
        if let main = json["main"] as? [String: Any] {
            let temp = main["temp"] as? Double
            print("temp\(temp!)")
            resp.temp = round(temp!)
            let temp_max = main["temp_max"] as? Double
            print("temp\(temp_max!)")
            resp.tempMax = round(temp_max!)
            let temp_min = main["temp_min"] as? Double
            print("temp\(temp_min!)")
            resp.tempMin = round(temp_min!)
        }
        let items = json["weather"] as! [AnyObject]
        let main = items[0]["main"] as! String
        print(main)
        resp.main = main
        let description = items[0]["description"] as! String
        print(description)
        resp.descriprion = description
        let icon = items[0]["icon"] as! String
        print(icon)
        resp.icon = icon
        let name = json["name"] as! String
        print("name\(name)")
        resp.name = name
        wea.append(resp)
    }
    
    func saveCity(name: String, lat: Int, lon:Int) {
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Places",
                                                 in:managedContext)
        
        let place = NSManagedObject(entity: entity!,
                                    insertInto: managedContext)
        
        place.setValue(name, forKey: "cityName")
        place.setValue(lat, forKey: "latitude")
        place.setValue(lon, forKey: "longitude")
        
        do {
            try managedContext.save()
            Places.append(place)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let info = CustomPointAnnotitation()
            var annotationView = MKAnnotationView()
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            annotationView = MKPinAnnotationView(annotation: info, reuseIdentifier: "pin")
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            if self.wea.count>0{
                info.title = "\(self.wea[0].temp!)"
            }
            self.mapView.addAnnotation(info)
            
            
            let lat = Int(self.pointAnnotation.coordinate.latitude)
            let lon = Int(self.pointAnnotation.coordinate.longitude)
            
            let unit: String!
            if self.fahreneit == false {
                unit = "metric"
            }
            else{
                unit = "imperial"
            }
            
            self.currentWeatherData(lat: lat, lon: lon, unit: unit, completion: { success in
                
                DispatchQueue.main.async {
                    self.jsonParserCurrent(json: success)
                }
            })
            
            self.defaults.set(lat, forKey: "lat")
            self.defaults.set(lon, forKey: "lon")
            self.defaults.synchronize()
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
