//
//  ViewController.swift
//  My VPN
//
//  Created by janardhan karravula on 07/10/2
//  Copyright © 2020 janardhan karravula. All rights reserved.
//
import UIKit
import NetworkExtension
import SwiftKeychainWrapper

class ViewController: UIViewController {

    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var onButton: UIButton!
    
    var vpn = NEVPNManager.shared()
    var userName = KeychainWrapper.standard.set("abc", forKey: "VPN_USER")
    var password = KeychainWrapper.standard.set("abc123", forKey: "VPN_PASSWORD")
    var sharedSecret = KeychainWrapper.standard.set("sharedSecretFromServer", forKey: "VPN_SSK")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        vpn.isEnabled = false
        onButton.setTitle("On", for: .normal)
        onButton.backgroundColor = .green
        connectionLabel.text = "Disconnected"
        connectionLabel.backgroundColor = .red
    }
    
    func connectAnimation(_ on: Bool){
        var increment = 0.0
        connectionLabel.backgroundColor = (on ? .green : .red)
        
        for i in 1...6 {
            
            
            Timer.scheduledTimer(withTimeInterval: 0.5+increment, repeats: false) { (timer) in
                if i==4{
                    self.connectionLabel.text =  on ? "Connecting" : "Disconnecting"
                    print(self.connectionLabel.text!)
                }
                self.connectionLabel.text?.append(".")
                
                if i==6 {
                    self.connectionLabel.text = on ? "Connected" : "Disconnected"
                    
                }
            
            }
            increment += 0.5
            onButton.setTitle(on ? "Off" : "On", for: .normal)
            onButton.backgroundColor = on ? .red : .green
            
        }
        
        
    }
    


    @IBAction func buttonPressed(_ sender: Any) {
        let protocalType = NEVPNProtocolIPSec()
        
        vpn.isEnabled = !vpn.isEnabled
        
        // first load your vpn config
        
        vpn.loadFromPreferences { (error) in
            if error != nil {
                print("Error loading preferences")
            }else{
                
                print("sucessfully loaded")
            }
        }
        
        // retreive username and password from your keychain, which are obtained from your server
        
        protocalType.username = KeychainWrapper.standard.string(forKey: "VPN_USER")
        protocalType.passwordReference = KeychainWrapper.standard.data(forKey: "VPN_PASSWORD")
        
        // set remote identifier and ip of your proxy server, which are obtained from your server
        protocalType.remoteIdentifier = "XYZ"
        protocalType.serverAddress = "000.000.000.000"
        
        //retreving shared key from your keychain, which is obtained from your server
        protocalType.authenticationMethod = .sharedSecret
        protocalType.sharedSecretReference = KeychainWrapper.standard.data(forKey: "VPN_SSK")
        
        
        vpn.protocolConfiguration = protocalType
        vpn.localizedDescription = "My VPN"
        
        
        
        // save your vpn config
        
        if vpn.isEnabled {
            vpn.saveToPreferences { (error) in
                if error != nil {
                    print("Error saving preferences")
                }else{
                    print("sucessfully saved")
                }
            }
            
            do {
                try vpn.connection.startVPNTunnel()
            } catch {
                // Handelling connection failure
                
                let alertController = UIAlertController(title: "Unable to connect", message: "Error occured while connecting to the server :(", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Try again", style: .default) { (UIAlertAction) in
                    
                    self.viewDidLoad()
                }
                
                alertController.addAction(action)
                
                present(alertController, animated: true, completion: nil)
            }
        }
        
        // generating connecting and disconnecting animation
        
        if vpn.isEnabled {
            
            connectionLabel.text = "Connecting"
        } else {
            connectionLabel.text = "Disconnecting"
        }
        
        connectAnimation(vpn.isEnabled)
        
        
   }
    
}


