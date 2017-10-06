//
//  Extensions.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 6/12/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DZNEmptyDataSet
import GoogleMobileAds

extension UIViewController : NVActivityIndicatorViewable{
    func showLoading(message msg:String, actionHandler action:()->Void){
        let size = CGSize(width: 30, height: 30)
        self.startAnimating(size, message: msg, type: NVActivityIndicatorType.ballPulseSync)
        
        action()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(msg)
        }
    }
    
    func dismissLoading(actionHandler action:@escaping ()->Void){
        DispatchQueue.main.async() {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            action()
        }
    }
}

extension UIViewController{
    func addConstraints(format:String, views:UIView...){
        // Create dictionary of view base on inputed view
        var viewsDictionary : [String:UIView] = [:]
        for (index, view) in views.enumerated(){
            viewsDictionary["v\(index)"] = view
        }
        // Add Constraint
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewsDictionary))
    }
    
    func loadAds(_ ads:GADBannerView...){
        
        let request = GoogleAdsManager.request
        
        for banner in ads{
            banner.load(request)
        }
    }
    
    func presentAds(_ ads: GADInterstitial){
        if ads.isReady{
            ads.present(fromRootViewController: self)
        }
    }
}

extension UIView{
    func addConstraintWithFormat(format:String, views:UIView...){
        // Create dictionary of view base on inputed view
        var viewsDictionary : [String:UIView] = [:]
        for (index, view) in views.enumerated(){
            viewsDictionary["v\(index)"] = view
        }
        // Add Constraint
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewsDictionary))
    }
}

