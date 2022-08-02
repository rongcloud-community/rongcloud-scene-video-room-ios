//
//  LiveVideoRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/15.
//

import SVProgressHUD
import RCSceneKit
import Foundation
import UIKit

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var more_role: RCRTCLiveRoleType {
        get { role }
        set {
            role = newValue
            guard let containerVC = self.parent as? RCSPageContainerController else { return }
            switch role {
            case .broadcaster:
                navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                containerVC.setScrollable(false)
            case .audience:
                navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                containerVC.setScrollable(true)
            @unknown default: ()
            }
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func more_viewDidLoad() {
        m_viewDidLoad()
    }
}


extension LiveVideoRoomViewController: LiveVideoRoomMoreDelegate {
    func sceneRoom(_ view: RCLiveVideoRoomMoreView, didClick action: LiveVideoRoomMoreAction) {
        switch action {
        case .leave:
            leaveRoom()
        case .quit:
            closeRoomDidClick()
        case .minimize:
            if role == .broadcaster {
                return SVProgressHUD.showInfo(withStatus: "连麦中禁止此操作")
            }
            scaleRoomDidClick()
        }
    }
    
    func closeRoomDidClick() {
        let controller = UIAlertController(title: "提示", message: "确定结束本次连麦么？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        let sureAction = UIAlertAction(title: "确认", style: .default) { _ in
            RCSensorAction.connectionWithDraw(self.room).trigger()
            RCLiveVideoEngine.shared()
                .leaveLiveVideo({ [weak self] _ in
                    self?.liveVideoDidFinish(.leave)
                })
        }
        controller.addAction(sureAction)
        present(controller, animated: true)
    }
    
    func scaleRoomDidClick() {
        let vc: UIViewController = parent ?? self
        RCSPageFloaterManager.shared().show(with: vc,
                                            avatarImgUrl: room.themePictureUrl,
                                            customContentView: self.makeCustomContentView(self.previewView),
                                            animated: true)
        needHandleFloatingBack = true
        backTrigger(false)
        guard let containerVC = vc as? RCSPageContainerController else { return }
        guard let delegate = containerVC.delegate else { return }
        RCSPageFloaterManager.shared().multiDelegates = NSArray(objects: delegate) as! [Any]
    }
    
    func makeCustomContentView(_ superView: UIView) -> UIView {
        superView.addSubview(self.closeButton)
        return superView
    }
    
    @objc func close() {
        leaveRoom({ [weak self] result in
            self?.closeButton.removeFromSuperview()
            RCSPageFloaterManager.shared().hide()
        })
    }
}

extension UIViewController {
    @objc
    func backTrigger(_ animated: Bool = true) {
        guard let controller = navigationController else {
            return dismiss(animated: animated)
        }
        if controller.viewControllers.first == self {
            return dismiss(animated: animated)
        }
        controller.popViewController(animated: animated)
    }
}
