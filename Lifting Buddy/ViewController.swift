//
//  ViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var startWorkoutButton: PrettyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayOfTheWeekLabel.numberOfLines = 1
        let date: NSDate = NSDate()
        dayOfTheWeekLabel.text = date.dayOfTheWeek()
        dayOfTheWeekLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startWorkoutButtonTouch(_ sender: PrettyButton) {
        sender.buttonPressed()
    }


}

extension NSDate {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
}
