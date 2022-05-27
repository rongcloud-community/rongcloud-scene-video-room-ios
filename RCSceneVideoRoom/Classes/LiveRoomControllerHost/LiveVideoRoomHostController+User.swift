//
//  LiveVideoRoomHostController+User.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import UIKit

extension LiveVideoRoomHostController {
    @objc func liveVideoRequestDidClick() {
        switch micButton.micState {
        case .user:
            let controller = RCLVMicViewController()
            controller.delegate = self
            present(controller, animated: true)
        case .waiting:
            let controller = RCLVRCancelMicViewController(.invite, delegate: self)
            present(controller, animated: true)
        case .connecting:
            let controller = RCLVRCancelMicViewController(.connection, delegate: self)
            present(controller, animated: true)
        default: ()
        }
    }
}

extension LiveVideoRoomHostController: RCLiveVideoCancelDelegate {
    func didCancelLiveVideo(_ action: RCLVRCancelMicType) {
        switch action {
        case .request: ()
        case .invite:
            RCLiveVideoEngine.shared().getInvitations { code, userIds in
                guard let userId = userIds.first else { return }
                RCLiveVideoEngine.shared().cancelInvitation(userId) { _ in
                    /// code
                }
            }
            micButton.micState = .user
        case .connection:
            let seat = RCLiveVideoEngine.shared().currentSeats.last { $0.userId.count > 0 }
            guard
                let userId = seat?.userId,
                userId != Environment.currentUserId
            else { return }
            RCLiveVideoEngine.shared()
                .kickUser(fromSeat:userId, completion: { code in
                    debugPrint("kickUser \(code.rawValue)")
                })
            micButton.micState = .user
        }
    }
}

extension LiveVideoRoomHostController: RCLVMicViewControllerDelegate {
    func didAcceptSeatRequest(_ user: RCSceneRoomUser) {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne:
            micButton.micState = .connecting
        default:
            micButton.micState = .user
        }
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.micButton.setBadgeCount(userIds.count)
        }
    }
    
    func didRejectRequest(_ user: RCSceneRoomUser) {
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.micButton.setBadgeCount(userIds.count)
        }
    }
    
    func didSendInvitation(_ user: RCSceneRoomUser) {
        switch RCLiveVideoEngine.shared().currentMixType{
        case .oneToOne:
            micButton.micState = .waiting
        default:
            micButton.micState = .user
        }
    }
    
    func didSwitchMixType(_ type: RCLiveVideoMixType) {
        RCLiveVideoEngine.shared().setMixType(type) { [weak self] code in
            switch code {
            case .success:
                debugPrint("switch success")
                let message = RCTextMessage(content: "麦位布局已修改，请重新上麦")!
                message.extra = "mixTypeChange"
                RCLiveVideoEngine.shared().sendMessage(message) { code in
                    self?.chatroomView.messageView.addMessage(message)
                }
            case .mixSame: ()
            case .pKing:
                SVProgressHUD.showError(withStatus: "当前 PK 中，无法进行此操作")
            default:
                SVProgressHUD.showError(withStatus: "切换布局失败")
            }
        }
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension LiveVideoRoomHostController: RCSceneRoomUserOperationProtocol {
    /// 踢出房间
    func kickOutRoom(userId: String) {
        presentedViewController?.dismiss(animated: true)
        RCLiveVideoEngine.shared().kickOutRoom(userId) { [weak self] code in
            self?.handleKickOutRoom(userId, by: Environment.currentUserId)
        }
    }
    
    /// 抱下麦
    func kickUserOffSeat(seatIndex: UInt) {
        presentedViewController?.dismiss(animated: true)
        let userId = SceneRoomManager.shared.seats[Int(seatIndex)]
        RCLiveVideoEngine.shared().kickUser(fromSeat:userId) { code in
            if code == .success {
                SVProgressHUD.showSuccess(withStatus: "抱下麦成功")
            } else {
                SVProgressHUD.showError(withStatus: "抱下麦失败")
            }
        }
    }
    
    func didSetManager(userId: String, isManager: Bool) {
        RCSceneUserManager.shared.fetchUserInfo(userId: userId) { user in
            let event = RCChatroomAdmin()
            event.userId = user.userId
            event.userName = user.userName
            event.isAdmin = isManager
            ChatroomSendMessage(event) { result in
                switch result {
                case .success:
                    self.messageView.addMessage(event)
                    if isManager {
                        self.managers.append(user)
                    } else {
                        self.managers.removeAll(where: { $0.userId == userId })
                    }
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        }
        if isManager {
            SVProgressHUD.showSuccess(withStatus: "已设为管理员")
        } else {
            SVProgressHUD.showSuccess(withStatus: "已撤回管理员")
        }
    }
    
    func didClickedPrivateChat(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedPrivateChat(userId: userId)
            }
            return
        }
        ChatViewController.presenting(self, userId: userId)
    }
    
    func didClickedSendGift(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedSendGift(userId: userId)
            }
            return
        }
        
        SceneRoomManager.updateLiveSeatList()
        
        let dependency = RCSceneGiftDependency(room: room,
                                                 seats: SceneRoomManager.shared.seats,
                                                 userIds: [userId])
        let vc = RCSceneGiftViewController(dependency: dependency, delegate: self)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        RCSceneUserManager.shared.refreshUserInfo(userId: userId) { followUser in
            guard isFollow else { return }
            RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                ChatroomSendMessage(message) { result in
                    switch result {
                    case .success:
                        self?.messageView.addMessage(message)
                    case .failure(let error):
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func didClickedInvite(userId: String) {
        RCLiveVideoEngine.shared().inviteLiveVideo(userId, at: -1) { [weak self] code in
            switch code {
            case .success:
                if RCLiveVideoEngine.shared().currentMixType == .oneToOne {
                    self?.micButton.micState = .waiting
                }
                SVProgressHUD.showSuccess(withStatus: "已邀请上麦")
            default:
                SVProgressHUD.showError(withStatus: "邀请失败")
            }
        }
    }
}
