//
//  TranslatedViewController.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 7/3/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import UIKit
import GoogleMobileAds
import DZNEmptyDataSet

class TranslatedViewController : UIViewController{
    
    let defaultCellID = "DefaultCell"
    let translatedTextCellID = "TranslatedTextCell"
    
    var results : [TranslatedResult] = [
        TranslatedResult(headerText: "Source", resultText:""),
        TranslatedResult(headerText: "Locale", resultText:""),
        TranslatedResult(headerText: "Translated Text", resultText:"")
    ]
    
    private lazy var backButton:UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButtonTap(_:)))
        return barButton
    }()
    
    private var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.white
        return tableView
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
        
        navigationItem.title = "Translation"
        
        self.navigationItem.leftBarButtonItem = backButton
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellID)
        self.tableView.register(TranslatedTextTableViewCell.self, forCellReuseIdentifier: translatedTextCellID)
        
        bottomBannerView.rootViewController = self
        
        self.view.addSubview(tableView)
        self.view.addSubview(bottomBannerView)
        
        self.addConstraints(format: "H:|[v0]|", views: tableView)
        self.addConstraints(format: "H:|[v0]|", views: bottomBannerView)
        self.addConstraints(format: "V:|[v0]-10-[v1(100)]|", views: tableView, bottomBannerView)
        
        self.tableView.reloadData()
        
        self.setupAds()
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

extension TranslatedViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = results[indexPath.section]
        
        switch indexPath.section {
        case 0...1:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellID, for: indexPath)
            cell.textLabel?.text = result.resultText
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: translatedTextCellID, for: indexPath) as! TranslatedTextTableViewCell
            cell.translatedTextView.text = result.resultText
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return results[section].headerText
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0...1:
            return 50
        default:
            return 200
        }
    }
}

extension TranslatedViewController : GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bottomBannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.bottomBannerView.alpha = 1
        })
    }
}

extension TranslatedViewController : GADInterstitialDelegate{
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.navigationController?.popViewController(animated: true)
    }
}
