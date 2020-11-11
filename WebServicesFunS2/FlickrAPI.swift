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
    static func fetchInterestingPhotos() {
        let url = FlickrAPI.flickrURL()
    }
}
