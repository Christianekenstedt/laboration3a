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
    case CUSTOMPASS = 0.5
    case HIGHPASS = 0.1
}

class ViewController: UIViewController {
    var motionManager : CMMotionManager!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    var filterdData = SpaceData(x: 0.5, y: 0.5, z: 0.5) //???????
    var oldFilterdData = SpaceData(x: 0.5, y: 0.5, z: 0.5)
    
    var startedShake = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
        motionManager = CMMotionManager()
        
        if motionManager.isDeviceMotionAvailable{
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data:CMAccelerometerData?, err:Error?) in
                if let accData = data?.acceleration{
                    let π = M_PI
                    
                    
                    var xAngle = atan( accData.x / (sqrt((accData.y*accData.y) + (accData.z*accData.z))))
                    var yAngle = atan( accData.y / (sqrt((accData.x*accData.x) + (accData.z*accData.z))))
                    var zAngle = atan( sqrt((accData.x*accData.x) + (accData.y*accData.y)) / accData.z)
                    
                    self.filterRawData(rawData: SpaceData(x: xAngle, y: yAngle, z: zAngle), filterFactor: .HIGHPASS)
                    
                    var dataToDisplay = SpaceData(x: self.filterdData.x, y: self.filterdData.y, z: self.filterdData.z)
                    dataToDisplay.x *= 180.00
                    dataToDisplay.y *= 180.00
                    dataToDisplay.z *= 180.00
                    dataToDisplay.x /= π
                    dataToDisplay.y /= π
                    dataToDisplay.z /= π
                    
                    self.updateAccelerometerLabels(data: dataToDisplay)
                    
                }
            })
            motionManager.gyroUpdateInterval = 0.01
            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (data:CMGyroData?, err:Error?) in
                if let gyroData = data?.rotationRate{
                    //print("x: \(gyroData.x), y: \(gyroData.y), z: \(gyroData.z)")
                }
            })
            motionManager.magnetometerUpdateInterval = 0.01
            motionManager.startMagnetometerUpdates(to: OperationQueue.current!, withHandler: { (data: CMMagnetometerData?, err:Error?) in
                if let magnometerData = data?.magneticField{
                    //print("x: \(magnometerData.x), y: \(magnometerData.y), z: \(magnometerData.z)")
                }
            })
        }
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
    }
    
    func updateAccelerometerLabels(data: SpaceData){
        xLabel.text = String(format: "%.f℃",data.x)
        yLabel.text = String(format: "%.f℃",data.y)
        zLabel.text = String(format: "%.f℃",data.z)
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            print("Deviced shaked!")
            let elapsed = Date().timeIntervalSince(startedShake)
            if  elapsed >= 1{
                print("skakad mer än en sekund")
                xLabel.textColor = randomColor()
                yLabel.textColor = randomColor()
                zLabel.textColor = randomColor()
            }else{
                print("stopped shake before timer...")
            }
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake{
            print("börja skaka...")
            startedShake = Date()
        }
    }
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake {
            print("canelled shake")
        }
    }


}

