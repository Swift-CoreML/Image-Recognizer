//
//  HomeViewController.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 6/12/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import UIKit
private let resultCellID = "ResultCell"
class HomeViewController: UIViewController {
    
    private var placeHolderImage : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "placeholder")
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
    
    private let model = Inceptionv3()
    
    private var results = ClassResult(headerTitle: "Predicted Results", results: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        resultTableView.register(UITableViewCell.self, forCellReuseIdentifier: resultCellID)
    }
    
    fileprivate func setupViews() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Image Recognizer"
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(placeHolderImage)
        view.addSubview(browseButton)
        view.addSubview(resultContainerView)
        
        let views : [String:Any] = ["placeHolderImage" : placeHolderImage, "browseButton" : browseButton, "resultContainerView" : resultContainerView]
        let navHeight = navigationController?.navigationBar.frame.height
        let topHeight = navHeight! + 85
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[placeHolderImage]-10-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-126-[browseButton]-126-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(topHeight)-[placeHolderImage(250)]-10-[browseButton(48)]-10-[resultContainerView]-10-|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[resultContainerView]-10-|", options: [], metrics: nil, views: views))
        
        // Result SubViews
        //resultContainerView.addSubview(resultLabel)
        resultContainerView.addSubview(resultTableView)
        
        let resultSubViews : [String:Any] = ["resultLabel" : resultLabel, "resultTableView" : resultTableView]
        
        //NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[resultLabel]-0-|", options: [], metrics: nil, views: resultSubViews))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[resultTableView]-0-|", options: [], metrics: nil, views: resultSubViews))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[resultTableView]-0-|", options: [], metrics: nil, views: resultSubViews))
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
        
        self.present(optionView, animated: true, completion: nil)
    }
    
    func predictionImage(_ image:UIImage){
        
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
        print("result", results)
        
        self.results.results = []
        for s in results{
            self.results.results.append(s.description)
        }
        self.resultTableView.reloadData()
        
    }
}

extension HomeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            placeHolderImage.image = pickedImage
            
            predictionImage(pickedImage)
            
            picker.dismiss(animated: true, completion: nil)
            
        }
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
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
        return results.headerTitle
    }
}
