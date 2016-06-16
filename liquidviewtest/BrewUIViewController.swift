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
import DaisyChain
import SwiftyJSON

class BrewUIViewController: UIViewController {
    
    // MARK: UI Variables
    
    @IBOutlet var liquidContainer: UIView!
    @IBOutlet weak var progressBackground: UIImageView!
    @IBOutlet weak var machineAnimationContainer: UIImageView!
    
    let coffeeColour = UIColor(red: 182/255, green: 140/255, blue: 108/255, alpha: 1)
    let milkColour = UIColor(red: 245/255, green: 255/255, blue: 250/255, alpha: 1)
    var milkView: BAFluidView?
    var coffeeView: BAFluidView?
    var manager = CMMotionManager()
    var step:Int = 0
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let aristGold = UIColor(red: 232.0/255.0, green: 198.0/255.0, blue: 98.0/255.0, alpha: 1.0)
    var frame = CGRect()
    var smallFrame = CGRect()
    
    var firstPosition: CGFloat!
    var secondPosition: CGFloat!
    var thirdPosition: CGFloat!
    
    // MARK: API Variables
    var outcomeId: String!
    var userId: String!
    var recipeId: String!
    var brewId: String!

    // Current Brew Progress Settings
    var waterVolume: Float? {
        didSet {
            let finalValue = Float(50)
            if waterVolume > oldValue {
                let percent = (waterVolume! / finalValue) * 100
                UIView.animateWithDuration(0.8, animations: { 
                    self.pumpBar.frame.size.width = self.pumpContainer.frame.size.width * CGFloat(percent)
                })
                if waterVolume == finalValue {
                    UIView.animateWithDuration(0.8, animations: { 
                        self.exitContainer(self.pumpContainer)
                    })
                }
            }
        }
    }
    
    var waterTemp: Float? {
        didSet {
            let finalValue = Float(100)
            if waterTemp > oldValue {
                
                machineBoil()
                
                let percent = (waterTemp! / finalValue)
                UIView.animateWithDuration(0.8, animations: {
                    self.boilBar.frame.size.width = self.boilView.frame.size.width * CGFloat(percent)
                })
                if waterTemp == finalValue {
                    
                    machineAnimationContainer.stopAnimating()
                    
                    UIView.animateWithDuration(0.8, animations: { 
                        self.boilLabel.text = "Water Temperature"
                        self.exitContainer(self.boilView)
                        if self.steamed == false && self.tamped == false {
                            UIView.animateWithDuration(0.8, animations: {
                                self.steamView.frame.origin.y = self.firstPosition
                                self.tampView.frame.origin.y = self.secondPosition
                            })
                        }
                        if self.steamed == true && self.tamped == false {
                            UIView.animateWithDuration(0.8, animations: { 
                                self.tampView.frame.origin.y = self.firstPosition
                            })
                        }
                        self.boiled = true
                    })
                }
            }
        }
    }
    
    var groundWeight: Float? {
        didSet {
            let finalValue = Float(50)
            if groundWeight > oldValue {
                
                let percent = (groundWeight! / finalValue)
                UIView.animateWithDuration(0.8, animations: { 
                    self.grindBar.frame.size.width = self.grindBar.frame.size.width * CGFloat(percent)
                })
                
                if groundWeight == finalValue {
                    machineAnimationContainer.stopAnimating()
                }
            }
            
        }
    }
    var steamTemp: Float?
    var tampStatus: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEST
        brewId = ""
        recipeId = ""
        outcomeId = ""
        userId = ""
        
        setVariables()
        buildLiquidViews()
        
        // In real project, trigger this when brew button is clicked
        startBrewProcess()
        
        // Check brew process every second
        delayExecute(1.0) { 
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(BrewUIViewController.checkBrewProcess), userInfo: nil, repeats: true)
            
            // test
            self.pumpWater()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Brew Communications
    func startBrewProcess() {
        let brewSetting = []
        BrewAPIManager.sharedInstance.startBrew(brewSetting, brewId: brewId, recipeId: recipeId, outcomeId: outcomeId, userId: userId) { (isSuccess, response) in
            if isSuccess {
                print(response)
            }
        }
    }
    
    func checkBrewProcess() {
        BrewAPIManager.sharedInstance.checkBrewProgress(brewId) { (isSuccess, response) in
            if isSuccess {
                let setting = JSON(response)["readings"]
                // self.waterVolume = setting["waterinnet"].floatValue
                self.steamTemp = setting["steamtemp"].floatValue
                self.tampStatus = setting["tamperStatus"].intValue
                
                self.groundWeight = setting["groundweight"].floatValue
                print("groundWeight: \(self.groundWeight)")
                
                self.waterTemp = setting["watertemp"].floatValue
                print("waterTemp: \(self.waterTemp)")
            }
        }
    }
    
    func stopBrewProcess() {
        BrewAPIManager.sharedInstance.stopBrew(self.brewId, completion: { (isSuccess, response) in
            if isSuccess {
                print(response)
            }
        })
    }
    
    // MARK: Setup Builds
    func setVariables() {
        if screenHeight == CGFloat(568) {
            self.frame = CGRectMake(15, screenHeight + 100, screenWidth - 30, 50)
            firstPosition = self.progressBackground.frame.origin.y + 90
            secondPosition = firstPosition + 60
            thirdPosition = secondPosition + 60
        } else {
            self.frame = CGRectMake(20, screenHeight + 100, screenWidth - 40, 64)
            firstPosition = self.progressBackground.frame.origin.y + 120
            secondPosition = firstPosition + 80
            thirdPosition = secondPosition + 80
        }
    }
    
    func buildLiquidViews() {
        manager.accelerometerUpdateInterval = 0.01
        manager.deviceMotionUpdateInterval = 0.01
        
        manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (motion, error) in
            if let motion = motion {
                let rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI
                self.milkView?.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
                self.coffeeView?.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
            }
        }
    }
    
    func buildBarFoundation(view: UIView) -> UIView {
        view.frame = frame
        view.backgroundColor = UIColor.whiteColor()
        let bar = UIView()
        bar.frame = CGRectMake(0, 0, 0, view.frame.size.height)
        bar.backgroundColor = aristGold
        view.alpha = 0.0
        view.insertSubview(bar, atIndex: 0)
        self.view.addSubview(view)
        return bar
    }
    
    func buildProcessLabel(container: UIView) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.blackColor()
        label.frame = CGRectMake(container.frame.origin.x + 67, 0, container.frame.size.width - 167, container.frame.size.height)
        return label
    }
    
    func buildQuantLabel(container: UIView) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(36)
        label.textColor = UIColor.blackColor()
        label.frame = CGRectMake(container.frame.size.width - 100, 0, 100, container.frame.size.height)
        return label
    }
    
    func exitContainer(container: UIView) {
        container.alpha = 0.0
        container.frame.origin.y = self.progressBackground.frame.origin.y - 100
    }
    
    // MARK: UI Animations
    
    // 1
    var pumpContainer = UIView()
    var pumpBar = UIView()
    var pumpLabel = UILabel()
    
    func pumpWater() {
        pumpBar = buildBarFoundation(pumpContainer)
        pumpLabel = buildProcessLabel(pumpContainer)
        pumpLabel.text = "Pumping water..."
        pumpContainer.addSubview(pumpLabel)
        
        if milkView == nil {
            milkView = BAFluidView(frame: liquidContainer.frame, maxAmplitude: 3, minAmplitude: 1, amplitudeIncrement: 1, startElevation: 0)
            milkView!.fillColor = milkColour
            milkView!.strokeColor = milkColour
            milkView!.fillAutoReverse = false
            milkView!.fillRepeatCount = 1
            milkView!.fillTo(0.8)
        }
        self.liquidContainer.addSubview(milkView!)
        
        let pumpChain = DaisyChain()
        UIView.animateWithDuration(0.8) {
            self.pumpContainer.alpha = 1.0
            self.pumpContainer.frame.origin.y = self.firstPosition
        }
        pumpChain.animateWithDuration(2.0) {
            self.milkView!.startAnimation()
            self.pumpBar.frame.size.width = self.pumpContainer.frame.size.width
        }
        pumpChain.animateWithDuration(1.0, animations: {
            self.pumpLabel.text = "Water Volume"
            self.exitContainer(self.pumpContainer)
        }) { (isDone) in
            if isDone {
                self.grindBeans()
            }
        }
    }
    
    // 2
    var boiled: Bool = false
    var steamed: Bool = false
    var tamped: Bool = false

    let grindView = UIView()
    var grindBar = UIView()
    var grindLabel = UILabel()
    
    func grindBeans() {
        let container = grindView
        grindBar = buildBarFoundation(grindView)
        grindLabel = buildProcessLabel(grindView)
        grindLabel.text = "Grinding beans..."
        container.addSubview(grindLabel)
        
        let grindChain = DaisyChain()
        grindChain.animateWithDuration(0.8, animations: {
            container.alpha = 1.0
            container.frame.origin.y = self.firstPosition
        }) { (isDone) in
            if isDone {
                self.boilWater()
            }
        }
//        grindChain.animateWithDuration(3.0) {
//            bar.frame.size.width = container.frame.size.width
//        }
//        grindChain.animateWithDuration(1.0, animations: {
//            label.text = "Ground Weight"
//            self.exitContainer(container)
//            if self.boiled == false && self.steamed == false {
//                UIView.animateWithDuration(0.8, animations: { 
//                    self.boilView.frame.origin.y = self.firstPosition
//                    self.steamView.frame.origin.y = self.secondPosition
//                })
//            }
//            
//        }) { (isDone) in
//            if isDone {
//                self.tampBeans()
//            }
//        }
    }
    
    var boilView = UIView()
    var boilBar = UIView()
    var boilLabel = UILabel()
    
    func boilWater(){
        let container = boilView
        
        boilBar = buildBarFoundation(boilView)
        boilLabel = buildProcessLabel(boilView)
        
        boilLabel.text = "Boiling water..."
        container.addSubview(boilLabel)
        
        let boilChain = DaisyChain()
        boilChain.animateWithDuration(0.8, animations: {
            container.alpha = 1.0
            container.frame.origin.y = self.secondPosition
        }) { (isDone) in
            if isDone {
                self.steamMilk()
            }
        }
//        boilChain.animateWithDuration(5.0) {
//            bar.frame.size.width = container.frame.size.width
//        }
//        boilChain.animateWithDuration(1.0, animations: {
//            label.text = "Water Temperature"
//            self.exitContainer(container)
//            if self.steamed == false && self.tamped == false {
//                UIView.animateWithDuration(0.8, animations: { 
//                    self.steamView.frame.origin.y = self.firstPosition
//                    self.tampView.frame.origin.y = self.secondPosition
//                })
//            }
//            if self.steamed == true && self.tamped == false {
//                UIView.animateWithDuration(0.8, animations: { 
//                    self.tampView.frame.origin.y = self.firstPosition
//                })
//            }
//        }) { (isDone) in
//            if isDone {
//                self.boiled = true
//            }
//        }
    }
    
    let steamView = UIView()
    func steamMilk() {
        let container = steamView
        let bar = buildBarFoundation(steamView)
        let label = buildProcessLabel(steamView)
        label.text = "Steaming milk..."
        container.addSubview(label)
        
        let steamChain = DaisyChain()
        steamChain.animateWithDuration(0.8) {
            container.alpha = 1.0
            container.frame.origin.y = self.thirdPosition
        }
        steamChain.animateWithDuration(3.0) {
            bar.frame.size.width = container.frame.size.width
        }
        steamChain.animateWithDuration(1.0, animations: {
            label.text = "Milk Temperature"
            self.exitContainer(container)
            if self.tamped == false && self.boiled == false {
                UIView.animateWithDuration(0.8, animations: {
                    self.tampView.frame.origin.y = self.secondPosition
                })
            }
            if self.tamped == false && self.boiled == true {
                UIView.animateWithDuration(0.8, animations: { 
                    self.tampView.frame.origin.y = self.firstPosition
                })
            }
        }) { (isDone) in
            if isDone {
                self.steamed = true
            }
        }
    }
    
    // 2.5 (tamp shows after grind is complete)
    let tampView = UIView()
    func tampBeans() {
        let container = tampView
        let bar = buildBarFoundation(tampView)
        let label = buildProcessLabel(tampView)
        label.text = "Tamping..."
        container.addSubview(label)
        
        let tampChain = DaisyChain()
        tampChain.animateWithDuration(0.8) {
            container.alpha = 1.0
            if self.boiled == true && self.steamed == true {
                container.frame.origin.y = self.firstPosition
            } else if self.boiled == true && self.steamed == false {
                container.frame.origin.y = self.secondPosition
            } else if self.boiled == false && self.steamed == true {
                container.frame.origin.y = self.secondPosition
            } else if self.boiled == false && self.steamed == false {
                container.frame.origin.y = self.thirdPosition
            }
        }
        tampChain.animateWithDuration(8.0) {
            bar.frame.size.width = container.frame.size.width
        }
        
        tampChain.animateWithDuration(1.0, animations: {
            label.text = "Grounds"
            self.exitContainer(container)
        }) { (isDone) in
            if isDone {
                self.tamped = true
            }
        }
        
    }
    
    // 3
    let extractView = UIView()
    func extractCoffee() {
        let container = extractView
        let bar = buildBarFoundation(extractView)
        let label = buildProcessLabel(extractView)
        label.text = "Brewing..."
        container.addSubview(label)
        
        if coffeeView == nil {
            coffeeView = BAFluidView(frame: liquidContainer.frame, maxAmplitude: 3, minAmplitude: 1, amplitudeIncrement: 1, startElevation: 0)
            coffeeView!.fillColor = coffeeColour
            coffeeView!.strokeColor = coffeeColour
            coffeeView!.fillAutoReverse = false
            coffeeView!.fillRepeatCount = 1
            coffeeView!.fillTo(0.6)
        }
        self.liquidContainer.insertSubview(coffeeView!, aboveSubview: milkView!)
        
        let extractChain = DaisyChain()
        extractChain.animateWithDuration(0.8) {
            container.alpha = 1.0
            container.frame.origin.y = self.firstPosition
        }
        let duration = 5.0
        extractChain.animateWithDuration(duration) {
            self.coffeeView!.fillDuration = duration
            self.coffeeView!.startAnimation()
            bar.frame.size.width = container.frame.size.width
        }
        extractChain.animateWithDuration(1.0) {
            label.text = "Extraction Time"
            self.exitContainer(container)
            
            // Test stop brew
            self.stopBrewProcess()
        }
    }
    
    // MARK: - Machine Animations
    func machineBoil() {
        let initialImage = UIImage(named: "Boiling_00000")
        machineAnimationContainer.image = initialImage
        machineAnimationContainer.animationImages = getBoilImageSequences()
        machineAnimationContainer.animationDuration = 8.0
        machineAnimationContainer.startAnimating()
    }
    
    func getBoilImageSequences() -> [UIImage] {
        var array = [UIImage]()
        for index in 0...99 {
            let intInStr = String(format: "%02d", index)
            array.append(UIImage(named: "Boiling_000\(intInStr)")!)
        }
        return array
    }
    
}


func delayExecute(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

