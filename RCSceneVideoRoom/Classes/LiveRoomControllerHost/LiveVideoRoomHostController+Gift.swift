//
//  LiveVideoRoomHostController+Gift.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import UIKit

extension LiveVideoRoomHostController {
    
    @_dynamicReplacement(for: roomDidCreated)
    private func gift_roomDidCreated() {
        roomDidCreated()
        LiveVideoGiftManager.shared.refresh(room.roomId)
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func like_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        handleGiftMessage(message.content)
    }
    
    @objc func handleGiftButtonClick() {
        RCSensorAction.giftClick(room).trigger()
        SceneRoomManager.updateLiveSeatList()
        let users: [String] = {
            if RCLiveVideoEngine.shared().pkInfo != nil {
                return [room.userId]
            }
            var users: [String] = SceneRoomManager.shared.seats
                .compactMap { $0 }
                .filter { $0.count > 0 }
            users.removeAll(where: { $0 == room.userId })
            users.insert(room.userId, at: 0)
            return users
        }()
        let dependency = RCSceneGiftDependency(room: room,
                                                 seats: SceneRoomManager.shared.seats,
                                                 userIds: users)
        let vc = RCSceneGiftViewController(dependency: dependency, delegate: self)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
}

extension LiveVideoRoomHostController: RCSceneGiftViewControllerDelegate {
    func didSendGift(message: RCMessageContent) {
        if let msg = message as? RCChatroomSceneMessageProtocol {
            messageView.addMessage(msg)
        }
        handleGiftMessage(message)
    }
    
    private func handleGiftMessage(_ content: RCMessageContent?) {
        if let message = content as? RCChatroomGift {
            let value = message.price * message.number
            LiveVideoGiftManager.shared.updateGift([message.targetId: value])
        } else if let message = content as? RCChatroomGiftAll {
            let value = message.price * message.number
            var items = [String: Int]()
            RCLiveVideoEngine.shared()
                .currentSeats
                .map { $0.userId }
                .filter { $0.count > 0 }
                .forEach { userId in
                    items[userId] = value
                }
            LiveVideoGiftManager.shared.updateGift(items)
        } else {
            return
        }
        
        let count = LiveVideoGiftManager.shared.giftInfo[room.userId]
        roomGiftView.update("\(count ?? 0)")
    }
}

