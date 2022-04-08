//
//  LiveVideoResultView.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/31.
//

import UIKit
import SVProgressHUD


class LiveVideoPKResultView: UIView {
    
    private lazy var winnerView = LiveVideoPKResultAvatarView()
    private lazy var loserView = LiveVideoPKResultAvatarView()
    
    private lazy var drawImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = RCSCAsset.Images.pkTieIcon.image
        return instance
    }()
    
    func update(_ result: LiveVideoPKResult) {
        switch result {
        case .win: setupWinnerUI()
        case .lose: setupLoserUI()
        case .draw: setupDrawUI()
        }
    }

    private func setupWinnerUI() {
        addSubview(winnerView)
        addSubview(loserView)
        winnerView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview().offset(20)
        }
        loserView.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview().offset(20)
        }
        if let PK = RCLiveVideoEngine.shared().pkInfo {
            updateUserAvatar([PK.roomUserId(), PK.otherRoomUserId()])
        }
        SVProgressHUD.showInfo(withStatus: "我方 PK 胜利")
    }
    
    private func setupLoserUI() {
        addSubview(winnerView)
        addSubview(loserView)
        winnerView.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview().offset(20)
        }
        loserView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview().offset(20)
        }
        if let PK = RCLiveVideoEngine.shared().pkInfo {
            updateUserAvatar([PK.otherRoomUserId(), PK.roomUserId()])
        }
        SVProgressHUD.showInfo(withStatus: "我方 PK 失败")
    }
    
    private func setupDrawUI() {
        addSubview(drawImageView)
        drawImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
    }
    
    private func updateUserAvatar(_ userIds: [String]) {
        winnerView.updatePKResult(result: .win)
        loserView.updatePKResult(result: .lose)
        RCSceneUserManager.shared.fetch(userIds) { users in
            guard
                let winner = users.first,
                let loser = users.last
            else { return }
            self.winnerView.updateUser(winner)
            self.loserView.updateUser(loser)
        }
    }
}

class LiveVideoPKResultAvatarView: UIView {
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.layer.cornerRadius = 34.resize
        instance.image = RCSCAsset.Images.defaultAvatar.image
        return instance
    }()
    private lazy var borderImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = RCSCAsset.Images.gradientBorder.image
        return instance
    }()
    private lazy var pkCrownImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = RCSCAsset.Images.pkCrownIcon.image
        instance.isHidden = true
        return instance
    }()
    private lazy var pkBottomImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = nil
        instance.isHidden = true
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatarImageView)
        addSubview(borderImageView)
        addSubview(pkCrownImageView)
        addSubview(pkBottomImageView)
        
        avatarImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 68.resize, height: 68.resize))
            $0.top.left.right.equalToSuperview().inset(2)
        }
        
        borderImageView.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
        
        pkBottomImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(10)
        }
        
        pkCrownImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(avatarImageView.snp.top).offset(7)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUser(_ user: RCSceneRoomUser) {
        avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: RCSCAsset.Images.defaultAvatar.image)
    }
    
    func updatePKResult(result: LiveVideoPKResult) {
        switch result {
        case .win:
            pkCrownImageView.isHidden = false
            pkBottomImageView.isHidden = false
            pkBottomImageView.image = RCSCAsset.Images.pkWinningIcon.image
        case .lose:
            pkCrownImageView.isHidden = true
            pkBottomImageView.isHidden = false
            pkBottomImageView.image = RCSCAsset.Images.pkFailedIcon.image
        case .draw: ()
        }
    }
}
