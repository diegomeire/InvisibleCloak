//
//  UICheckbox.swift
//  ColorAnalysis
//
//  Created by Diego Meire on 30/07/19.
//  Copyright © 2019 Diege Miere. All rights reserved.
//

import Foundation


class UICheckbox : UIButton{
    
    override func awakeFromNib() {
        
        self.setTitle("X", for: .selected)
        self.setTitle(" ", for: .normal)
        
        self.addTarget(self,
                       action: #selector(buttonClicked(_:)),
                       for: .touchUpInside)
        
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        self.isSelected = !self.isSelected
    }
    
}
