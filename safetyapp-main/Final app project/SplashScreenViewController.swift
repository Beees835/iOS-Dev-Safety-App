//
//  SplashScreenViewController.swift
//  Final app project
//
//  Created by Beees on 23/5/2023.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage(named: "AppIcon") // Make sure to add your image in Assets.xcassets
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)

        // Time delay in seconds
        let delayInSeconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            // Here you can instantiate and present your main view controller
            // Make sure to replace "MainViewController" with your view controller
            let vc = initialPageViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}

