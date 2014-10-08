//
//  ViewController.swift
//  Stormy
//
//  Created by Luis Matute on 10/3/14.
//  Copyright (c) 2014 Luis Matute. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    private let apiKey = "83c7c3bcf4febc8ca3b2744be23e4832"
    let locationManager = CLLocationManager()

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshActivityIndicator.hidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        println(locationManager.location)
        getCurrentWeatherData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentWeatherData() -> Void {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL)
        let weatherData = NSData(contentsOfURL: forecastURL!)
        let sharedSession = NSURLSession.sharedSession()
        let donwloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!) { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                let dataObj = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObj!, options: nil, error: nil) as NSDictionary
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.iconView.image = currentWeather.icon!
                    self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    
                    // Stop refresh Anim
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshButton.hidden = false
                    self.refreshActivityIndicator.hidden = true
                })
            } else {
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Conectivity error!", preferredStyle: .Alert)
                
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                networkIssueController.addAction(cancelButton)
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    // Stop refresh Anim
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshButton.hidden = false
                    self.refreshActivityIndicator.hidden = true
                })
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)
            }
        }
        donwloadTask.resume()

    }
    
    
    
    // Location services
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error)->Void in
            println(placemarks)
//            if error {
//                println("Reverse geocoder failed with error” + error.localizedDescription)
//                return
//            }
//            
//            if placemarks.count > 0 {
//                let pm = placemarks[0] as CLPlacemark
//                self.displayLocationInfo(pm)
//            } else {
//                println("Problem with the data received from geocoder”)
//            }
        })
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location. " + error.localizedDescription)
    }
    
    @IBAction func refresh() {
        getCurrentWeatherData()
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
    }
    

}

