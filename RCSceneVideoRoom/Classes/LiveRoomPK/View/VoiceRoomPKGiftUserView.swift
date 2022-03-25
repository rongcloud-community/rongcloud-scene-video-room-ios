//
//  VoiceRoomPKGiftView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/11.
//

import UIKit

struct PKViewConstants {
    static let countdown = 180
    static let leftColor = UIColor(hexString: "#E92B88")
    static let rightColor = UIColor(hexString: "#505DFF")
}

class VoiceRoomPKGiftUserView: UIView {
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.layer.cornerRadius = 13
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        instance.image = RCSCAsset.Images.pkSeatDefaultSofa.image
        instance.clipsToBounds = true
        return instance
    }()
    private lazy var rankLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 8)
        instance.textColor = .white
        return instance
    }()
    private lazy var rankBgImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        return instance
    }()
    
    
    init(isLeft: Bool, rank: Int, frame: CGRect = .zero) {
        super.init(frame: frame)
        buildLayout()
        rankBgImageView.image = isLeft ?
        RCSCAsset.Images.leftRankBg.image :
        RCSCAsset.Images.rightRankBg.image
        avatarImageView.layer.borderColor = isLeft ? PKViewConstants.leftColor.cgColor : PKViewConstants.rightColor.cgColor
        rankLabel.text = "\(rank)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        addSubview(avatarImageView)
        avatarImageView.addSubview(rankBgImageView)
        rankBgImageView.addSubview(rankLabel)
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 26, height: 26))
            make.edges.equalToSuperview()
        }
        
        rankBgImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        rankLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func updateUser(user: PKSendGiftUser?) {
        guard let user = user else {
            avatarImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            avatarImageView.image = RCSCAsset.Images.pkSeatDefaultSofa.image
            return
        }
        let portraitURLString = Environment.url.absoluteString + "file/show?path=" + user.portrait
        avatarImageView.kf.setImage(with: URL(string: portraitURLString),
                                    placeholder: RCSCAsset.Images.defaultAvatar.image)
    }
}
