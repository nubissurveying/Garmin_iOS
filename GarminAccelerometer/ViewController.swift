//
//  ViewController.swift
//  GarminAccelerometer
//
//  Created by Qinjia Huang on 4/26/18.
//  Copyright © 2018 Qinjia Huang. All rights reserved.
//

import UIKit
import ConnectIQ
import Alamofire


class ViewController: UIViewController, DeviceManagerDelegate, IQDeviceEventDelegate, IQAppMessageDelegate{
    
    @IBOutlet weak var message: UILabel!
    
    
    @IBAction func findDevice(_ sender: Any) {
        ConnectIQ.sharedInstance().showDeviceSelection()
    }
    
    @IBAction func loadDevice(_ sender: Any) {
        print("device load",DeviceManager.shared().allDevices().count)
        for curr in DeviceManager.shared().allDevices() {
            let device = curr as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            connectIQ.register(forDeviceEvents: device, delegate: self)
        }
        
    }
    
    var stringAppUUID: UUID!
    
    var connectIQ : ConnectIQ!
    var deviceManager : DeviceManager!
    var stringApp : IQApp!
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceManager = DeviceManager.shared()
        deviceManager.delegate = self
        connectIQ = ConnectIQ.sharedInstance()
//        print("connectIQ", connectIQ.)
        stringAppUUID = UUID.init(uuidString: "a3421fee-d289-106a-538c-b9547ab12095")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear","should show devices")
        for currDevice in deviceManager.allDevices() {
            let device = currDevice as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            message.text = device.friendlyName
            connectIQ.register(forDeviceEvents: device, delegate: self)
            
            stringApp = IQApp.init(uuid: stringAppUUID, store: stringAppUUID, device: device)
            
            connectIQ.register(forAppMessages: stringApp, delegate: self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
//        connectIQ.unregister(forAllAppMessages: self)
//        connectIQ.unregister(forAllDeviceEvents: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func receivedMessage(_ message: Any!, from app: IQApp!) {
        print("receive message", message)
    }
    
    func devicesChanged() {
        print("device change")
        for curr in deviceManager.allDevices() {
            let device = curr as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            connectIQ.register(forDeviceEvents: device, delegate: self)
        }
    }
    
    func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
        
            print("deviceStausChange", device.friendlyName)
            print("deviceStausChange", device.modelName)
            print("deviceStausChange", connectIQ.getDeviceStatus(device))
            
        
    }

}

