//
//  UIColorExtensions.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/24/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(segment: Int) {
        switch segment {
        case 0:
            self.init(displayP3Red: 0.96, green: 0.46, blue: 0.27, alpha: 1.0)
        case 1:
            self.init(displayP3Red: 0.15, green: 0.73, blue: 0.93, alpha: 1.0)
        case 2:
            self.init(displayP3Red: 0.38, green: 0.64, blue: 0.53, alpha: 1.0)
        case 3:
            self.init(displayP3Red: 0.39, green: 0.36, blue: 0.91, alpha: 1.0)
        default:
            if UIViewController().traitCollection.userInterfaceStyle == .dark {
                self.init(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                self.init(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            }
        }
    }
}
