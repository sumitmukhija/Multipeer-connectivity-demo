//
//  ViewController.swift
//  MultiPeer
//
//  Created by Sumit on 3/22/17.
//  Copyright © 2017 Sumit Mukhija. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ColorManagerHelper {

    let colorServManager = ColorServiceManager()
    
    @IBOutlet weak var connectionsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        colorServManager.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func didChangeColor(color: String) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            switch color {
            case "red":
                self.change(UIColor.redColor())
            case "yellow":
                self.change(UIColor.yellowColor())
            default:
                NSLog("%@", "Unknown color value received: \(color)")
            }
        }
    }

    @IBAction func redTapped(sender: AnyObject) {
        self.change(UIColor.redColor())
        colorServManager.send("red")
    }
    
    @IBAction func yellowTapped(sender: AnyObject) {
        self.change(UIColor.yellowColor())
        colorServManager.send("yellow")
    }
    
    func change(color : UIColor) {
        UIView.animateWithDuration(0.2) { 
            self.view.backgroundColor = color
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

