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


class ViewController: UIViewController, DeviceManagerDelegate, IQDeviceEventDelegate{
    
    @IBOutlet weak var message: UILabel!
    
    var connectIQ : ConnectIQ!
    var deviceManager : DeviceManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceManager = DeviceManager.shared()
        deviceManager.delegate = self
        connectIQ = ConnectIQ.sharedInstance()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for currDevice in deviceManager.allDevices() {
            let device = currDevice as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            connectIQ.register(forDeviceEvents: device, delegate: self)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

