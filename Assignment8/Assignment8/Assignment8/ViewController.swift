//
//  ViewController.swift
//  Assignment8
//
//  Created by user239837 on 3/31/24.
//

import UIKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    let apiKey = "53fad73944d454da8c0506e5244d51c6"
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        fetchWeatherData(for: location.coordinate)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //handleError(error)
    }
    // Fetch the weather data
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        guard let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&exclude=hourly,daily&appid=\(self.apiKey)") else { return }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error")
                return
            }
            guard let data = data else {
                print("Error decoding weather data:")
                return
            }
            self.parseWeatherData(data)
            
        }
        .resume()
    }
    
    
    func parseWeatherData(_ data: Data) {
        do {
            let weatherData = try JSONDecoder().decode(Weather.self, from: data)
            updateUI(with: weatherData)
        } catch {
         print("Error")
        }
        
        
        
    }
    
    func fetchWeatherIcon(with iconCode: String, completion: @escaping (UIImage?) -> Void) {
        let imageUrlString = "https://api.openweathermap.org/img/w/\(iconCode).png"
        guard let url = URL(string: imageUrlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }
            
            completion(image)
        }
        
        task.resume()
    }

    func updateUI(with weatherData: Weather) {
        print("logging weather Data", weatherData);
        DispatchQueue.main.async {
            self.cityLabel.text = weatherData.name
            self.descriptionLabel.text = weatherData.weather.first?.description
            
            let temperatureInCelsius = weatherData.main.temp - 273.15
            self.temperatureLabel.text = "\(Int(temperatureInCelsius))°C"
            self.humidityLabel.text = "humidity: \(weatherData.main.humidity)%"
            self.windLabel.text = "Wind: \(Int(weatherData.wind.speed)) m/s"
            
            if let weatherIconCode = weatherData.weather.first?.icon {
                self.fetchWeatherIcon(with: weatherIconCode) {
                    image in DispatchQueue.main.async {
                        self.weatherImage.image = image
                    }
                }
            }
        }
    }
}
    
    
        
    
    

