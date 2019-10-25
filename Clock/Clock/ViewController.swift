//
//  ViewController.swift
//  Clock
//
//  Created by R on 25.10.2019.
//  Copyright © 2019 R. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var clockView: ClockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Start clock with specified time
        clockView.start(time: Date(timeIntervalSinceNow: -60 * 60)) // 1 hour before
        */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.clockView.borderColor = .clear
            self.clockView.secondHandColor = .green
        }
    }

}

