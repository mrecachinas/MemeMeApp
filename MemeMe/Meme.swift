//
//  Meme.swift
//  MemeMe
//
//  Created by Michael Recachinas on 7/22/15.
//  Copyright (c) 2015 Michael Recachinas. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: NSString!
    var bottomText: NSString!
    var image: UIImage!
    var memedImage: UIImage!
    
    init(topText: NSString, bottomText: NSString, image: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
}