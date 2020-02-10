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
    
    @IBOutlet weak var sliderMinBrightness: UISlider!
    @IBOutlet weak var sliderMaxBrightness: UISlider!
    
    @IBOutlet weak var sliderMinSaturation: UISlider!
    @IBOutlet weak var sliderMaxSaturation: UISlider!
    
    var colorsToFind = [UIColor]()
    
    
    @objc func sliderChanged( sender: UISlider ){
        switch sender.tag {
        case 0:
            OpenCVWrapper.shared()?.minBrightness = CGFloat(sender.value)
        case 1:
            OpenCVWrapper.shared()?.maxBrightness = CGFloat(sender.value)
        case 2:
             OpenCVWrapper.shared()?.minSaturation = CGFloat(sender.value)
        case 3:
             OpenCVWrapper.shared()?.maxSaturation = CGFloat(sender.value)
        default:
             print("default")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderMinBrightness.addTarget(self, action: #selector(sliderChanged), for: UIControl.Event.valueChanged)
        sliderMaxBrightness.addTarget(self, action: #selector(sliderChanged), for: UIControl.Event.valueChanged)
        sliderMinSaturation.addTarget(self, action: #selector(sliderChanged), for: UIControl.Event.valueChanged)
        sliderMaxSaturation.addTarget(self, action: #selector(sliderChanged), for: UIControl.Event.valueChanged)
        
        sliderMinBrightness.value = 50
        OpenCVWrapper.shared()?.minBrightness = CGFloat(sliderMinBrightness.value)
        sliderMaxBrightness.value = 255
        OpenCVWrapper.shared()?.maxBrightness = CGFloat(sliderMaxBrightness.value)
        sliderMinSaturation.value = 50
        OpenCVWrapper.shared()?.minSaturation = CGFloat(sliderMinSaturation.value)
        sliderMaxSaturation.value = 255
        OpenCVWrapper.shared()?.maxSaturation = CGFloat(sliderMaxSaturation.value)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        OpenCVWrapper.shared().createOpenCVVideoCamera(with: imageView)
        OpenCVWrapper.shared().startVideo()
        
        
       
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

