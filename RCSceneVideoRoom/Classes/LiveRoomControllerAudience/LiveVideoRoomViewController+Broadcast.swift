//
//  LiveVideoRoomViewController+Broadcast.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/9.
//

import UIKit

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func broadcast_viewDidLoad() {
        m_viewDidLoad()
        RCBroadcastManager.shared.delegate = self
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func broadcast_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard message.content.isKind(of: RCGiftBroadcastMessage.self) else { return }
        let content = message.content as! RCGiftBroadcastMessage
        RCBroadcastManager.shared.add(content)
    }
}

extension LiveVideoRoomViewController: RCRTCBroadcastDelegate {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(roomUserView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    
    func broadcastViewAccessible(_ room: RCSceneRoom) -> Bool {
        if role == .broadcaster { return false }
        if self.room.roomId == room.roomId { return false }
        return true
    }
    
    func broadcastViewDidClick(_ room: RCSceneRoom) {
        if room.isPrivate == 1 {
            let controller = RCSRPasswordViewController()
            controller.completion = { [weak self] password in
                guard room.password == password else {
                    return SVProgressHUD.showError(withStatus: "密码错误")
                }
                self?.roomContainerAction?.switchRoom(room)
            }
            present(controller, animated: true)
        } else {
            roomContainerAction?.switchRoom(room)
        }
    }
}
