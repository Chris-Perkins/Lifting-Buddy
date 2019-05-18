//
//  UnitPickerViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/25/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class UnitPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    let data: [String] = [Exercise.Unit.DISTANCE.rawValue,
                          Exercise.Unit.TIME.rawValue,
                          Exercise.Unit.WEIGHT.rawValue]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return data[row] as String
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
}
