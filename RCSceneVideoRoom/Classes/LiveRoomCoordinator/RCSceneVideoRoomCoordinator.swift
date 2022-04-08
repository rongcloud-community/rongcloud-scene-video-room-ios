//
//  RCSceneVideoRoomCoordinator.swift
//  RCSceneVideoRoom
//
//  Created by xuefeng on 2022/2/22.
//

import UIKit
import XCoordinator

import RCSceneRoom

public var videoRouter: StrongRouter<VideoRoomRouter>!

public enum VideoRoomRouter: Route {
    case inputPassword(delegate: RCSceneRoomSettingProtocol?)
    case notice(modify: Bool = false, notice: String, delegate: RCSceneRoomSettingProtocol)
    case userList(room: RCSceneRoom, delegate: RCSceneRoomUserOperationProtocol)
    case manageUser(dependency: RCSceneRoomUserOperationDependency, delegate: RCSceneRoomUserOperationProtocol?)
    case gift(dependency: RCSceneGiftDependency, delegate: RCSceneGiftViewControllerDelegate)
    case chatList
    case chat(userId: String)
}

public class VideoRoomCoordinator: NavigationCoordinator<VideoRoomRouter> {
    
    public init(rootViewController: UINavigationController) {
        super.init(rootViewController: rootViewController)
        videoRouter = strongRouter
    }
    
    public override func prepareTransition(for route: VideoRoomRouter) -> NavigationTransition {
        switch route {
        case let .inputPassword(delegate):
            let vc = PasswordViewController(delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case let .userList(room, delegate):
            let vc = RCSceneRoomUsersViewController(room: room, delegate: delegate)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            nav.modalTransitionStyle = .coverVertical
            nav.modalPresentationStyle = .overFullScreen
            return .present(nav)
        case let .manageUser(dependency, delegate):
            let vc = RCSceneRoomUserOperationViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return .present(vc)
        case let .gift(dependency, delegate):
            let vc = RCSceneGiftViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case .chatList:
            let vc = ChatListViewController(.ConversationType_PRIVATE)
            vc.canCallComing = false
            return .show(vc)
        case let .chat(userId):
            let vc = ChatViewController(.ConversationType_PRIVATE, userId: userId)
            vc.canCallComing = false
            return .show(vc)
        case .notice(modify: let modify, notice: let notice, delegate: let delegate):
            let vc = NoticeViewController(modify, notice: notice, delegate: delegate)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.hidesBottomBarWhenPushed = true
            return .present(vc)
        }
    }
}
