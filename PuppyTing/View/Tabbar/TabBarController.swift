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
        self.tabBar.tintColor = .puppyPurple
        
        let tingVC = UINavigationController(rootViewController: TingViewController())
        tingVC.tabBarItem = UITabBarItem(
            title: "퍼피팅",
            image: UIImage(systemName: "dog"),
            tag: 0
        )
        
        let chatVC = UINavigationController(rootViewController: ChatListViewController())
        chatVC.tabBarItem = UITabBarItem(
            title: "채팅",
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            tag: 1
        )
        
        let myPageVC = UINavigationController(rootViewController: MypageViewController())
        myPageVC.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            tag: 2
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
