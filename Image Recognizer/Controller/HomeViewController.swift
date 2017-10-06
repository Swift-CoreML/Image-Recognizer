//
//  HomeViewController.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 6/12/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import DZNEmptyDataSet
import GoogleMobileAds

class HomeViewController: UIViewController {
    private let resultCellID = "ResultCell"
    private var placeHolderImage : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "placeholder")
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        return image
    }()
    
    private var browseButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "subViewBackground")
        button.setTitle("Browse...", for: .normal)
        button.setTitleColor(UIColor(named: "buttonTitleColor"), for: .normal)
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(browseImage(_:)), for: .touchUpInside)
        return button
    }()
    
    private var resultContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var resultLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Results"
        return label
    }()
    
    private var resultTableView : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var bottomBannerView: GADBannerView = {
        let banner = GADBannerView(adSize: kGADAdSizeFullBanner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.adUnitID = GoogleAdsManager.bottomAdsUnit
        return banner
    }()
    
    private let model = Inceptionv3()
    private var results = ClassResult(headerTitle: "Predicted Results", results: [])
    //    private let translationLanguages : [Language] = [
    //        Language(language: "简体中文", code:"zh-CN"),
    //        Language(language: "中國傳統的", code:"zh-TW"),
    //        Language(language: "English", code:"en"),
    //        Language(language: "日本語", code:"ja"),
    //        Language(language: "ភាសាខ្មែរ", code:"km"),
    //        Language(language: "한국어", code:"ko")
    //    ]
    
    private let translationLanguages : [Language] = [
        Language(language: "Chinese(Simplified)", code:"zh-CN"),
        Language(language: "Chinese(Traditional)", code:"zh-TW"),
        //Language(language: "English", code:"en"),
        Language(language: "Japanese", code:"ja"),
        Language(language: "Khmer", code:"km"),
        Language(language: "Korean", code:"ko")
    ]
    
    var translationService:TranslationService?
    // Tracking whether allow viewing photo full screen or not
    var isAllowedFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        translationService = TranslationService()
        translationService?.delegate = self
        bottomBannerView.delegate = self
        
        setupViews()
        
        resultTableView.emptyDataSetDelegate = self
        resultTableView.emptyDataSetSource = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.tableFooterView = UIView()
        resultTableView.register(UITableViewCell.self, forCellReuseIdentifier: resultCellID)
    }
    
    fileprivate func setupViews() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Image Recognizer"
        
        view.backgroundColor = UIColor.white
        
        // Add Action
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(previewImage(sender:)))
        placeHolderImage.isUserInteractionEnabled = true
        placeHolderImage.addGestureRecognizer(imageTapGesture)
        
        bottomBannerView.rootViewController = self
        
        view.addSubview(placeHolderImage)
        view.addSubview(browseButton)
        view.addSubview(resultContainerView)
        view.addSubview(bottomBannerView)
        
        // Set Up Ads
        let navHeight = navigationController?.navigationBar.frame.height
        let topHeight = navHeight! + 30
        
        self.addConstraints(format: "H:|-10-[v0]-10-|", views: placeHolderImage)
        self.addConstraints(format: "H:|-126-[v0]-126-|", views: browseButton)
        
        if #available(iOS 11.0, *){
            placeHolderImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            placeHolderImage.heightAnchor.constraint(equalToConstant: 250).isActive = true
            browseButton.topAnchor.constraint(equalTo: placeHolderImage.bottomAnchor, constant: 10).isActive = true
            browseButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
            resultContainerView.topAnchor.constraint(equalTo: browseButton.bottomAnchor, constant: 10).isActive = true
            bottomBannerView.topAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: 10).isActive = true
            bottomBannerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            bottomBannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }else{
            self.addConstraints(format: "V:|-\(topHeight)-[v0(250)]-10-[v1(48)]-10-[v2]-10-[v3(50)]|", views: placeHolderImage, browseButton, resultContainerView, bottomBannerView)
        }
        
        self.addConstraints(format: "H:|-10-[v0]-10-|", views: resultContainerView)
        self.addConstraints(format: "H:|[v0]|", views: bottomBannerView)
        self.addConstraints(format: "H:|[v0]|", views: bottomBannerView)
        
        // Result SubViews
        resultContainerView.addSubview(resultTableView)
        
        self.addConstraints(format: "H:|-0-[v0]-0-|", views: resultTableView)
        self.addConstraints(format: "V:|-0-[v0]-0-|", views: resultTableView)
        
        self.loadAds(bottomBannerView)
    }
    
    @objc func browseImage(_ sender:UIButton){
        let optionView = UIAlertController(title: "Browse Image...", message: "Please choose image source!", preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        //        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        optionView.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        optionView.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        optionView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(optionView, animated: true, completion: nil)
    }
    
    @objc private func previewImage(sender gesture:UITapGestureRecognizer){
        if isAllowedFullScreen{
            guard let previewImage = placeHolderImage.image else{ return }
            let photo = IDMPhoto(image: previewImage)
            let browser = IDMPhotoBrowser(photos: [photo!], animatedFrom: self.placeHolderImage)
            self.present(browser!, animated: true, completion: nil)
        }
    }
    
    private func predictionImage(_ image:UIImage){
        
        // Resize Image to 299 x 224
        guard let resizedImage = ImageProcessor.resizeImage(image) else{
            fatalError("Resize Image - Unexpected runtime error.")
        }
        
        // Convert Image to CVPixelBuffer
        guard let pixelBuffer = ImageProcessor.pixelBuffer(forImage: resizedImage.cgImage!) else{
            fatalError("Convert Image - Unexpected runtime error.")
        }
        
        // Predict Image
        guard let predicted = try? model.prediction(image: pixelBuffer) else{
            fatalError("Predict Image - Unexpected runtime error.")
        }
        
        let results = predicted.classLabel.split(separator: Character.init(","))
        
        self.results.results = []
        for s in results{
            self.results.results.append(s.description)
        }
        
        // Dismiss The loading
        self.dismissLoading {
            self.resultTableView.reloadData()
        }
        
    }
}

extension HomeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            placeHolderImage.image = pickedImage
            isAllowedFullScreen = true
            
            self.showLoading(message: "Predicting...", actionHandler: {
                picker.dismiss(animated: true){
                    self.predictionImage(pickedImage)
                }
            })
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = "No Prediction Result"
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes as? [NSAttributedStringKey : Any])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = "This allows you to transform picture to it's name. It mean that, when you don't know what the picture is, you can do let it done with this 🙂. Click the Browse... button to Get Started."
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(14.0)), NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.paragraphStyle: paragraph]
        return NSAttributedString(string: text, attributes: attributes as? [NSAttributedStringKey : Any])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resultCellID, for: indexPath)
        let result = results.results[indexPath.row]
        cell.textLabel?.text = result
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if results.results.count > 0{
            return results.headerTitle
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let word = results.results[indexPath.row]
        
        let optionView = UIAlertController(title: "Choose what you want to perform.", message: "", preferredStyle: .actionSheet)
        // Translate using google translate
        optionView.addAction(UIAlertAction(title: "Translate", style: .default, handler: { action in
            
            let translationOption = UIAlertController(title: "Choose language you want to translate.", message: "", preferredStyle: .actionSheet)
            
            for lang in self.translationLanguages{
                translationOption.addAction(UIAlertAction(title: lang.language, style: .default, handler: { (action) in
                    // Show Indicator
                    self.showLoading(message: "Translating", actionHandler: {
                        self.translationService?.translate(q: word, target: lang.code)
                    })
                    
                }))
            }
            
            translationOption.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(translationOption, animated: true, completion: nil)
        }))
        // Search with Google
        optionView.addAction(UIAlertAction(title: "Search with Google", style: .default, handler: { action in
            let vc = WebViewController()
            vc.wordToSearch = word
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        optionView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(optionView, animated: true, completion: nil)
    }
}

extension HomeViewController : TranslationServiceDelegate{
    
    func responseTranslatedResult(_ results: [TranslatedResult]) {
        // Stop Indicator
        self.dismissLoading {
            let vc = TranslatedViewController()
            vc.results = results
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func translationFail(_ message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController : GADBannerViewDelegate{
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bottomBannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.bottomBannerView.alpha = 1
        })
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
}
