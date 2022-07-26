//
//  RCSceneVideoRoom+Chat.swift
//  Alamofire
//
//  Created by shaoshuai on 2022/5/25.
//

import RCSceneRoom

extension ChatListViewController {
    @discardableResult
    static func presenting(_ controller: UIViewController,
                           animated: Bool = true) -> UINavigationController {
        let vc = ChatListViewController(.ConversationType_PRIVATE)
        vc.canCallComing = false
        let navigation = UINavigationController(rootViewController: vc)
        navigation.modalTransitionStyle = .coverVertical
        navigation.modalPresentationStyle = .overFullScreen
        vc.navigationItem.leftBarButtonItem = {
            let image = RCSCAsset.Images.backIndicatorImage.image
                .withRenderingMode(.alwaysTemplate)
            let action = #selector(backTrigger)
            let instance = UIBarButtonItem(image: image,
                                           style: .plain,
                                           target: navigation,
                                           action: action)
            instance.tintColor = .black
            return instance
        }()
        controller.present(navigation, animated: animated)
        return navigation
    }
}

extension ChatViewController {
    static func presenting(_ controller: UIViewController, userId: String) {
        let vc = ChatListViewController(.ConversationType_PRIVATE)
        vc.canCallComing = false
        let navigation = UINavigationController(rootViewController: vc)
        navigation.modalTransitionStyle = .coverVertical
        navigation.modalPresentationStyle = .overFullScreen
        vc.navigationItem.leftBarButtonItem = {
            let image = RCSCAsset.Images.backIndicatorImage.image
                .withRenderingMode(.alwaysTemplate)
            let action = #selector(backTrigger)
            let instance = UIBarButtonItem(image: image,
                                           style: .plain,
                                           target: navigation,
                                           action: action)
            instance.tintColor = .black
            return instance
        }()
        let chatController = ChatViewController(.ConversationType_PRIVATE, userId: userId)
        navigation.pushViewController(chatController, animated: false)
        controller.present(navigation, animated: true)
    }
}
