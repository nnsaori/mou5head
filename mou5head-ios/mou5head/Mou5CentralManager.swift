//
//  CentralManager.swift
//  mou5head
//
//  Created by Kousuke Kurimoto on 2015/09/21.
//  Copyright © 2015年 Kousuke Kurimoto. All rights reserved.
//

import Foundation
import CoreBluetooth

// デリゲート
protocol Mou5CentralManagerDelegate {
    // ステータスメッセージの更新を通知
    func mou5UpdateStatusMessage(bluetoothStatusMessage:String)

    // デバイス一覧の更新を通知
    func mou5UpdateDeviceList()
    
    // デバイスへの接続成功を通知
    func mou5DidConnectedDevice()
}

class Mou5CentralManager: NSObject, CBCentralManagerDelegate {

    private var deviceList              = NSMutableArray()
    private var bluetoothStatusMessage  : String!
    private var cbCentralManager        : CBCentralManager!
            var delegate                : Mou5CentralManagerDelegate?

    // シングルトンにする
    class var sharedInstance : Mou5CentralManager {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Mou5CentralManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Mou5CentralManager()
        }
        return Static.instance!
    }
    // イニシャライザ
    private override init() {
        super.init()
        self.cbCentralManager = CBCentralManager(delegate:self, queue:nil)
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Getter
     */
    
    // デバイス名を返す
    func getDeviceName(index:Int) -> String {
        return self.checkPeripheralName(self.deviceList[index] as! CBPeripheral)
    }
    
    // デバイス数を返す
    func getDevicesCount() -> Int {
        return self.deviceList.count
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    * Private
    */
    func checkPeripheralName(peripheral:CBPeripheral) -> String{
        var deviceName:String?
        if peripheral.name == nil {
            deviceName = "No name"
        }else{
            if(peripheral.name! == "HMSoft"){
                deviceName = "Deadmou5Head"
            }else{
                deviceName = peripheral.name!
            }
        }
        return deviceName!
    }

    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Bluetoothの操作
     */
    // デバイスのスキャンを開始
    func startScan() {
        // ステータスメッセージを更新
        self.bluetoothStatusMessage = "Bluetooth機器をスキャン中..."
        // ステータスメッセージの更新を通知
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
        
        // デバイスリストを初期化
        self.deviceList = NSMutableArray()
        
        // デバイスのスキャンを開始
        let options = ["CBCentralManagerScanOptionAllowDuplicatesKey" : true]
        self.cbCentralManager.scanForPeripheralsWithServices(nil, options: options)
    }
    
    // デバイスのスキャンを停止
    func stopScan() {
        // ステータスメッセージを更新
        self.bluetoothStatusMessage = "スキャンを停止しました"
        // ステータスメッセージの更新を通知
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
        
        // デバイスのスキャンを停止
        self.cbCentralManager.stopScan()
    }
    
    // デバイスに接続(デバイスリストのindex番号を引数にとる)
    func connectDevice(index:Int) {
        self.bluetoothStatusMessage = "デバイスに接続しています..."
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
        self.cbCentralManager.connectPeripheral(self.deviceList[index] as! CBPeripheral, options: nil)
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * CBCentralManager Delegate
     */
    // CBCentralManagerのステータスメッセージ更新後に呼ばれる
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        // Bluetoothのステータスメッセージを取得
        switch self.cbCentralManager.state {
        case .PoweredOff:
            self.bluetoothStatusMessage = "Bluetoothの電源がOffです"
            break
        case .PoweredOn:
            self.bluetoothStatusMessage = "Bluetoothの準備が完了しました"
            break
        case .Resetting:
            self.bluetoothStatusMessage = "リセット中"
            break
        case .Unauthorized:
            self.bluetoothStatusMessage = "Bluetoothを使用できません(未認証)"
            break
        case .Unknown:
            self.bluetoothStatusMessage = "Bluetoothを使用できません(不明なエラー)"
            break
        case .Unsupported:
            self.bluetoothStatusMessage = "このプラットフォームはBluetoothをサポートしていません"
            break
        }
        // ステータスメッセージの更新を通知
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
    }
    
    // デバイス発見時に呼ばれる
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // デバイス一覧に保存
        self.deviceList.addObject(peripheral)
        
        // 発見したデバイスの名前を取得してステータスメッセージを更新
        if peripheral.name == nil {
            self.bluetoothStatusMessage = "デバイスを発見 Name:No name " + "Identifier:" + peripheral.identifier.description
        }else{
            self.bluetoothStatusMessage = "デバイスを発見 Name:" + peripheral.name! + "Identifier:" + peripheral.identifier.description
        }
        
        // ステータスメッセージの更新を通知
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
        
        // デバイスリストの更新を通知
        delegate?.mou5UpdateDeviceList()
    }
    
    // デバイスへの接続成功時に呼ばれる
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        // ステータスメッセージを更新
        self.bluetoothStatusMessage = self.checkPeripheralName(peripheral) + " への接続が成功しました"

        // ステータスメッセージの更新を通知
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
        
        // スキャンを停止
        self.stopScan()
        
        // デバイスをセット
        Mou5Device.sharedInstance.device = peripheral
        
        // 接続成功を通知
        delegate?.mou5DidConnectedDevice()
    }
    
    // デバイスへの接続失敗時に呼ばれる
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // ステータスメッセージを更新
        self.bluetoothStatusMessage = "デバイスへの接続に失敗しました"
        // ステータスメッセージの更新を通知
        delegate?.mou5UpdateStatusMessage(self.bluetoothStatusMessage)
    }
    
}