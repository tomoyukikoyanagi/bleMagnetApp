//
//  Device.swift
//  BLEMultiConnectSample
//
//  Created by hirotaka on 2017/12/23.
//  Copyright © 2017 hiro. All rights reserved.
//

import Foundation
import CoreBluetooth


var txCharacteristic : CBCharacteristic?
var rxCharacteristic : CBCharacteristic?
var blePeripheral : CBPeripheral?
var characteristicASCIIValue = NSString()

final class Device: NSObject {
    static let characteristicUpdated = Notification.Name("charactteristicUpdated")
    let peripheral: CBPeripheral
    let rssi: NSNumber
    var state = State.disconnected
    var characteristic =  NSString()
    var head_or_tail = Head_or_Tail.tail

    init(peripheral: CBPeripheral, rssi: NSNumber) {
        self.peripheral = peripheral
        self.rssi = rssi
        super.init()
        peripheral.delegate = self
        
        print("peripheral: \(peripheral)" )
        print("rssi:  \(rssi)")
    }
}

extension Device {

    enum State: String, CustomStringConvertible {
        case disconnected
        case connected

        var description: String {
            return rawValue
        }
    }
}

extension Device {
    
    enum Head_or_Tail: String, CustomStringConvertible {
        case head
        case tail
        
        var description: String {
            return rawValue
        }
    }
}


// MARK: - CBPeripheralDelegate

extension Device: CBPeripheralDelegate {
    
    //Data
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if ((error) != nil) {
            //print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        //print("Discovered Services: \(services)")
    }
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //print("*******************************************************")
        
        if ((error) != nil) {
            //print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        //print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                //print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                //print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    //*********************************************こっからBLEから読み取った値を処理します************************************************************
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
            //ASCIIstring が読み取った結果です
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                //print("Value Recieved: \((characteristicASCIIValue as String))")
                self.characteristic = ASCIIstring
                
            //読み取った値から表裏を判別
                //元の値を保存
                let oldValue = self.head_or_tail
                //表裏の判別
                if self.characteristic == "head" {
                    
                    self.head_or_tail = Head_or_Tail.head
                }
                else {
                    self.head_or_tail = Head_or_Tail.tail
                }
                // 元の値と今の値の変化を確認
                if oldValue != self.head_or_tail {
                    //print("******************UpdateValueFor***********************")
                    //通知を出す
                    //NotificationCenter.default.post(name:NSNotification.Name(rawValue: "deviceUpdated"), object: nil)
                    //NotificationCenter.default.post(name: Device.deviceUpdated, object: nil)
                    NotificationCenter.default.post(name: DeviceManager.deviceUpdated, object: nil)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //print("*******************************************************")
        
        if error != nil {
            //print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor?
                //print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
                //print("Rx Value \(String(describing: rxCharacteristic?.value))")
                //print("Tx Value \(String(describing: txCharacteristic?.value))")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //print("*******************************************************")
        
        if (error != nil) {
            //print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            //print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            //print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            //print("Error discovering services: error")
            return
        }
        //print("Message sent")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            //print("Error discovering services: error")
            return
        }
        //print("Succeeded!")
    }
}
