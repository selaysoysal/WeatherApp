//
//  MainVC.swift
//  WeatherApp
//
//  Created by Selay Soysal on 30/11/16.
//  Copyright © 2016 Selay Soysal. All rights reserved.
//

import UIKit
import CoreLocation

class MainVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource {
  
    var wea: [Weather] = []
    var fiveDaysWeather: [FiveDaysWeather] = []
    var locate: [Location] = []
    
    let defaults = UserDefaults.standard
    
    var locationManager = CLLocationManager()
    
    var fahreneit : Bool?
    var icon : String?
    var temprature : Int?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLbl2: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var change: UIButton!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var degreeLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var rightImg: UIImageView!
    @IBOutlet weak var downImg: UIImageView!
    @IBOutlet weak var Celsius: UIButton!
    
    @IBAction func changeValuetoFah(_ sender: Any) {
        defaults.set(true, forKey: "fahreneit")
        defaults.synchronize()
        Celsius.isHidden = true
        change.isHidden = false
    }
    @IBAction func changeValue(_ sender: Any) {
        defaults.set(false, forKey: "fahreneit")
        defaults.synchronize()
        change.isHidden = true
        Celsius.isHidden = false
        
    }
    @IBAction func locateMe(_ sender: Any) {
        defaults.set(false, forKey: "coordinates")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        let currentDate = NSDate()
        leftImg.shake()
        rightImg.shake()
        downImg.shake()
        dayLbl.text = getDayOfWeek(fromDate:currentDate as Date)
        
        if fahreneit == true {
            Celsius.isHidden = true
            change.isHidden = false
        }
        else{
            change.isHidden = true
            Celsius.isHidden = false
        }
        
        self.scrollViewDidScroll(scrollView)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        self.hideArrows()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        downImg.isHidden = true
        defaults.setValue("OK", forKey: "SwipeUp")
        defaults.synchronize()
    }
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                // go to left page
                defaults.setValue("OK", forKey: "SwipeRight")
                defaults.synchronize()
                self.leftImg.isHidden = true
                print("Swiped right")
                self.performSegue(withIdentifier: "segueLeftScreen", sender: nil)
            case UISwipeGestureRecognizerDirection.down:
                // go to up page or refresh
                defaults.setValue("OK", forKey: "SwipeDown")
                defaults.synchronize()
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                // go to right page
                defaults.setValue("OK", forKey: "SwipeLeft")
                defaults.synchronize()
                self.rightImg.isHidden = true
                print("Swiped left")
                self.performSegue(withIdentifier: "segueRightScreen", sender: nil)
            case UISwipeGestureRecognizerDirection.up:
                // go to bottom page
                defaults.setValue("OK", forKey: "SwipeUp")
                defaults.synchronize()
                self.downImg.isHidden = true
                print("Swiped up")
                
            default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLocation:CLLocation = locations[0] as CLLocation
        let lat = Int(userLocation.coordinate.latitude)
        let lon = Int(userLocation.coordinate.longitude)
        locate.removeAll()
        fiveDaysWeather.removeAll()
        wea.removeAll()
        let coordinate = Location()
        coordinate.lat = lat
        coordinate.lon = lon
        self.locate.append(coordinate)
        self.weathers()
        
    }
    
    func weathers(){
        fahreneit = defaults.bool(forKey: "fahreneit")
        
        let lat: Int!
        let lon: Int!
        let unit: String!
        let loc = defaults.bool(forKey: "coordinates")
        if loc == true
        {
            lat = Int(defaults.integer(forKey: "lat"))
            lon = Int(defaults.integer(forKey: "lon"))
            
        }
        else{
            lat = locate[0].lat
            lon = locate[0].lon
        }
        
        if fahreneit == false {
            unit = "metric"
        }
        else{
            unit = "imperial"
        }
        currentWeatherData(lat: lat, lon: lon, unit: unit, completion: { success in
            DispatchQueue.main.async {
                self.jsonParserCurrent(json: success)
                let temp = Int(self.wea[0].temp!)
                self.degreeLbl.text = "\(temp)°"
                self.locationLbl.text = "\(self.wea[0].name!)"
                self.locationLbl2.text = "\(self.wea[0].name!)"
                self.changeBackgroud()
            }
        })
        
        fiveDaysForecast(lat: lat, lon: lon, unit: "metric", completion: { success in
            DispatchQueue.main.async {
                self.jsonParserFiveDays(json: success)
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "dailyCell"
        
        var cell: DailyCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? DailyCell
        
        if cell == nil {
            tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DailyCell
        }
        if fiveDaysWeather.count > 0{
            let forecast = fiveDaysWeather[indexPath.row]
            cell.dayLbl.text = forecast.hour!
            cell.highDegreeLbl.text = "\(forecast.tempMax!)°"
            cell.lowDegreeLbl.text = "\(forecast.tempMin!)°"
            if let url = URL(string: "http://openweathermap.org/img/w/\(forecast.icon!).png") {
                if let data = try? Data(contentsOf: url) {
                    cell.weatherIconImg.image = UIImage(data:data)!
                }
            }}
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fiveDaysWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        
        if fiveDaysWeather.count > 0{
            let forecast = fiveDaysWeather[indexPath.row]
            let icon = forecast.icon!
            if let url = URL(string: "http://openweathermap.org/img/w/\(icon).png"){
                if let data = try? Data(contentsOf: url) {
                    cell.weatherIcon.image = UIImage(data:data)!
                }
            }
            
            cell.dateTimeLbl?.text = forecast.hour!
            cell.degreeLbl?.text = "\(forecast.tempMax!)°"
        }
        return cell
        
    }
    
    func hideArrows(){
        if let up = defaults.value(forKey: "SwipeUp") as? String  {
            if up == "OK"{self.downImg.isHidden = true}
            else{downImg.isHidden = false}
        }else {downImg.isHidden = false}
        if let right = defaults.value(forKey: "SwipeRight") as? String{
            if right == "OK"{leftImg.isHidden = true}
            else{rightImg.isHidden = false}
        }else {rightImg.isHidden = false}
        if let left = defaults.value(forKey: "SwipeLeft") as? String {
            if left == "OK"{rightImg.isHidden = true}
            else{leftImg.isHidden = false}
        }else {leftImg.isHidden = false}
    }
    
    func getDayOfWeek(fromDate date: Date) -> String? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        switch weekDay {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            print("Error fetching days")
            return "Day"
        }
    }
    
    func changeBackgroud(){
    
        if wea.count>0{
            if let icon = wea[0].icon{
        switch icon{
        case "01d":
            let image : UIImage = UIImage(named: "clearskyD.jpg")!
            weatherImage.image = image
        case "02d":
            let image : UIImage = UIImage(named: "clouds.jpg")!
            weatherImage.image = image
        case "03d" :
            let image : UIImage = UIImage(named: "tumblr_static_tumblr_static_4nx6b6h2stgkw40c80gkcwwg8_640.jpg")!
            weatherImage.image = image
        case "04d":
            let image: UIImage = UIImage(named: "tumblr_static_tumblr_static_4nx6b6h2stgkw40c80gkcwwg8_640.jpg")!
            weatherImage.image = image
        case "09d" :
            let image : UIImage = UIImage(named: "rain.jpg")!
            weatherImage.image = image
        case "10d":
            let image : UIImage = UIImage(named: "rain.jpg")!
            weatherImage.image = image
        case "11d":
            let image : UIImage = UIImage(named: "thunder.jpg")!
            weatherImage.image = image
        case "13d":
            let image: UIImage = UIImage(named: "snow.jpeg")!
            weatherImage.image = image
        case "50d":
            let image :  UIImage = UIImage(named: "fog.jpg")!
            weatherImage.image = image
            
        case "01n" :
            let image : UIImage = UIImage(named: "clearSkyN.jpg")!
            weatherImage.image = image
            
        case "02n":
            let image: UIImage = UIImage(named: "azbulutgece.jpg")!
            weatherImage.image = image
            
        case "03n":
            let image: UIImage = UIImage(named: "tumblr_static_tumblr_static_4nx6b6h2stgkw40c80gkcwwg8_640.jpg")!
            weatherImage.image = image
            
        case "04n" :
            
            let image : UIImage = UIImage(named: "tumblr_static_tumblr_static_4nx6b6h2stgkw40c80gkcwwg8_640.jpg")!
            weatherImage.image = image
            
        case "09n" :
            let image : UIImage = UIImage(named: "rain.jpg")!
            weatherImage.image = image
            
        case "10n":
            let image : UIImage = UIImage(named: "rain.jpg")!
            weatherImage.image = image
            
        case "11n":
            let image: UIImage = UIImage(named: "thunder.jpg")!
            weatherImage.image = image
            
        case "13n":
            let image : UIImage = UIImage(named: "snow.jpeg")!
            weatherImage.image = image
            
        case "50n":
            let image : UIImage = UIImage(named: "fog.jpg")!
            weatherImage.image = image
            
            
            break
        default:
            let image : UIImage = UIImage(named: "thunder")!
            weatherImage.image = image
                }
            }
        }
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
    
    func fiveDaysForecast( lat: Int,lon: Int,unit: String, completion: (([String: Any])->())?){
        let key = "ee84c2b1ee564cd8519c9551de58969d"
        let url = URL(string:"http://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=\(unit)&APPID=\(key)")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!) { (data:Data?, response:URLResponse?, error:Error?) in
            if error != nil {
                print("[ERROR] Error with connection: \(error)")
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
    
    func jsonParserFiveDays(json: [String:Any]){
        
        let list = json["list"] as! [AnyObject]
        
        for items in list{
            let resp = FiveDaysWeather()
            if let main = items["main"] as? [String: Any] {
                let temp_max = main["temp_max"] as? Double
                print("temp\(temp_max!)")
                resp.tempMax = round(temp_max!)
                let temp_min = main["temp_min"] as? Double
                print("temp\(temp_min!)")
                resp.tempMin = round(temp_min!)
                let temp = main["temp"] as? Double
                print("temp\(temp!)")
                resp.temp = round(temp!)
                
            }
            let weather = items["weather"] as! [AnyObject]
            for items in weather{
                let main = items["main"] as! String //specify as String
                print(main)
                resp.main = main
                let description = items["description"] as! String //specify as String
                print(description)
                resp.descriprion = description
                let icon = items["icon"] as! String //specify as String
                print(icon)
                resp.icon = icon
            }
            let hour = items["dt_txt"] as! String
            print(hour)
            resp.hour = hour
            self.fiveDaysWeather.append(resp)
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
public extension UIView {
    
    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count ?? 100
        animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
        animation.autoreverses = true
        animation.byValue = translation ?? -5
        layer.add(animation, forKey: "shake")
    }
}
