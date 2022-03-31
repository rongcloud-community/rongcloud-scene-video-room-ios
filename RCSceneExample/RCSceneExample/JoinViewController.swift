//
//  JoinViewController.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/31.
//

import UIKit

import RongRTCLib

class JoinViewController: UIViewController {
    
    private lazy var videoView = RCRTCVideoView()
    
    var roomID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black

        // Do any additional setup after loading the view.
        view.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let config = RCRTCRoomConfig()
        config.roomType = .live
        config.roleType = .audience
        
        RCRTCEngine.sharedInstance().joinRoom(roomID, config: config) { room, code in
            guard code == .success else {
                return debugPrint("join rtc room failed: \(code.rawValue)")
            }
            guard let CDNStream = room?.getCDNStream() else {
                return debugPrint("room CDN stream nil")
            }
            CDNStream.setVideoView(self.videoView)
            room?.localUser.subscribeStream([CDNStream], tinyStreams: []) { success, code in
                guard code == .success else {
                    return debugPrint("subscribe CDN stream failed: \(code.rawValue)")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        RCRTCEngine.sharedInstance().leaveRoom { success, code in
            debugPrint("leave RTC room \(code.rawValue)")
        }
    }
}
