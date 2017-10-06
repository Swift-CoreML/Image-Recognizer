//
//  Configuration.swift
//  Image Recognizer
//
//  Created by LUN Sovathana on 9/28/17.
//  Copyright © 2017 Lun Sovathana. All rights reserved.
//

import Foundation

enum Environment{
    case dev
    case prod
}

class Configuration {
    static var env : Environment{
        return .dev
    }
}
