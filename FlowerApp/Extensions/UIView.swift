//
//  UIView.swift
//  FlowerApp
//
//  Created by mahmoud on 09/02/2024.
//

import Foundation
import UIKit

extension UIViewController {
    
    static var identifiere: String {
        return String(describing: self)
    }
    
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: identifiere) as! Self
    }
}
