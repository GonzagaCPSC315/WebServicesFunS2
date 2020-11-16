//
//  FlickrAPI.swift
//  WebServicesFun
//
//  Created by Gina Sprint on 11/3/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//

import Foundation

struct FlickrAPI {
    // it is BAD PRACTICE to put an API key in your code
    // typically you put it in an encrypted file, or in keychain services, or even in your Info.plist (add Info.plist .gitignore file)
    static let apiKey = "1e62fea963ae2caf0854ae1be8fee7fd"
    static let baseURL = "https://api.flickr.com/services/rest"
    
    // the first thing we wanna do is construct or flickr.interestingness.getList url request for data
    static func flickrURL() -> URL {
        // first lets define our query parameters
        let params = [
            "method": "flickr.interestingness.getList",
            "api_key": FlickrAPI.apiKey,
            "format": "json",
            "nojsoncallback": "1", // asks for raw JSON
            "extras": "date_taken,url_h" // url_h is for a 1600px image url for the photo
        ]
        // now we need to get the params into a url with the base ulr
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        var components = URLComponents(string: FlickrAPI.baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
    }
    
    // lets define a function to make the request using the url we just constructed
    // @escaping tells the compiler that this closure executs after the method returns
    static func fetchInterestingPhotos(completion: @escaping ([InterestingPhoto]?) -> Void) {
        let url = FlickrAPI.flickrURL()
        
        // we need to make a request to the Flickr API server using the url
        // we will get back a JSON response (if all goes well)
        // we will make the request on a background thread using a data task
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            // this closure executes later...
            // when the task has received a response from the server
            // we want to grab the Data object that represents the JSON response (if there is one)
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!!")
                print(dataString)
                
                // we want to convert the Data to a JSON object, then the JSON object to a Swift dictionary so we can parse the photos from the array
                // to create [InterestingPhoto]
                // write a method to do this
                if let interestingPhotos = interestingPhotos(fromData: data) {
                    print("we got an [InterestingPhoto] with \(interestingPhotos.count) photos")
                    // our goal is to get this array back to ViewController for displaying in the views
                    // PROBLEMS!!
                    // MARK: - Threads
                    // so far, our code in ViewController (for example) has run on the main UI thread
                    // the main UI thread listens for interactions with views from the user, it calls callbacks in view controllers and delgates, etc.
                    // we don't want to run long running tasks/code on the main UI thread, why?
                    // by default, URLSession dataTasks run on a background thread
                    // that means that this closure we are in right now... runs asynchronously on a background thread
                    // fetchInterestingPhotos() starts the task (that runs in the background), then it immediately returns (we can't return the array then!!)
                    
                    // we need a completion handler (AKA closure) to call code in ViewController when we have a result (success or failure)
                    completion(interestingPhotos)
                    // TODO: should call completion on failure as well
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting data \(error)")
                }
            }
        }
        // by default tasks are created in the suspended state
        // call resume() to start the task
        task.resume()
    }
    
    static func interestingPhotos(fromData data: Data) -> [InterestingPhoto]? {
        // if anything goes wrong, return nil
        
        // MARK: - JSON
        // javascript object notation
        // json is the most commonly used format for passing data around the web
        // it is really just a dictionary
        // keys are strings
        // values are strings, arrays, nested JSON objects, ints, bools, etc.
        // our goal is to convert the data into a swift dictionary [String: Any]
        // libaries (like swiftyJSON) that make this really easy
        // we are gonna do it the long way!
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let photosObject = jsonDictionary["photos"] as? [String: Any], let photoArray = photosObject["photo"] as? [[String: Any]] else {
                print("Error parsing JSON")
                return nil
            }
            // we sucessfully go the array of photos
            print("successfully got photoArray")
            var interestingPhotos = [InterestingPhoto]()
            for photoObject in photoArray {
                // parse a InterestingPhoto from photoObject ([String: Any])
                // write a method to do this
                if let interestingPhoto = interestingPhoto(fromJSON: photoObject) {
                    interestingPhotos.append(interestingPhoto)
                }
            }
            // return the array if it its not empty
            // GS: finished after class
            if !interestingPhotos.isEmpty {
                return interestingPhotos
            }
        }
        catch {
            print("Error converting Data to JSON \(error)")
        }
        
        return nil
    }
    
    static func interestingPhoto(fromJSON json: [String: Any]) -> InterestingPhoto? {
        // task: finish this method
        // we need the id, title, datetaken, url_h
        // GS: finished after class
        guard let id = json["id"] as? String, let title = json["title"] as? String, let dateTaken = json["datetaken"] as? String, let photoURL = json["url_h"] as? String else {
            return nil
        }
        // package up and return an InterestingPhoto
        // GS: finished after class
        return InterestingPhoto(id: id, title: title, dateTaken: dateTaken, photoURL: photoURL)
    }
}

