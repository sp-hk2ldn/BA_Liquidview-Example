//
//  FluidViewController.swift
//  liquidviewtest
//
//  Created by Stephen Parker on 06/06/2016.
//  Copyright © 2016 nbition. All rights reserved.
//

import UIKit
import BAFluidView

class FluidViewController: UIViewController {
    @IBOutlet var maskView: UIView!
    var coffeeColour = UIColor(red: 182/255, green: 140/255, blue: 108/255, alpha: 1)
    let milkColour = UIColor(red: 245/255, green: 255/255, blue: 250/255, alpha: 1)
    var milkView: BAFluidView?
    var coffeeView: BAFluidView?
    let milkMaskingImage = UIImage(named: "maskShape")!
    let milkMaskingLayer = CALayer()
    let coffeeMaskingImage = UIImage(named: "maskShape")!
    let coffeeMaskingLayer = CALayer()
    var cupInsideImageView: UIImageView?
    var step:Int = 0
    

    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        configureMask()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if milkView == nil {
            milkView = BAFluidView(frame: maskView.frame, maxAmplitude: 3, minAmplitude: 1, amplitudeIncrement: 1, startElevation: 0.5)
            milkView!.fillColor = milkColour
            milkView!.strokeColor = milkColour
            milkView!.fillAutoReverse = false
            milkView!.fillRepeatCount = 1
        }
        milkView!.layer.mask = milkMaskingLayer
        if cupInsideImageView == nil {
            cupInsideImageView = UIImageView(frame: CGRectMake(maskView.frame.origin.x, maskView.frame.origin.y, maskView.frame.size.width, maskView.frame.size.height))
            cupInsideImageView!.image = UIImage(named: "CupInside")!
            self.view.insertSubview(cupInsideImageView!, aboveSubview: maskView)
        }
        self.view.insertSubview(milkView!, aboveSubview: cupInsideImageView!)
    }
    
    override func viewDidAppear(animated: Bool) {
    }


    @IBAction func addCoffeeButton(sender: UIButton) {
        if step == 3 { step = 1 }
        switch step {
        case 0:
            if coffeeView == nil {
                coffeeView = BAFluidView(frame: maskView.frame, maxAmplitude: 3, minAmplitude: 1, amplitudeIncrement: 1, startElevation: 0.1)
                coffeeView!.fillColor = coffeeColour
                coffeeView!.strokeColor = coffeeColour
                coffeeView!.fillAutoReverse = false
                coffeeView!.fillRepeatCount = 1
            }
            
            coffeeView!.layer.mask = coffeeMaskingLayer
            self.view.insertSubview(coffeeView!, aboveSubview: cupInsideImageView!)
        case 1:
            coffeeView!.fillDuration = 3.0
            milkView!.fillDuration = 3.0
            coffeeView!.fillTo(0.6)
            milkView!.fillTo(0.9)
            milkView!.startAnimation()
            coffeeView!.startAnimation()
        default: break
        }
        step += 1
        
    }
    
    func configureMask(){
        milkMaskingLayer.frame = CGRectMake(0, 0, milkMaskingImage.size.width, milkMaskingImage.size.height)
        milkMaskingLayer.contents = milkMaskingImage.CGImage
        coffeeMaskingLayer.frame = CGRectMake(0, 0, coffeeMaskingImage.size.width, coffeeMaskingImage.size.height)
        coffeeMaskingLayer.contents = coffeeMaskingImage.CGImage
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
