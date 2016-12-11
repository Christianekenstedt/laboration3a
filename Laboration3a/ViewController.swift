//
//  ViewController.swift
//  Laboration3a
//
//  Created by Christian Ekenstedt on 2016-12-01.
//  Copyright © 2016 Christian Ekenstedt. All rights reserved.
//

import UIKit
import CoreMotion

struct SpaceData {
    var x : Double
    var y : Double
    var z : Double
}

enum Filter: Double {
    case LOWPASS = 0.99
    case CUSTOMPASS = 0.9
    case HIGHPASS = 0.1
}

class ViewController: UIViewController {
    var motionManager : CMMotionManager!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    var filterdData = SpaceData(x: 0.0, y: 0.0, z: 0.0) //???????
    var oldFilterdData = SpaceData(x: 0.0, y: 0.0, z: 0.0)
    
    var mLinearAcceleration = SpaceData(x: 0.0, y: 0.0, z: 0.0)
    
    
    var SHAKE_THRESHOLD: Double = 1.0
    var ACC_THRESHOLD: Double = 2
    
    var startTime = 0.0
    var lastShake = 0.0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
        motionManager = CMMotionManager()
        
        if motionManager.isDeviceMotionAvailable{
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data:CMAccelerometerData?, err:Error?) in
                if let accData = data?.acceleration{
                    
                    
                    let xAngle = atan( accData.x / (sqrt((accData.y*accData.y) + (accData.z*accData.z))))
                    let yAngle = atan( accData.y / (sqrt((accData.x*accData.x) + (accData.z*accData.z))))
                    let zAngle = atan( sqrt((accData.x*accData.x) + (accData.y*accData.y)) / accData.z)
                    
                    self.filterRawData(rawData: SpaceData(x: xAngle, y: yAngle, z: zAngle), filterFactor: .CUSTOMPASS)
                    self.checkIfShaked()
                    
                    let dataToDisplay = self.radToDeg(dataTo: SpaceData(x: self.filterdData.x, y: self.filterdData.y, z: self.filterdData.z))
                    
                    self.updateAccelerometerLabels(data: dataToDisplay)
                    
                }
            })
        }
    }
    
    func checkIfShaked(){
        
        let resulutant = getMaxCurrentLinearAcceleration()
        if resulutant > SHAKE_THRESHOLD { // Kolla om skakning
            let now = Date().timeIntervalSince1970
            
            if startTime == 0 {
                startTime = now // Skakning börjad
                lastShake = now
            }
            
            let elapsed = now - lastShake
            if elapsed < 1 {
                lastShake = now
                count = count + 1
                
                if count > 3{
                    var totalElapsed = now - startTime
                    if totalElapsed > 1 {
                        // ändra färg
                        xLabel.textColor = randomColor()
                        yLabel.textColor = randomColor()
                        zLabel.textColor = randomColor()
                        reset()
                    }
                }
            }else{
                reset()
            }
        }
    }
    func reset(){
        startTime = 0.0
        lastShake = 0.0
    }
    
    func radToDeg(dataTo: SpaceData)-> SpaceData {
        let π = M_PI
        var d = dataTo
        d.x = d.x * 180.00
        d.y = d.y * 180.00
        d.z = d.z * 180.00
        d.x = d.x / π
        d.y = d.y / π
        d.z = d.z / π
        
        return d
    }
    

    func randomColor() -> UIColor{
        switch arc4random()%5 {
        case 0:
            return UIColor.red
        case 1:
            return UIColor.blue
        case 2:
            return UIColor.red
        case 3:
            return UIColor.brown
        case 4:
            return UIColor.cyan
        default:
            return UIColor.black
        }
    }
    
    func filterRawData(rawData : SpaceData, filterFactor: Filter){
        
        let f = filterFactor.rawValue
        filterdData.x = f * filterdData.x + (1.0 - f) * rawData.x
        filterdData.y = f * filterdData.y + (1.0 - f) * rawData.y
        filterdData.z = f * filterdData.z + (1.0 - f) * rawData.z
        
        mLinearAcceleration.x = rawData.x - filterdData.x
        mLinearAcceleration.y = rawData.y - filterdData.y
        mLinearAcceleration.z = rawData.z - filterdData.z
    }
    
    func getMaxCurrentLinearAcceleration() -> Double{
        return sqrt(mLinearAcceleration.x * mLinearAcceleration.x + mLinearAcceleration.y * mLinearAcceleration.y + mLinearAcceleration.z * mLinearAcceleration.z)
    }
    
    func updateAccelerometerLabels(data: SpaceData){
        xLabel.text = String(format: "%.f°",data.x)
        yLabel.text = String(format: "%.f°",data.y)
        zLabel.text = String(format: "%.f°",data.z)
    }
    
}

