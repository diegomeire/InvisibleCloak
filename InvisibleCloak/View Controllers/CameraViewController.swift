//
//  CameraViewController.swift
//  InvisibleCloak
//
//  Created by Diego Meire on 12/08/19.
//  Copyright © 2019 Diege Miere. All rights reserved.
//

import Foundation


class CameraViewController : UIViewController, OpenCVWrapperDelegate{
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var color01Button: UIButton!
    @IBOutlet weak var color02Button: UIButton!
    @IBOutlet weak var color03Button: UIButton!
    @IBOutlet weak var color04Button: UIButton!
    @IBOutlet weak var color05Button: UIButton!
    @IBOutlet weak var color06Button: UIButton!
    @IBOutlet weak var color07Button: UIButton!
    
    @IBOutlet weak var parametersStackView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var captureColorsButton: UIButton!
    
    var color01 = UIColor()
    var color02 = UIColor()
    var color03 = UIColor()
    var color04 = UIColor()
    var color05 = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        color01 = color01Button.backgroundColor!
        color02 = color02Button.backgroundColor!
        color03 = color03Button.backgroundColor!
        color04 = color04Button.backgroundColor!
        color05 = color05Button.backgroundColor!
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        parametersStackView.isHidden = true
        nextButton.isHidden = true
        captureColorsButton.isHidden = false
        
        OpenCVWrapper.shared()?.createOpenCVPhotoCamera(with: imageView)
        OpenCVWrapper.shared()?.delegate = self
        OpenCVWrapper.shared()?.startPhoto()
        
        OpenCVWrapper.shared()?.switchPhotoCamera()
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        OpenCVWrapper.shared()?.stopPhoto()
    }
    
    
    
    @IBAction func getColor( _ sender: AnyObject){
        
        OpenCVWrapper.shared()?.numberOfMeanColors = 7 
        OpenCVWrapper.shared()?.takePicture()
    }
    
    @IBAction func colorTouched(){
        nextButton.isHidden = false
    }
    
    
    @IBAction func clearColors(){
        
        color01Button.backgroundColor = color01
        color02Button.backgroundColor = color02
        color03Button.backgroundColor = color03
        color04Button.backgroundColor = color04
        color05Button.backgroundColor = color05
        
        parametersStackView.isHidden = true
        nextButton.isHidden = true
        captureColorsButton.isHidden = false
    }
    
    @IBAction func switchPhotoCamera(){
        OpenCVWrapper.shared()?.switchPhotoCamera()
    }
    
    func getAbsoluteHueFrom( color: UIColor ) -> UIColor{
        
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alp: CGFloat = 0
        color.getHue(&hue,
                     saturation: &sat,
                     brightness: &bri,
                     alpha: &alp)
        
        return UIColor(hue: hue, saturation: 255, brightness: 255, alpha: 255)
        
    }
    
    func pictureTaken(withColors colors: [Any]!) {
        
        color01Button.backgroundColor = (colors[0] as! UIColor)
        color02Button.backgroundColor = (colors[1] as! UIColor)
        color03Button.backgroundColor = (colors[2] as! UIColor)
        color04Button.backgroundColor = (colors[3] as! UIColor)
        color05Button.backgroundColor = (colors[4] as! UIColor)
        color06Button.backgroundColor = (colors[5] as! UIColor)
        color07Button.backgroundColor = (colors[6] as! UIColor)
        
        parametersStackView.isHidden = false
        nextButton.isHidden = true
        captureColorsButton.isHidden = true
        
    }
    
    ///
    func showAlert( _ message: String ){
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              switch action.style{
              case .default:
                    print("default")

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")
              @unknown default:
                fatalError()
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if identifier == "InvisibleCloak" {
            
            if (!color01Button.isSelected) &&
               (!color02Button.isSelected) &&
               (!color03Button.isSelected) &&
               (!color04Button.isSelected) &&
               (!color05Button.isSelected) &&
               (!color06Button.isSelected) &&
               (!color07Button.isSelected){
                showAlert( "You must select at least one color to segment")
                return false
            }
            else{
                return true
            }
        }
        else{
            return true
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "InvisibleCloak" {
            
            OpenCVWrapper.shared()?.stopPhoto()
            
            ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.removeAll()
            OpenCVWrapper.shared()?.clearColorsToFind()
            
            OpenCVWrapper.shared()?.fullColorRange = true//switchFullRange.isOn
            
            if color01Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color01Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color01Button.backgroundColor!)
            }
            if color02Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color02Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color02Button.backgroundColor!)
            }
            if color03Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color03Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color03Button.backgroundColor!)
            }
            if color04Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color04Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color04Button.backgroundColor!)
            }
            if color05Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color05Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color05Button.backgroundColor!)
            }
            if color06Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color06Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color06Button.backgroundColor!)
            }
            if color07Button.isSelected {
                OpenCVWrapper.shared()?.addColor( toFind: color07Button.backgroundColor! )
                ( segue.destination as? InvisibleCloakViewController )?.colorsToFind.append(color07Button.backgroundColor!)
            }
        }
    }
    
    
    
}
