//
//  PopUpVC.swift
//  snap-city
//
//  Created by Burhanuddin Shakir on 22/04/18.
//  Copyright © 2018 COMP47390-41550. All rights reserved.
//

import UIKit

class PopUpVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var image:UIImage!
    
    func initData(forImage image:UIImage){
        self.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popImageView.image = image
        addDoubleTap()

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


}
