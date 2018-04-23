//
//  FlickrService.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 23/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class FlickrService{
    
    static let instance = FlickrService()
    
    var imageURLArray = [FlickrImage]()
    var imageArray = [UIImage]()
    
    
    func retrieveImagesURL(forAnnotation annotation: DroppablePin, handler:@escaping (_ status : Bool) -> ()){
        
        
        Alamofire.request(flickrUrl(forApiKey: api_key, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String,AnyObject> else {return}
            
            print(json)
            
            let photoDict = json["photos"] as! Dictionary<String,AnyObject>
            
            let photoDictArray = photoDict["photo"] as! [Dictionary<String,AnyObject>]
            
            for photo in photoDictArray{
                
                let postURL = "https://farm\(photo["farm"]!).static.flickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                
                let flickrImage = FlickrImage(url: postURL, description: photo["title"] as! String, id: photo["id"]! as! String)
                
                self.imageURLArray.append(flickrImage)
            }
            
            handler(true)
            
        }
    }
    
    func retrieveImage(handler:@escaping (_ status : Bool) -> ()){
        
        for images in imageURLArray{
            Alamofire.request(images.url).responseImage(completionHandler: { (response) in
                
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                
//                self.progressLbl?.text = "\(self.imageArray.count)/40 images downloaded"
                
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIF_IMAGE_LOADED), object: nil)
                
                if self.imageArray.count == self.imageURLArray.count{
                    handler(true)
                }
            })
        }
        
        
    }
    
    
}


