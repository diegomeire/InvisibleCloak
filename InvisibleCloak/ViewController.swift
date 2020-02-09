//
//  ViewController.swift
//  InvisibleCloak
//
//  Created by Diego Meire on 31/07/19.
//  Copyright © 2019 Diege Miere. All rights reserved.
//

import UIKit

class InvisibleCloakViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        OpenCVWrapper.shared().hue = 50;
        OpenCVWrapper.shared().createOpenCVCamera(with: imageView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        OpenCVWrapper.shared().start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        OpenCVWrapper.shared().stop()
    }
    
    @IBAction func captureBackground( _ Sender: Any){
        
        OpenCVWrapper.shared().getBackground()
        
    }


}

