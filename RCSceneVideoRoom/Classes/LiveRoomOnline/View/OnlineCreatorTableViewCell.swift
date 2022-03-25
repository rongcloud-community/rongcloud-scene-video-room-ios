//
//  OnlineCreatorTableViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/9.
//

import UIKit
import Reusable
import RCSceneService

class OnlineCreatorTableViewCell: UITableViewCell, Reusable {
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.layer.cornerRadius = (48.resize)/2
        instance.clipsToBounds = true
        instance.image = RCSCAsset.Images.defaultAvatar.image
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var acceptButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = RCSCAsset.Colors.hexCDCDCD.color.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14)
        instance.setTitle("邀请PK", for: .normal)
        instance.layer.cornerRadius = 20
        instance.addTarget(self, action: #selector(handleAccpetButtonClick), for: .touchUpInside)
        instance.isUserInteractionEnabled = false
        return instance
    }()
    private lazy var lineView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return instance
    }()
    private var userId: String?
    var inviteCallback:((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildLayout() {
        backgroundColor = .clear
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(lineView)
        
        avatarImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(23.resize)
            $0.top.bottom.equalToSuperview().inset(8.resize)
            $0.size.equalTo(CGSize(width: 48.resize, height: 48.resize))
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarImageView.snp.right).offset(12.resize)
            $0.right.lessThanOrEqualTo(acceptButton.snp.left).offset(-4)
            $0.centerY.equalToSuperview()
        }
        
        acceptButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 64.resize, height: 40.resize))
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(23.resize)
        }
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.equalTo(avatarImageView.snp.right)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateCell(user: VoiceRoomUser?, selectingUserId: String?) {
        guard let user = user else {
            return
        }
        userId = user.userId
        nameLabel.text = user.userName
        avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: RCSCAsset.Images.defaultAvatar.image)
        if user.userId == selectingUserId {
            acceptButton.setTitle("已邀请", for: .normal)
        } else {
            acceptButton.setTitle("邀请PK", for: .normal)
        }
    }
    
    @objc func handleAccpetButtonClick() {
        guard let id = userId else {
            return
        }
        inviteCallback?(id)
    }
}
