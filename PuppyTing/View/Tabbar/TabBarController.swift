//
//  TabBarController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = .puppyPurple
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.tabBar.layer.shadowRadius = 6
        self.tabBar.layer.shadowOpacity = 0.1
        
        let tingVC = UINavigationController(rootViewController: TingViewController())
        tingVC.tabBarItem = UITabBarItem(
            title: "퍼피팅",
            image: UIImage(named: "dogDefault"),
            selectedImage: UIImage(named: "dogTinted")
        )
        
        let chatVC = UINavigationController(rootViewController: ChatListViewController())
        chatVC.tabBarItem = UITabBarItem(
            title: "채팅",
            image: UIImage(named: "chatDefault"),
            selectedImage: UIImage(named: "chatTinted")
        )
        
        let myPageVC = UINavigationController(rootViewController: MypageViewController())
        myPageVC.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(named: "myPageDefault"),
            selectedImage: UIImage(named: "myPageTinted")
        )
        
        self.setViewControllers([tingVC, chatVC, myPageVC], animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToMyPageTab), name: NSNotification.Name("SwitchToMyPage"), object: nil)
    }
    
    @objc func switchToMyPageTab() {
        self.selectedIndex = 2
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
