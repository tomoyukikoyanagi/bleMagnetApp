//
//  DeviceManager.swift
//  BLEMultiConnectSample
//
//  Created by koyanagi on 2019/08/21.
//
//

import Foundation
import CoreBluetooth

final class DeviceManager: NSObject {
    static let deviceUpdated = Notification.Name("deviceUpdated")
    private let centralManager: CBCentralManager
    private(set) var devices = [Device]() {
        didSet {
            //ViewControllerへ通知を送る
            NotificationCenter.default
                .post(name: DeviceManager.deviceUpdated, object: nil)
        }
    }

    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        centralManager.delegate = self
        self.timerUpdate()
        
    }

    func scan() {
        //centralManager.scanForPeripherals(withServices: nil, options: nil)
        centralManager.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        
    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func removeDevices() {
        devices.removeAll()
    }
    
    @objc func timerUpdate() {
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){ t in
            var count = self.devices.count
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ timer in
                count -= 1
                print("scan:", count)
                if count >= 0 {
                    self.connect(peripheral: self.devices[count].peripheral)
                }
                if count <= 0{
                    count = self.devices.count
                }
            }
        }
    }
}


// MARK: - CBCentralManagerDelegate
/*
 Invoked when the central manager’s state is updated.
 This is where we kick off the scan if Bluetooth is turned on.
 */
extension DeviceManager: CBCentralManagerDelegate{

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //print("state: \(central.state.rawValue)")
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("Bluetooth Enabled")
            scan()
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                print("delaying...")
                self.stopScan()
            print("stop scanning")
            }
 */
            
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
            
            /*
            let alertVC = UIAlertController(title: "Bluetooth is not enabled", message: "Make sure that your bluetooth is turned on", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
 */
        }
    }

    //device を追加する
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = Device(peripheral: peripheral, rssi: RSSI)
        if let index = devices.index(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            devices[index] = device
        } else {
            devices.append(device)
            //self.centralManager.connect(device.peripheral, options: nil)
        }
        
    }

    //deviceが接続された場合
    //ここで呼び出すBLEデバイスを特定すること
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        devices.first { $0.peripheral == peripheral }
            .map { $0.state = .connected }
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([BLEService_UUID])
        NotificationCenter.default
            .post(name: DeviceManager.deviceUpdated, object: nil)
    }

    //deviceが切断された場合
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        devices.first { $0.peripheral == peripheral }
            .map { $0.state = .disconnected }

        /*
        NotificationCenter.default
            .post(name: DeviceManager.deviceUpdated, object: nil)
         */
    }
}
