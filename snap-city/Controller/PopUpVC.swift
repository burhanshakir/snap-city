//
//  PopUpVC.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 22/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import UIKit
import Alamofire

class PopUpVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imageDataView: UIView!
    
    var image:UIImage!
    var imageDescription : FlickrImage!
    
    var desc:String = ""
    var datePosted:String = ""
    
    var isDataHidden:Bool = true
    
    func initData(forImage image:UIImage , andData data : FlickrImage){
        self.image = image
        self.imageDescription = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popImageView.image = image
        imageDataView.isHidden = true
        
        addDoubleTap()
        addSingleTap()
        
        getImageDescription { (true) in
            self.titleLbl.text = self.imageDescription.description
            self.descLbl.text = self.desc
            self.dateLbl.text = "Posted: \(self.datePosted)"
            
        }

        // Do any additional setup after loading the view.
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissScreen))
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
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
            
            handler(true)
            
            
        }
        
        
        
        
        
    }
    

}
