//
//  CreateViewController.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/31.
//

import UIKit

import RongRTCLib
import RCSceneRoom

class CreateViewController: UIViewController {
    
    private lazy var videoView = RCRTCVideoView()
    
    var roomID: String!
    
    private var isSquire: Bool = false
    
    private var liveInfo: RCRTCLiveInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: RCSCAsset.Images.rcBeautySwitchCamera.image,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(setMixConfig))

        // Do any additional setup after loading the view.
        videoView.fillMode = .aspectFill
        videoView.frameAnimated = false
        view.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        RCRTCEngine.sharedInstance().defaultVideoStream.startCapture()
        RCRTCEngine.sharedInstance().defaultVideoStream.setVideoView(videoView)
        
        let config = RCRTCRoomConfig()
        config.roomType = .live
        
        RCRTCEngine.sharedInstance().joinRoom(roomID, config: config) { room, code in
            guard code == .success else {
                return debugPrint("join rtc room failed: \(code.rawValue)")
            }
            room?.localUser.publishDefaultLiveStreams({ success, code, liveInfo in
                guard code == .success else {
                    return debugPrint("join rtc room failed: \(code.rawValue)")
                }
                self.liveInfo = liveInfo
            })
        }
        
        setMixSize(CGSize(width: 1280, height: 720))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        RCRTCEngine.sharedInstance().leaveRoom { success, code in
            debugPrint("leave RTC room \(code.rawValue)")
        }
    }
    
    @objc private func setMixConfig() {
        let size = CGSize(width: 720, height: isSquire ? 720 : 1280)
        isSquire.toggle()
        setMixSize(size)
    }
    
    private func setMixSize(_ size: CGSize) {
        /// 布局配置
        let config = RCRTCMixConfig()
        config.layoutMode = .custom
        config.customMode = true
        
        config.mediaConfig.videoConfig.videoLayout.width = Int(size.width)
        config.mediaConfig.videoConfig.videoLayout.height = Int(size.height)
        config.mediaConfig.videoConfig.videoLayout.fps = 15
        config.mediaConfig.videoConfig.videoLayout.bitrate = 2200
        config.mediaConfig.videoConfig.videoExtend.renderMode = .crop
        
        let layout = RCRTCCustomLayout()
        layout.x = 0
        layout.y = 0
        layout.width = Int(size.width)
        layout.height = Int(size.height)
        layout.videoStream = RCRTCEngine.sharedInstance().defaultVideoStream
        
        config.customLayouts = [layout]
        
        liveInfo?.setMixConfig(config, completion: { success, code in
            debugPrint("set mix confi \(code.rawValue)")
        })
    }
}
