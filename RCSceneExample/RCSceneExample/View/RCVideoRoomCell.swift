//
//  RCVideoRoomCell.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/29.
//

import UIKit
import Kingfisher
import RCSceneRoom

class RCVideoRoomCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    func updateUI(_ room: RCSceneRoom) -> RCVideoRoomCell {
        titleLabel.text = room.roomName
        avatarView.kf.setImage(with: URL(string: room.themePictureUrl ?? ""))
        return self
    }
}
