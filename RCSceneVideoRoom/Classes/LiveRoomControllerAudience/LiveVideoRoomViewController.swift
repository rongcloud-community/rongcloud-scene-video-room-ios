//
//  LiveVideoRoomViewController.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/13.
//

import UIKit
import RCSceneRoom

class LiveVideoRoomViewController: RCLiveModuleViewController {
    
    /// 管理员
    dynamic var managers = [RCSceneRoomUser]()
    
    /// 主播美颜
    var beautyPlugin: RCBeautyPluginDelegate?
    
    private let musicInfoBubbleView = RCMusicEngine.musicInfoBubbleView
    
    private lazy var gradientLayer: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.colors = [
            UIColor(byteRed: 70, green: 42, blue: 79).cgColor,
            UIColor(byteRed: 26, green: 29, blue: 61).cgColor
        ]
        instance.locations = [0, 0.89]
        instance.startPoint = CGPoint(x: 0.25, y: 0.5)
        instance.endPoint = CGPoint(x: 0.75, y: 0.5)
        return instance
    }()
    
    private(set) lazy var previewView = LiveVideoRoomPreviewView()
    private(set) lazy var seatView = UIView()
    private(set) lazy var roomUserView = LiveVideoRoomUserView()
    private(set) lazy var roomCountingView = LiveVideoRoomCountingView()
    private(set) lazy var roomNoticeView = SceneRoomNoticeView()
    private(set) lazy var roomGiftView = SceneRoomMarkView()
    private(set) lazy var roomMoreView = RCLiveVideoRoomMoreView()
    private(set) lazy var chatroomView = RCChatroomSceneView()

    private(set) lazy var micButton = RCChatroomSceneButton(.mic)
    private(set) lazy var giftButton = RCChatroomSceneButton(.gift)
    private(set) lazy var messageButton = RCChatroomSceneButton(.message)
    
    lazy var PKView = LiveVideoRoomPKView()
    
    dynamic var role: RCRTCLiveRoleType = .audience
    
    var isSeatFreeEnter: Bool = false
    
    var floatingManager: RCSceneRoomFloatingProtocol?
    
    weak var roomContainerAction: RCRoomContainerAction?
    
    var needHandleFloatingBack = false
    
    var room: RCSceneRoom
    
    init(_ room: RCSceneRoom) {
        self.room = room
        self.role = room.isOwner ? .broadcaster : .audience
        super.init(nibName: nil, bundle: nil)
        SceneRoomManager.shared.forbiddenWords = []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("LVRV deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        RCIM.shared().addReceiveMessageDelegate(self)
        RCSceneMusic.join(room, bubbleView: musicInfoBubbleView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.layer.addSublayer(gradientLayer)
        
        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(seatView)
        
        view.addSubview(roomUserView)
        view.addSubview(roomCountingView)
        view.addSubview(roomMoreView)
        view.addSubview(roomNoticeView)
        view.addSubview(roomGiftView)
        view.addSubview(chatroomView.messageView)
        view.addSubview(chatroomView.toolBar)
        
        var enableCDN: Bool = {
            if case .CDN_WS = kCDNType {
                return true
            }
            return false
        }()
        roomUserView.updateNetworkDelay(enableCDN)
        roomUserView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-120)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        
        roomCountingView.snp.makeConstraints { make in
            make.centerY.equalTo(roomUserView)
            make.right.equalTo(roomMoreView.snp.left).offset(-10)
        }
        
        roomMoreView.snp.makeConstraints { make in
            make.centerY.equalTo(roomUserView)
            make.right.equalToSuperview().inset(12)
            make.width.height.equalTo(36)
        }
        
        roomNoticeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(roomUserView.snp.bottom).offset(8)
        }
        
        roomGiftView.iconImageView.image = RCSCAsset.Images.giftValue.image
        roomGiftView.nameLabel.text = "0"
        roomGiftView.snp.makeConstraints { make in
            make.centerY.equalTo(roomNoticeView)
            make.left.equalTo(roomNoticeView.snp.right).offset(6)
        }
        
        chatroomView.toolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        chatroomView.messageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-140.resize)
            make.bottom.equalTo(chatroomView.toolBar.snp.top)
            make.height.equalTo(320.resize)
        }
        
        guard let bubble = musicInfoBubbleView else {
            return
        }
        view.addSubview(bubble)
        bubble.snp.makeConstraints { make in
            make.top.equalTo(roomUserView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 150, height: 50))
        }
    }
    
    dynamic func handleReceivedMessage(_ message: RCMessage) {}
    
    func videoJoinRoom(_ completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        let roomId = room.roomId
        videoRoomService.roomInfo(roomId: roomId) { [weak self] result in
            guard let self = self else { return }
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                switch wrapper.code {
                case 10000:
                    RCLiveVideoEngine.shared().setCDNDataSource(self)
                    switch kCDNType {
                    case .MCU:
                        self.joinMCURoom(roomId, completion: completion)
                    default:
                        self.joinCDNRoom(roomId, completion: completion)
                    }
                case 30001:
                    completion(.success(()))
                    self.didCloseRoom() /// 房间已关闭
                default: completion(.failure(RCSceneError("加入房间失败")))
                }
            case let .failure(error):
                completion(.failure(RCSceneError("加入房间失败:\(error.localizedDescription)")))
            }
        }
    }
    
    private func joinCDNRoom(_ roomId: String, completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        RCLiveVideoEngine.shared().joinRoom(roomId) { code in
            if code == .success {
                videoRoomService.userUpdateCurrentRoom(roomId: roomId) { _ in }
                completion(.success(()))
            } else {
                completion(.failure(RCSceneError("加入房间失败:\(code.rawValue)")))
            }
        }
    }
    
    private func joinMCURoom(_ roomId: String, completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        RCLiveVideoEngine.shared().joinRoom(roomId) { code in
            if code == .success {
                videoRoomService.userUpdateCurrentRoom(roomId: roomId) { _ in }
                completion(.success(()))
            } else {
                completion(.failure(RCSceneError("加入房间失败:\(code.rawValue)")))
            }
        }
    }
    
    func videoLeaveRoom(_ completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        RCLiveVideoEngine.shared().leaveRoom { code in
            switch code {
            case .success, .roomStateError:
                videoRoomService.userUpdateCurrentRoom(roomId: "") { _ in }
                completion(.success(()))
            default:
                completion(.failure(RCSceneError("离开房间失败:\(code.rawValue)")))
            }
        }
    }
    
    func videoDescendantViews() -> [UIView] {
        return [chatroomView.messageView.tableView]
    }
}

extension LiveVideoRoomViewController: RCIMReceiveMessageDelegate {
    func onRCIMCustomAlertSound(_ message: RCMessage!) -> Bool {
        return true
    }
}

extension LiveVideoRoomViewController: RCSCDNDataSource {
    
    func liveType() -> RCSLiveType {
        switch kCDNType {
        case .MCU: return .MCU
        case .CDN_WS: return .innerCDN
        case .CDN: return .thirdCDN
        }
    }
    
    func thirdCDNPlayer() -> UIView & RCSLivePlayer {
        guard case .CDN(let type) = kCDNType else {
            fatalError("Third CDN must impl Player")
        }
        return type.pullPlayer(room.roomId)
    }
}
