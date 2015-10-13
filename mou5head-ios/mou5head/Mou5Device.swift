//
//  Mou5PeripheralManager.swift
//  mou5head
//
//  Created by Kousuke Kurimoto on 2015/09/27.
//  Copyright © 2015年 Kousuke Kurimoto. All rights reserved.
//

import Foundation
import CoreBluetooth

// デリゲート
protocol Mou5DeviceDelegate {
    // 非対応のデバイスに接続した時に通知
    func deviceNotCompatible()
}

class Mou5Device: NSObject, CBPeripheralDelegate {
    
    internal var device    :CBPeripheral?
    private  var service   :CBService?
    private  var status    = false
             var delegate  :Mou5DeviceDelegate?
    
    // シングルトンにする
    class var sharedInstance : Mou5Device {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Mou5Device? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Mou5Device()
        }
        return Static.instance!
    }
    // イニシャライザ
    private override init() {
        super.init()
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    * Bluetoothの操作
    */
    // 初期化
    func setup() {
        self.device?.delegate = self
        // サービスを検索
        let UUID = CBUUID(string: "FFE0")
        self.device?.discoverServices([UUID])
    }
    // 文字列を送信
    func sendValue(var value:String){
        //value = value
        let writeValue = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)
        self.device!.writeValue(writeValue!, forCharacteristic: self.service!.characteristics![0] , type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Peripheral Delegate
     */
    // サービスを発見した時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if(peripheral.services!.count == 0){
            // 非対応のデバイスだった場合
            delegate?.deviceNotCompatible()
        }else{
            peripheral.discoverCharacteristics(nil, forService: peripheral.services![0])
        }
    }
    // キャラクタリスティクスを発見した時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        self.service = service
    }
}