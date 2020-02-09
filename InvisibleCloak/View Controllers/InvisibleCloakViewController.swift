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
    
    @IBOutlet weak var colorView: UIView!
    
    var colorsToFind = [UIColor]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        OpenCVWrapper.shared().createOpenCVVideoCamera(with: imageView)
        OpenCVWrapper.shared().startVideo()
        
        
        let gradient = CAGradientLayer()
        
        var cgArray = [CGColor]()
        for c in colorsToFind {
            cgArray.append(c.cgColor)
        }
        
        gradient.frame = colorView.bounds
        gradient.colors = cgArray
        
        colorView.layer.insertSublayer(gradient, at: 0)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        OpenCVWrapper.shared().stopVideo()
    }
    
    @IBAction func captureBackground( _ Sender: Any){
        OpenCVWrapper.shared().getBackground()
    }
    
    
    
    @IBAction func switchVideoCamera(){
        OpenCVWrapper.shared()?.switchVideoCamera()
    }
   


}

