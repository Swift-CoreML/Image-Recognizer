//
//  WebViewController.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 6/19/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import UIKit
import GoogleMobileAds

class WebViewController: UIViewController {
    
    private var webView:UIWebView?
    
    var wordToSearch = ""
    
    private lazy var backButton:UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButtonTap(_:)))
        return barButton
    }()
    
    // Advertise
    private var bottomBannerView: GADBannerView = {
        let banner = GADBannerView(adSize: kGADAdSizeLargeBanner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.adUnitID = GoogleAdsManager.bottomAdsUnit
        banner.backgroundColor = UIColor.white
        return banner
    }()
    
    private var interstitial : GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = backButton
        
        webView = UIWebView()
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.delegate = self
        view.addSubview(webView!)
        view.addSubview(bottomBannerView)
        
        self.addConstraints(format: "H:|[v0]|", views: webView!)
        self.addConstraints(format: "H:|[v0]|", views: bottomBannerView)
        self.addConstraints(format: "V:|[v0]-10-[v1(100)]|", views: webView!, bottomBannerView)
        
        self.setupAds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.title = "Search for " + wordToSearch
        let newWord = wordToSearch.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://www.google.com/search?q=\(newWord)&tbm=isch"
        
        guard let url = URL(string: urlString) else{
            fatalError("Error occured during create url.")
        }
        
        webView?.loadRequest(URLRequest(url: url))
    }
    
    private func setupAds(){
        // Display Bottom Ads
        self.loadAds(bottomBannerView)
        
        // Set up interstitrial
        interstitial = GADInterstitial(adUnitID: GoogleAdsManager.fullScreenAdsUnit)
        interstitial.delegate = self
        let request = GoogleAdsManager.request
        interstitial.load(request)
    }
    
    @objc private func backButtonTap(_ sender:UIBarButtonItem){
        self.presentAds(interstitial)
    }
}

extension WebViewController : UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}

extension WebViewController : GADInterstitialDelegate{
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.navigationController?.popViewController(animated: true)
    }
}
