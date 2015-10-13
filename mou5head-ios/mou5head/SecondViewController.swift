//
//  SecondViewController.swift
//  mou5head
//
//  Created by Kousuke Kurimoto on 2015/09/23.
//  Copyright © 2015年 Kousuke Kurimoto. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,Mou5DeviceDelegate {

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * View
     */


    @IBAction func flushButtonTouchDown(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("1")
    }

    @IBAction func flushButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("2")
    }
    
    @IBAction func startAnimationButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("3")
    }
    
    @IBAction func nextAnimationButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("4")
    }

    @IBAction func blueButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("5")
    }
    
    @IBAction func redButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("6")
    }
    
    @IBAction func greenButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("7")
    }
    
    @IBAction func purpleButtonTouchUp(sender: UIButton) {
        Mou5Device.sharedInstance.sendValue("8")
    }
    
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
    func setup(){
        self.navigationItem.title = "Controller"
        
        Mou5Device.sharedInstance
        Mou5Device.sharedInstance.delegate = self
        Mou5Device.sharedInstance.setup()
        
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
     * Mou5Device Delegate
     */
    // 非対応のデバイスに接続した時に呼ばれる
    func deviceNotCompatible() {
        let alertAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        let alertController = UIAlertController(title: "Info", message: "このデバイスには対応していません", preferredStyle: .Alert)
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    


}
