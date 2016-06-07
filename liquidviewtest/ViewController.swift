//
//  ViewController.swift
//  liquidviewtest
//
//  Created by Stephen Parker on 06/06/2016.
//  Copyright © 2016 nbition. All rights reserved.
//

import UIKit
import BAFluidView

class ViewController: UIViewController {

    @IBOutlet var meterContainerView: UIView!
    let milkColour = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    let coffeeColour = UIColor(red: 182/255, green: 140/255, blue: 57/255, alpha: 1.0)
    var milkView: BAFluidView?
    var coffeeView: BAFluidView?
    var step: Int = 0
    
    @IBOutlet var highlightView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
    }
    
    @IBAction func button(sender: UIButton) {
        if step == 1 {
            let fillTo = CGFloat(30 / 100.0)
            coffeeView?.fillTo(fillTo > 1 ? 1 : fillTo)
            step = step + 1
        }
        if coffeeView == nil {
            let width = meterContainerView.frame.size.width
            coffeeView = BAFluidView(frame: CGRect(x: 0, y: 0, width: width, height: width), maxAmplitude: 40, minAmplitude: 8, amplitudeIncrement: 1)
            coffeeView!.backgroundColor = .clearColor()
            coffeeView!.fillColor = coffeeColour
            coffeeView!.fillAutoReverse = false
            coffeeView?.fillDuration = 1.5
            coffeeView?.fillRepeatCount = 0
            coffeeView?.strokeColor = coffeeColour
            meterContainerView.insertSubview(coffeeView!, belowSubview: imageView)
            step = step + 1
        }
    }
    
    var moved: Bool = false
    override func viewWillAppear(animated: Bool) {
        if milkView == nil {
            let width = meterContainerView.frame.size.width
            milkView = BAFluidView(frame: CGRect(x: 0, y: 0, width: width, height: width), maxAmplitude: 40, minAmplitude: 8, amplitudeIncrement: 1)
            milkView!.backgroundColor = .clearColor()
            milkView!.fillColor = milkColour
            milkView!.fillAutoReverse = false
            milkView!.fillDuration = 1.5
            milkView!.fillRepeatCount = 0;
            milkView?.strokeColor = milkColour
            meterContainerView.insertSubview(milkView!, belowSubview: imageView)
            updateUI()
        }
    }
    
    func updateUI() {
//        let percentage = EntryHandler.sharedHandler.currentPercentage()
//        percentageLabel.countFromCurrentValueTo(Float(round(percentage)))
        let fillTo = CGFloat(70 / 100.0)
        milkView?.fillTo(fillTo > 1 ? 1 : fillTo)
    }

}

