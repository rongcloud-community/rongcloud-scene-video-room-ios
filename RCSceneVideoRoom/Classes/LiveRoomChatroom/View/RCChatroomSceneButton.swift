//
//  RCChatroomSceneButton.swift
//  RCE
//
//  Created by shaoshuai on 2021/11/4.
//

import UIKit

enum RCChatroomSceneButtonType {
    case pk
    case mic
    case gift
    case message
    case setting
    
    var image: UIImage? {
        switch self {
        case .pk: return RCSCAsset.Images.voiceroomPkButton.image
        case .mic: return RCSCAsset.Images.voiceRoomMicOrderIcon.image
        case .gift: return RCSCAsset.Images.voiceRoomGiftIcon.image
        case .message: return RCSCAsset.Images.voiceRoomMessageIcon.image
        case .setting: return RCSCAsset.Images.voiceRoomSettingIcon.image
        }
    }
}

enum RCChatroomSceneMicState {
    case user
    case request
    case waiting
    case connecting
    var image: UIImage? {
        switch self {
        case .user: return RCSCAsset.Images.voiceRoomMicOrderIcon.image
        case .request: return RCSCAsset.Images.connectMicStateNone.image
        case .waiting: return RCSCAsset.Images.connectMicStateWaiting.image
        case .connecting: return RCSCAsset.Images.connectMicStateConnecting.image
        }
    }
}

enum RCChatroomScenePKState {
    case request
    case waiting(otherRoomId: String, otherRoomUserId: String)
    case connecting(otherRoomId: String, otherRoomUserId: String)
    var image: UIImage? {
        switch self {
        case .request: return RCSCAsset.Images.voiceroomPkButton.image
        case .waiting: return RCSCAsset.Images.connectMicStateWaiting.image
        case .connecting: return RCSCAsset.Images.pkOngoingIcon.image
        }
    }
}

class RCChatroomSceneButton: UIButton {
    
    private lazy var badgeView = RCSceneRoomBageView()
    var badgeCount: Int { badgeView.count }
    
    var micState: RCChatroomSceneMicState = .user {
        didSet {
            hideBadgeIfNeeded()
            setImage(micState.image, for: .normal)
        }
    }
    
    var pkState: RCChatroomScenePKState = .request {
        didSet {
            setImage(pkState.image, for: .normal)
        }
    }

    private let type: RCChatroomSceneButtonType
    init(_ type: RCChatroomSceneButtonType) {
        self.type = type
        super.init(frame: .zero)
        setImage(type.image, for: .normal)
        addSubview(badgeView)
        badgeView.snp.makeConstraints { make in
            make.centerX.equalTo(snp.right).offset(-4)
            make.centerY.equalTo(snp.top).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBadgeCount(_ count: Int) {
        badgeView.update(count)
        hideBadgeIfNeeded()
    }
    
    private func hideBadgeIfNeeded() {
        guard type == .mic else { return }
        switch micState {
        case .user, .request:
            badgeView.isHidden = badgeCount == 0
        case .waiting, .connecting:
            badgeView.isHidden = true
        }
    }
}

extension RCChatroomSceneButton {
    func refreshMessageCount() {
        let unreadCount = RCIMClient.shared()
            .getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
        setBadgeCount(Int(unreadCount))
    }
}
