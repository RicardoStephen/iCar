//
//  ViewController.swift
//  iCar
//
//  Created by Ricardo Leander Stephen on 1/17/16.
//  Copyright © 2016 Ricardo Leander Stephen. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion


// CONVENTION: pwmMultiplier1 controls the right wheel


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: Constants
    let PERIPHERAL_NAME = "iCar"
    let NAVIGATION_SERVICE_UUID = CBUUID(string: "0x04DA")
    let NAVIGATION_CHARACTERISTIC_UUID = CBUUID(string: "0x04DB")
    let TIMER_INTERVAL = 0.25
    let SEGMENT_REVERSE: Int = 0
    let SEGMENT_LEFT: Int = 1
    let SEGMENT_STOP: Int = 2
    let SEGMENT_RIGHT: Int = 3
    let SEGMENT_FORWARD: Int = 4
    let ACCELERATE_UPDATE: Double = 20
    let BREAK_UPDATE: Double = 20
    let DETERIORATION_UPDATE: Double = 3
    
    
    // MARK: Properties
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    var currentBreak: Bool = false
    var currentAccelerate: Bool = false
    var currentSegmentIndex: Int = 1
    var currentSlider: Float!
    var currentUserSetSlider: Bool = false
    var currentPWM: Double = 0
    var bleManager: CBCentralManager!
    var ready: Bool = false
    var peripheral: CBPeripheral?
    var navigationCharacteristic: CBCharacteristic?
    var motionManager: CMMotionManager!
    var timer: NSTimer!
    
    
    // MARK: UIViewController
    override func viewDidLoad() {
        sleep(2) // extend launch duration
        super.viewDidLoad()
        timer = NSTimer(timeInterval: TIMER_INTERVAL, target: self, selector: "pwm_controller", userInfo: nil, repeats: true)
        bleManager = CBCentralManager(delegate: self, queue:nil)
        motionManager = CMMotionManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if (central.state == CBCentralManagerState.PoweredOn) {
            speedSlider.setValue(Float(0), animated: false)
            print("Connected to bluetooth")
            central.scanForPeripheralsWithServices([NAVIGATION_SERVICE_UUID], options: nil)
        } else {
            statusLabel.text = "Disconnected"
            speedSlider.setValue(Float(0), animated: false)
            ready = false
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if peripheral.name == PERIPHERAL_NAME {
            central.stopScan()
            self.peripheral = peripheral
            peripheral.delegate = self
            central.connectPeripheral(peripheral, options: nil)
            print("Discovered \(PERIPHERAL_NAME)...")
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices([NAVIGATION_SERVICE_UUID])
        speedSlider.setValue(Float(0), animated: false)
        print("Connected to \(PERIPHERAL_NAME)...")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        speedSlider.setValue(Float(0), animated: false)
        ready = false
        motionManager.stopDeviceMotionUpdates()
        statusLabel.text = "Disconnected"
        print("Disconnected from \(PERIPHERAL_NAME)")
    }
    
    
    // MARK: CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            if service.UUID == NAVIGATION_SERVICE_UUID {
                peripheral.discoverCharacteristics([NAVIGATION_CHARACTERISTIC_UUID], forService: service)
                print("Discovered the service...")
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics! {
            if characteristic.UUID == NAVIGATION_CHARACTERISTIC_UUID {
                navigationCharacteristic = characteristic
                motionManager.startDeviceMotionUpdates()
                ready = true
                NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                statusLabel.text = "Ready!"
                print("Discovered the characteristic")
            }
        }
    }

    
    // MARK: Actions
    @IBAction func breakTouchDown(sender: UIButton) {
        currentBreak = true
        currentUserSetSlider = false
    }
    
    @IBAction func breakTouchUpInside(sender: UIButton) {
        currentBreak = false
    }
    
    @IBAction func breakTouchUpOutside(sender: UIButton) {
        currentBreak = false
    }
    
    @IBAction func accelerateTouchDown(sender: UIButton) {
        currentAccelerate = true
        currentUserSetSlider = false
    }
    
    @IBAction func accelerateTouchUpInside(sender: UIButton) {
        currentAccelerate = false
    }
    
    @IBAction func accelerateTouchUpOutside(sender: UIButton) {
        currentAccelerate = false
    }
    
    @IBAction func directionValueChanged(sender: UISegmentedControl) {
        currentSegmentIndex = sender.selectedSegmentIndex
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        currentUserSetSlider = true
        currentSlider = sender.value
    }
    
    
    // MARK: Helper Functions
    func pwm_controller() {
        if !ready {
            centralManagerDidUpdateState(bleManager)
            return
        }
        
        var command = [UInt8](count: 5, repeatedValue: 1)
        var pitch: Double // Note: turn left if pitch > 0. right if pitch < 0
        var characteristic: CBCharacteristic
        var pwmMultiplier1: Double = 1
        var pwmMultiplier2: Double = 1
        
        // Set unwrapped characteristic if available
        if let temp = navigationCharacteristic {
            characteristic = temp
        } else {
            return
        }
        
        // Set unwrapped pitch if available
        if let deviceMotion = motionManager.deviceMotion {
            pitch = deviceMotion.attitude.pitch
        } else {
            return
        }
        
        // Set start/stop and direction
        switch currentSegmentIndex {
        case SEGMENT_REVERSE:
            break
        case SEGMENT_LEFT:
            command[1] = 0
        case SEGMENT_STOP:
            command[0] = 0
        case SEGMENT_RIGHT:
            command[3] = 0
        case SEGMENT_FORWARD:
            command[1] = 0
            command[3] = 0
        default:
            print("Error: \(currentSegmentIndex) is not a valid index")
        }
        
        // Set maximum pwm
        if currentUserSetSlider {
            currentPWM = Double(currentSlider)
        } else {
            if currentAccelerate {
                currentPWM += ACCELERATE_UPDATE
            }
            if currentBreak {
                currentPWM -= BREAK_UPDATE
            }
            if !currentAccelerate && !currentBreak {
                currentPWM -= DETERIORATION_UPDATE
            }
        }
        if currentPWM > 255 {
            currentPWM = 255
        } else if currentPWM < 0 {
            currentPWM = 0
        }
        speedSlider.setValue(Float(currentPWM), animated: false)
        
        // Compute pwm multiplers
        if pitch > 0 {
            if pitch > M_PI/4 {
                pitch = M_PI/3
            }
            pwmMultiplier1 = (M_PI - 2*pitch)/M_PI
        } else {
            if pitch < -M_PI/4 {
                pitch = -M_PI/3
            }
            pwmMultiplier2 = (M_PI + 2*pitch)/M_PI
        }
        
        // Set pwm for each motor
        command[2] = UInt8(currentPWM*pwmMultiplier2)
        command[4] = UInt8(currentPWM*pwmMultiplier1)
        
        // Write over bluetooth
        let data = NSData(bytes: &command, length: 5*sizeof(UInt8))
        self.peripheral!.writeValue(data, forCharacteristic: characteristic, type: .WithResponse)
    }
}

