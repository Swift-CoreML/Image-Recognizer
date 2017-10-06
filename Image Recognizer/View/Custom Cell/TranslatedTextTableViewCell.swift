//
//  TranslatedTextTableViewCell.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 6/19/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import UIKit

class TranslatedTextTableViewCell: UITableViewCell {
    
    var translatedTextView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(){
        self.addSubview(translatedTextView)
        
        self.addConstraintWithFormat(format: "H:|-[v0]-|", views: translatedTextView)
        self.addConstraintWithFormat(format: "V:|-[v0]-|", views: translatedTextView)
    }
}
