//
//  Constants.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 21/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import Foundation

let api_key = "f72130c4196a687374832f3313b69c03"

func flickrUrl(forApiKey key: String, withAnnotation annotation : DroppablePin, andNumberOfPhotos number: Int) -> String{
    
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(api_key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
}


func flickrImageDataUrl(forApiKey key: String, andId id: String) -> String{
    
    return "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(api_key)&photo_id=\(id)&format=json&nojsoncallback=1"
}




