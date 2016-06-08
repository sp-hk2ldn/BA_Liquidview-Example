//
//  BrewUIViewController.swift
//  liquidviewtest
//
//  Created by Songyee Park on 7/6/2016.
//  Copyright © 2016 nbition. All rights reserved.
//

import UIKit
import BAFluidView
import CoreMotion

class BrewUIViewController: UIViewController {
    
    @IBOutlet var liquidContainer: UIView!
    
    let coffeeColour = UIColor(red: 182/255, green: 140/255, blue: 108/255, alpha: 1)
    let milkColour = UIColor(red: 245/255, green: 255/255, blue: 250/255, alpha: 1)
    
    var milkView: BAFluidView?
    var coffeeView: BAFluidView?
    
    var manager = CMMotionManager()
    var step:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.accelerometerUpdateInterval = 0.01
        manager.deviceMotionUpdateInterval = 0.01
        
        manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (motion, error) in
            if let motion = motion {
                let rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI
                self.milkView?.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
                self.coffeeView?.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            }
        }
        
        if milkView == nil {
            milkView = BAFluidView(frame: liquidContainer.frame, maxAmplitude: 3, minAmplitude: 1, amplitudeIncrement: 1, startElevation: 0)
    
            milkView!.fillColor = milkColour
            milkView!.strokeColor = milkColour
            milkView!.fillAutoReverse = false
            milkView!.fillDuration = 4
            milkView!.fillRepeatCount = 1
            milkView!.fillTo(0.8)
        }
        
        self.liquidContainer.addSubview(milkView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        milkView!.startAnimation()
    }
    
    @IBAction func addCoffee(sender: UIButton) {
        if step == 2 { step = 1 }
        switch step {
        case 0:
            if coffeeView == nil {
                coffeeView = BAFluidView(frame: liquidContainer.frame, maxAmplitude: 3, minAmplitude: 1, amplitudeIncrement: 1, startElevation: 0)
                coffeeView!.fillColor = coffeeColour
                coffeeView!.strokeColor = coffeeColour
                coffeeView!.fillAutoReverse = false
                coffeeView!.fillRepeatCount = 1
                coffeeView!.fillTo(0.6)
                coffeeView!.fillDuration = 1
            }
            self.liquidContainer.insertSubview(coffeeView!, aboveSubview: milkView!)
            
        case 1:
            coffeeView!.startAnimation()
            
        default: break
        }
        step += 1
    }
    
}
