//
//  TranslationService.swift
//  Image Recognizer
//
//  Created by Lun Sovathana on 6/19/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import Foundation

protocol TranslationServiceDelegate {
    func responseTranslatedResult(_ results: [TranslatedResult])
    func translationFail(_ message:String)
}

class TranslationService{
    
    var delegate:TranslationServiceDelegate?
    
    func translate(q:String, target:String){
        // trim beginning and ending space
        var newQ = q.trimmingCharacters(in: .whitespacesAndNewlines)
        // replace space with + character
        newQ = newQ.replacingOccurrences(of: " ", with: "+")
        let urlString = "\(Translate_URL)?key=\(API_KEY)&target=\(target)&q=\(newQ)"
        print("urlString", urlString)
        guard let url = URL(string: urlString) else{
            fatalError("Error occured during creating url.")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if(error != nil){
                print("error", error?.localizedDescription ?? "")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    if let data = json["data"] as? [String:AnyObject]{
                        if let arr = data["translations"] as? [Any], let translations = arr.first as? [String:Any]{
                            var results : [TranslatedResult] = []
                            results.append(TranslatedResult(headerText: "Source Text", resultText: q))
                            results.append(TranslatedResult(headerText: "Locale", resultText: target))
                            results.append(TranslatedResult(headerText: "Translated Text", resultText: translations["translatedText"] as! String))
                            self.delegate?.responseTranslatedResult(results)
                        }
                    }
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }.resume()
    }
}
