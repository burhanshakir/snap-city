//
//  DroppablePin.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 21/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate : CLLocationCoordinate2D, identifier: String){
        self.coordinate = coordinate
        self.identifier = identifier
       
        super.init()
        
    }

    
    

}
