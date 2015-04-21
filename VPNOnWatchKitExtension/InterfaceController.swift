//
//  InterfaceController.swift
//  VPN On WatchKit Extension
//
//  Created by Lex Tang on 3/30/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation
import VPNOnKit

let kVPNOnSelectedIDInToday = "kVPNOnSelectedIDInToday"

class InterfaceController: VPNInterfaceController {
    
    @IBOutlet weak var tableView: WKInterfaceTable!

    override func willActivate() {
        super.willActivate()
        
        loadVPNs()
    }
    
    func loadVPNs() {
        if vpns.count > 0 {
            self.tableView.setNumberOfRows(vpns.count, withRowType: "VPNRow")
            
            for i in 0...vpns.count-1 {
                if let row = self.tableView.rowControllerAtIndex(i) as! VPNRowWithSwitch? {
                    let vpn = vpns[i]
                    
                    if let countryCode = vpn.countryCode {
                        row.flag.setImageNamed(countryCode)
                    }
                    
                    row.latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
                    
                    let connected = Bool(VPNManager.sharedManager.status == .Connected && vpn.ID == selectedID)
                    let backgroundColor = connected ? UIColor(red:0, green:0.6, blue:1, alpha:1) : UIColor(white: 1.0, alpha: 0.2)
                    row.group.setBackgroundColor(backgroundColor)
                    row.VPNSwitch.setOn(connected)
                }
            }
        } else {
            self.tableView.setNumberOfRows(1, withRowType: "HintRow")
        }
    }
    
    func didTurnOnVPN(notifiction: NSNotification) {
        if let userInfo = notifiction.userInfo as! [String: Int]? {
            if let index = userInfo[kVPNIndexKey] {
                let vpn = vpns[index]
                selectedID = vpn.ID
                connectVPN(vpn)
            }
        }
    }
    
    func didTurnOffVPN(notification: NSNotification) {
        VPNManager.sharedManager.disconnect()
        loadVPNs()
    }
    
    // MARK: - Notification
    
    func pingDidUpdate(notification: NSNotification) {
        loadVPNs()
    }
    
    func coreDataDidSave(notification: NSNotification) {
        VPNDataManager.sharedManager.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
        loadVPNs()
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        loadVPNs()
        if VPNManager.sharedManager.status == .Disconnected {
            LTPingQueue.sharedQueue.restartPing()
        }
    }

}
