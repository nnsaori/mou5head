//
//  ViewController.swift
//  mou5head
//
//  Created by Kousuke Kurimoto on 2015/09/20.
//  Copyright © 2015年 Kousuke Kurimoto. All rights reserved.
//
import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,Mou5CentralManagerDelegate {
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Views
     */
    @IBOutlet weak var consoleTextView: UITextView!
    @IBAction func StartScanButton(sender: UIButton) {
        Mou5CentralManager.sharedInstance.startScan()
        self.deviceListTableView.reloadData()
    }
    @IBAction func StopScanButton(sender: UIButton) {
        Mou5CentralManager.sharedInstance.stopScan()
    }
    @IBOutlet weak var deviceListTableView: UITableView!
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Viewイベント
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Private
     */
    // 初期化
    func setup() {
        // 画面タイトルの設定
        self.navigationItem.title = "Search"
        
        // Mou5CentralManagerの設定
        Mou5CentralManager.sharedInstance // インスタンス生成(シングルトン)
        Mou5CentralManager.sharedInstance.delegate = self
        
        // デバイス一覧表示用TableViewの設定
        self.deviceListTableView.delegate   = self
        self.deviceListTableView.dataSource = self
        self.deviceListTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // コンソール用テキストビューを更新する
    func updateConsoleText(insert_text:String){
        // 現在時刻を取得する
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.stringFromDate(now)
        
        // コンソールの文字列を更新する
        consoleTextView.scrollEnabled = false
        consoleTextView.text = consoleTextView.text.stringByAppendingString("\n" + time + " " + insert_text)
        consoleTextView.scrollEnabled = true
        
        // 末尾にスクロールする
        var scroll_y:CGFloat = consoleTextView.contentSize.height  - consoleTextView.bounds.size.height
        if (scroll_y < 0) {
            scroll_y = 0;
        }
        let scroll_point = CGPointMake(0.0, scroll_y)
        consoleTextView.setContentOffset(scroll_point, animated: false)
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * CentralManager Delegate
     */
    // Bluetoothのステータスが更新された時に呼ばれる
    func mou5UpdateStatusMessage(bluetoothStatus: String) {
        self.updateConsoleText(bluetoothStatus)
    }
    // 発見したBluetoothデバイス一覧が更新された時に呼ばれる
    func mou5UpdateDeviceList() {
        // TableViewを更新
        self.deviceListTableView.reloadData()
    }
    // デバイスに接続成功した時に呼ばれる
    func mou5DidConnectedDevice() {
        // コントローラー画面に遷移
        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SecondViewController") as! SecondViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * DeviceListTableView Delegate
     */
    // 行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Mou5CentralManager.sharedInstance.getDevicesCount()
    }
    // セルの中身
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell") as UITableViewCell
        cell.textLabel!.text = Mou5CentralManager.sharedInstance.getDeviceName(indexPath.row)
        return cell
    }
    // セルが選択された時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択されたデバイスに接続
        Mou5CentralManager.sharedInstance.connectDevice(indexPath.row)
    }
}

