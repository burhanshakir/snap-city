//
//  ViewController.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 19/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    var screenSize = UIScreen.main.bounds
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius:Double = 1000
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView?
    
    var imagesArray = [FlickrImage]()
    var downloadedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        setUpCollectionView()
        
        registerForPreviewing(with: self, sourceView: collectionView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locationBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
    func setUpCollectionView(){
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
        
    }
    
    func addDoubleTap(){
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe(){
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        pullUpViewHeightConstraint.constant = 300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
     }
    
    @objc func animateViewDown(){
        
        cancelSessions()
        pullUpViewHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width/2) - ((spinner?.frame.width)!/2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width/2) - 120, y: 175, width: 240, height: 40)
        
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl(){
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
    }

}

extension MapVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        pinAnnotation.animatesDrop = true
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        
        return pinAnnotation
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender : UITapGestureRecognizer){
        
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelSessions()
        
        downloadedImages = []
        imagesArray = []
        
        self.collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "pin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveImagesURL(forAnnotation: annotation) { (finished) in
            if finished{
                self.retrieveImage(handler: { (finished) in
                    if finished{
                        self.removeSpinner()
                        self.removeProgressLbl()

                        self.collectionView?.reloadData()


                    }
                })
            }
        }
     
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveImagesURL(forAnnotation annotation: DroppablePin, handler:@escaping (_ status : Bool) -> ()){
        
        
        Alamofire.request(flickrUrl(forApiKey: api_key, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String,AnyObject> else {return}
            
            print(json)
            
            let photoDict = json["photos"] as! Dictionary<String,AnyObject>
            
            let photoDictArray = photoDict["photo"] as! [Dictionary<String,AnyObject>]
            
            for photo in photoDictArray{
                
                let postURL = "https://farm\(photo["farm"]!).static.flickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                
                let flickrImage = FlickrImage(url: postURL, description: photo["title"] as! String, id: photo["id"]! as! String)
                
                self.imagesArray.append(flickrImage)
            }
            
            handler(true)
            
        }
    }
    
    func retrieveImage(handler:@escaping (_ status : Bool) -> ()){
        
        for image in imagesArray{
            Alamofire.request(image.url).responseImage(completionHandler: { (response) in
                
                guard let image = response.result.value else
                {
                    return
                    
                }
                self.downloadedImages.append(image)
                
                self.progressLbl?.text = "\(self.downloadedImages.count)/40 images downloaded"
                
                if self.downloadedImages.count == self.imagesArray.count{
                    handler(true)
                }
            })
        }
        
        
    }
    
    // Cancel all background sessions when user closes collection view
    
    func cancelSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sesionDataTask, uploadDataTask, downloadDataTask) in
            
            sesionDataTask.forEach({ $0.cancel() })
            downloadDataTask.forEach({ $0.cancel() })
        }
    }
    
}

extension MapVC : CLLocationManagerDelegate{
    func configureLocationServices(){
        
        if authorizationStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        else{
            return
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


extension MapVC : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.downloadedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        
        let image = UIImageView(image: downloadedImages[indexPath.row])
        cell.addSubview(image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as? PopUpVC else { return }
        popVC.initData(forImage: downloadedImages[indexPath.row], andData: imagesArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
        
    }
    
}
// Adding 3D touch to preview the image before scaling it
extension MapVC: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as? PopUpVC else { return nil }
        popVC.initData(forImage: downloadedImages[indexPath.row], andData: imagesArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
    }
    
    
    
    
}



