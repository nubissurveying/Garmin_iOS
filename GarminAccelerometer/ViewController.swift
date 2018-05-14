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
    
    @IBOutlet weak var deviceInfo: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var AccelerometerData: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var collectButton: UIButton!
    
    
    
    @IBAction func findDevice(_ sender: Any) {
        ConnectIQ.sharedInstance().showDeviceSelection()
    }
    
    @IBAction func loadDevice(_ sender: Any) {
        var deviceInfos = ""
        print("device load",DeviceManager.shared().allDevices().count)
        for curr in DeviceManager.shared().allDevices() {
            let device = curr as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            deviceInfos += device.friendlyName + "\n"
            connectIQ.register(forDeviceEvents: device, delegate: self)
        }
        
        let alert = UIAlertController(title: "Device info", message: deviceInfos, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var stringAppUUID: UUID!
    
    var connectIQ : ConnectIQ!
    var deviceManager : DeviceManager!
    var stringApp : IQApp!
    var acceFileManager : AcceFileManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceManager = DeviceManager.shared()
        deviceManager.delegate = self
        connectIQ = ConnectIQ.sharedInstance()
//        print("connectIQ", connectIQ.)
        stringAppUUID = UUID.init(uuidString: "a3421fee-d289-106a-538c-b9547ab12095")
        // Do any additional setup after loading the view, typically from a nib.
        acceFileManager = AcceFileManager(fileName: "acce")
//        startButton.isEnabled = false
        stopButton.isEnabled = false
        collectButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear","should show devices")
        for currDevice in deviceManager.allDevices() {
            let device = currDevice as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            deviceInfo.text = device.friendlyName
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
        time.text = DateUtil.stringifyAll(calendar: Date())
        AccelerometerData.text = message as? String
        
        if(acceFileManager.processData(data: message as! String)){
            let alert = UIAlertController(title: "Collect Complete", message: "Already collect data from device, do you want to upload to the server?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Upload", style: UIAlertActionStyle.default, handler:{
                (handler) in
                self.acceFileManager.uploadFile()
            } ))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func devicesChanged() {
        print("device change")
        for curr in deviceManager.allDevices() {
            let device = curr as! IQDevice
            print("Registering for device events from '%@'", device.friendlyName)
            connectIQ.register(forDeviceEvents: device, delegate: self)
//            startButton.isEnabled = true
        }
    }
    
    func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
        
            print("deviceStausChange", device.friendlyName)
            print("deviceStausChange", device.modelName)
            print("deviceStausChange", connectIQ.getDeviceStatus(device))
            
        
    }
    @IBAction func sendStartMessage(_ sender: Any) {
        
        sendMessageToDevice(message: "start")
        stopButton.isEnabled = true
        collectButton.isEnabled = false
        startButton.isEnabled = false
    }
    
    @IBAction func sendCollectMessage(_ sender: Any) {
        sendMessageToDevice(message: "collect")
        
        
    }
    @IBAction func sendStopMessage(_ sender: Any) {
        sendMessageToDevice(message: "stop")
        collectButton.isEnabled = true
        startButton.isEnabled = true
        stopButton.isEnabled = false
    }
    func sendMessageToDevice(message : String) {
        connectIQ.sendMessage(message, to: stringApp, progress: { (sentBytes, totalBytes) in
            let percent = 100 * Double(sentBytes) / Double(totalBytes)
            print("send progress", percent, sentBytes, totalBytes)
            
        }, completion: {(result) in
            print("send message finished with result", NSStringFromSendMessageResult(result))
        })
    }
}

