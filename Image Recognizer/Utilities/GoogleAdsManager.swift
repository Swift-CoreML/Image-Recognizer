//
//  GoogleManager.swift
//  Image Recognizer
//
//  Created by LUN Sovathana on 9/28/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import Foundation
import GoogleMobileAds

struct GoogleAdsManager{
    
    private static let testDeviceId = "2077ef9a63d2b398840261c8221a0c9b"
    private static let testBannerId = "ca-app-pub-3940256099942544/6300978111"
    
    static var adsMobAppId : String {
        return (Bundle.main.infoDictionary!["GoogleAdsMob"] as! [String:Any])["appId"] as! String
    }
    
    static var bottomAdsUnit : String{
        if Configuration.env == .prod{
            return (Bundle.main.infoDictionary!["GoogleAdsMob"] as! [String:Any])["bottomAdsUnit"] as! String
        }else{
            return GoogleAdsManager.testBannerId
        }
    }
    
    static var fullScreenAdsUnit : String{
        if Configuration.env == .prod{
            return (Bundle.main.infoDictionary!["GoogleAdsMob"] as! [String:Any])["fullScreenAdsUnit"] as! String
        }else{
            return GoogleAdsManager.testBannerId
        }
    }
    
    static var request : GADRequest{
        if Configuration.env == .prod{
            let request = GADRequest()
            return request
        }else{
            let request = GADRequest()
            request.testDevices = [ kGADSimulatorID, "ebbb8c50d15d11b67969a43ef0d62876"]
            return request
        }
    }
}
