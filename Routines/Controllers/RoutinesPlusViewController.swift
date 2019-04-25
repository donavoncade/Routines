//
//  RoutinesPlusViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/24/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import SwiftMessages
import SwiftTheme
import UIKit

class RoutinesPlusViewController: UIViewController {
    @IBOutlet var paymentTermsLabel: UILabel!
    @IBOutlet var paymentScrollView: UIScrollView!
    @IBOutlet var paymentStackView: UIStackView!
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var gradientView: UIView!

    @IBOutlet var routinesPlusLabel: UILabel!
    @IBOutlet var routinesLabelPlusSymbol: UILabel!

    @IBOutlet var paymentButtons: [UIButton]!

    @IBOutlet var monthlyButton: UIButton!
    @IBOutlet var yearlyButton: UIButton!
    @IBOutlet var lifetimeButton: UIButton!

    @IBOutlet var restoreButton: UIButton!
    @IBAction func restoreButtonTapped(_: UIButton) {
        restorePurchase()
    }

    @IBAction func monthlyButtonTapped(_: UIButton) {
        purchase(purchase: .monthly)
    }

    @IBAction func yearlyButtonTapped(_: UIButton) {
        purchase(purchase: .yearly)
    }

    @IBAction func lifetimeButtonTapped(_: UIButton) {
        purchase(purchase: .lifetime)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getPrices()
        #if DEBUG
            print("routines plus view loaded")
        #endif
        // Do stuff
        setUpUI()
    }

    var monthlyPrice = ""
    var yearlyPrice = ""
    var lifetimePrice = ""

    func getPrices() {
        AppDelegate.productInfo?.retrievedProducts.forEach { product in
            if product.productIdentifier == RegisteredPurchase.monthly.rawValue {
                monthlyPrice = product.localizedPrice ?? "Failed to fetch price"
            } else if product.productIdentifier == RegisteredPurchase.yearly.rawValue {
                yearlyPrice = product.localizedPrice ?? "Failed to fetch price"
            } else if product.productIdentifier == RegisteredPurchase.lifetime.rawValue {
                lifetimePrice = product.localizedPrice ?? "Failed to fetch price"
            }
        }
    }

    func setButtonText() {
        #if DEBUG
            print("setting prices on buttons")
        #endif
        monthlyButton.setTitle("\(monthlyPrice) / Month", for: .normal)
        yearlyButton.setTitle("\(yearlyPrice) / Year", for: .normal)
        lifetimeButton.setTitle("\(lifetimePrice) / Lifetime", for: .normal)
    }

    func setUpUI() {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            gradientView.backgroundColor = .clear
        default:
            let gradient = CAGradientLayer()
            gradient.frame = gradientView.bounds
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.locations = [0.5, 0.85]
            gradientView.layer.mask = gradient
        }

//        let windowHeight = UIScreen.main.bounds.height

//        if UIDevice.current.userInterfaceIdiom == .phone {
//            preferredContentSize = .init(width: 0, height: windowHeight * 0.9)
//        }

        paymentScrollView.contentInset.bottom = 40

        let titleColor = UIColor(rgba: "#645be7", defaultColor: .white)
        let shadowColor = UIColor(rgba: "#645be7", defaultColor: .white)
        routinesLabelPlusSymbol.textColor = titleColor
        routinesPlusLabel.textColor = titleColor
        routinesLabelPlusSymbol.layer.shadowColor = shadowColor.cgColor
        routinesLabelPlusSymbol.layer.shadowRadius = 7
        routinesLabelPlusSymbol.layer.shadowOpacity = 1
        routinesLabelPlusSymbol.layer.shadowOffset = CGSize(width: 0, height: 0)
        routinesLabelPlusSymbol.layer.masksToBounds = false

        paymentButtons.forEach { button in
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 12
            button.backgroundColor = titleColor
        }
        yearlyButton.layer.shadowColor = shadowColor.cgColor
        yearlyButton.layer.shadowRadius = 16
        yearlyButton.layer.shadowOpacity = 1
        yearlyButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        yearlyButton.layer.masksToBounds = false

        restoreButton.setTitleColor(titleColor, for: .normal)

        setButtonText()
    }
}