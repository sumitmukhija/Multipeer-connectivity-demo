//
//  ColorServiceManager.swift
//  MultiPeer
//
//  Created by Sumit on 3/22/17.
//  Copyright © 2017 Sumit Mukhija. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ColorManagerHelper {
    func didChangeColor(color: String)
}

class ColorServiceManager: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, UIAlertViewDelegate {
    
    let serviceType = "color-service"
    let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    var serviceAdvertiser: MCNearbyServiceAdvertiser? = nil
    
    var delegate: ColorManagerHelper?
    var serviceSeeker: MCNearbyServiceBrowser? = nil
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        return session
    }()
    
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceSeeker = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        self.serviceAdvertiser?.delegate = self
        self.serviceAdvertiser?.startAdvertisingPeer()
        
        self.serviceSeeker?.delegate = self
        self.serviceSeeker?.startBrowsingForPeers()
    }
    
    deinit{
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceSeeker?.startBrowsingForPeers()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("Received invitation..")
        invitationHandler(true, self.session)
//        let alertCon = UIAlertController(title: "Connect?", message: "Connect with \(peerID)", preferredStyle: .Alert)
//        alertCon.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
//            invitationHandler(true, self.session)
//        }))
//        alertCon.addAction(UIAlertAction(title: "No", style: .Destructive, handler: { (action) in
//            invitationHandler(false, self.session)
//        }))
        
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Didn't start receving \(error.localizedDescription)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("Didn't start browsing \(error.localizedDescription)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer \(peerID.displayName)")
        print("Invite peer \(peerID.displayName)")
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 100)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer \(peerID.displayName)")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("received data from \(peerID.displayName)")
        let str = String(data: data, encoding: NSUTF16StringEncoding)!
        self.delegate?.didChangeColor(str)
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("\(peerID.displayName) changed state")
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("received stream from \(peerID.displayName)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("started receiving from \(peerID.displayName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("finished receiving from \(peerID.displayName)")
    }
    
    func send(colorName : String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(colorName.dataUsingEncoding(NSUTF16StringEncoding)!, toPeers: session.connectedPeers, withMode: .Reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
}
