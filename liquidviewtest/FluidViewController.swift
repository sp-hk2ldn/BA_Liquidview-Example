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
    let coffeeColour = UIColor(red: 182/255, green: 140/255, blue: 108/255, alpha: 1)
    let milkColour = UIColor(red: 245/255, green: 255/255, blue: 250/255, alpha: 1)
    var milkView: BAFluidView?
    var coffeeView: BAFluidView?
    let maskingImage = UIImage(named: "cupwithouthighlight")!
    let maskingLayer = CALayer()
    var cupInsideImageView: UIImageView?

    
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
            milkView = BAFluidView(frame: maskView.frame, startElevation: 0.5)
            milkView!.fillColor = milkColour
            milkView!.strokeColor = milkColour
            milkView!.fillAutoReverse = false
        }
        milkView!.layer.mask = maskingLayer
        if cupInsideImageView == nil {
            cupInsideImageView = UIImageView(frame: CGRectMake(maskView.frame.origin.x, maskView.frame.origin.y, maskView.frame.size.width, maskView.frame.size.height))
            cupInsideImageView!.image = UIImage(named: "CupInside")!
            self.view.insertSubview(cupInsideImageView!, aboveSubview: maskView)
        }
//        milkView?.backgroundColor = UIColor.whiteColor()
//        milkView?.alpha = 1.0
        self.view.insertSubview(milkView!, aboveSubview: cupInsideImageView!)
    }
    
    override func viewDidAppear(animated: Bool) {
    }


    @IBAction func addCoffeeButton(sender: UIButton) {
//        if coffeeView == nil {
//            coffeeView = BAFluidView(frame: maskView.frame, startElevation: 0)
//            coffeeView?.fillColor = coffeeColour
//            coffeeView?.fillColor = coffeeColour
//            coffeeView?.fillAutoReverse = false
//        }
//        coffeeView!.layer.mask = maskingLayer
//        self.view.insertSubview(coffeeView!, aboveSubview: maskView)
//        coffeeView?.fillTo(0.33)
//        self.cupInsideView.removeFromSuperview()
//        self.view.insertSubview(cupInsideView, atIndex: 1)
        
    }
    
    func configureMask(){
        maskingLayer.frame = CGRectMake(0, 0, maskingImage.size.width, maskingImage.size.height)
        maskingLayer.contents = maskingImage.CGImage
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
