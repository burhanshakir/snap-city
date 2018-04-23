//
//  PopUpVC.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 22/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class PopUpVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imageDataView: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var shareView: UIView!
    
    
    var image:UIImage!
    var imageDescription : FlickrImage!
    
    var desc:String = ""
    var datePosted:String = ""
    var lat:String = ""
    var long:String = ""
    
    var isDataHidden:Bool = true
    
    func initData(forImage image:UIImage , andData data : FlickrImage){
        self.image = image
        self.imageDescription = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popImageView.image = image
        imageDataView.isHidden = true
        navView.isHidden = true
        shareView.isHidden = true
        
        addSwipe()
        addSingleTap()
        
        getImageDescription { (true) in
            self.titleLbl.text = self.imageDescription.description
            self.descLbl.text = self.desc
            self.dateLbl.text = "Posted: \(getDate(dt: self.datePosted))"
            
        }

        // Do any additional setup after loading the view.
    }
    
    func addSwipe(){
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissScreen))
        swipe.direction = .down
        
        view.addGestureRecognizer(swipe)
    }
    
    @objc func dismissScreen(){
        dismiss(animated: true, completion: nil)
    }
    
    func addSingleTap(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(showOrHideData))
        
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
    }
    
    @objc func showOrHideData(){
        
        if isDataHidden{
            popImageView.alpha = 0.3
        }
        else{
            popImageView.alpha = 1
        }
        
        isDataHidden = !isDataHidden
        
        imageDataView.isHidden = isDataHidden
        navView.isHidden = isDataHidden
        shareView.isHidden = isDataHidden
      
    }
    
    
    @IBAction func navBtnPressed(_ sender: Any) {
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((lat as NSString).doubleValue), longitude: Double((long as NSString).doubleValue))

        
        let coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = "Destination/Target Address or Name"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
        
    }
    
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    func getImageDescription(handler:@escaping (_ status : Bool) -> ()){
        
        Alamofire.request(flickrImageDataUrl(forApiKey: api_key, andId: imageDescription.id)).responseJSON { (response) in
            
            guard let result = response.result.value as? Dictionary<String,AnyObject> else {return}
            
            let json = result["photo"] as? Dictionary<String,AnyObject>
            
            print(result)
            
            
            let descriptionDict = json!["description"] as! Dictionary<String,AnyObject>
            self.desc = (descriptionDict["_content"] as? String)!
            
            let datesDict = json!["dates"] as! Dictionary<String,AnyObject>
            self.datePosted = (datesDict["posted"] as? String)!
            
            let latDict = json!["location"] as! Dictionary<String,AnyObject>
            self.lat = (latDict["latitude"] as? String)!
            
            let longDict = json!["location"] as! Dictionary<String,AnyObject>
            self.long = (longDict["longitude"] as? String)!
            
            handler(true)
            
            
        }
        
        
        
        
        
    }
    

}
