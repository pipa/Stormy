// Playground - noun: a place where people can play

import Cocoa

let apiKey = "83c7c3bcf4febc8ca3b2744be23e4832"

let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL)
forecastURL!
let weatherData = NSData(contentsOfURL: forecastURL!)
println(weatherData!)