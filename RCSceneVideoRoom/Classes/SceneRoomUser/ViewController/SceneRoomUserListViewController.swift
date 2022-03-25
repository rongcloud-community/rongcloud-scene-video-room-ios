//
//  SceneRoomUserListViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import SVProgressHUD

import RCSceneRoom
import RCSceneService

class SceneRoomUserListViewController: UIViewController {
    private let room: VoiceRoom
    private weak var delegate: UserOperationProtocol?
    
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: RCLVMicInviteCell.self)
        instance.dataSource = self
        instance.delegate = self
        return instance
    }()
    private lazy var emptyView = VoiceRoomUserListEmptyView()
    private lazy var cancelButton: UIButton = {
        let instance = UIButton()
        instance.setImage(RCSCAsset.Images.whiteQuiteIcon.image, for: .normal)
        instance.addTarget(self, action: #selector(handleCancelClick), for: .touchUpInside)
        instance.sizeToFit()
        return instance
    }()
    
    private var userlist = [VoiceRoomUser]() {
        didSet {
            emptyView.isHidden = userlist.count > 0
        }
    }
    private var managers = [String]()
    
    init(room: VoiceRoom, delegate: UserOperationProtocol) {
        self.delegate = delegate
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "用户列表"
        view.addSubview(blurView)
        view.addSubview(emptyView)
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-72.resize)
            make.width.height.equalTo(190.resize)
        }
        fetchRoomUserlist()
        fetchmanagers()
    }
    
    private func buildLayout() {
        view.backgroundColor = RCSCAsset.Colors.hex03062F.color.withAlphaComponent(0.5)
        view.addSubview(blurView)
        view.addSubview(tableView)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func fetchRoomUserlist() {
        userService.roomUsers(roomId: room.roomId) { [weak self] result in
            switch result.map(RCNetworkWapper<[VoiceRoomUser]>.self) {
            case let .success(wrapper):
                if let users = wrapper.data {
                    self?.userlist = users
                    self?.tableView.reloadData()
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func fetchmanagers() {
        userService.roomManagers(roomId: room.roomId) { [weak self] result in
            switch result.map(RCNetworkWapper<[VoiceRoomUser]>.self) {
            case let .success(wrapper):
                if let users = wrapper.data {
                    self?.managers = users.map(\.userId)
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
        
    }
    
    @objc func handleCancelClick() {
        dismiss(animated: true, completion: nil)
    }
}

extension SceneRoomUserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: RCLVMicInviteCell.self)
        return cell.updateCell(userlist[indexPath.row])
    }
}

extension SceneRoomUserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userlist[indexPath.row]
        guard user.userId != Environment.currentUserId else {
            return
        }
        
        let userType: SceneRoomUserType = {
            if user.userId == room.userId { return .creator }
            if SceneRoomManager.shared.managers.contains(user.userId) { return .manager }
            return .audience
        }()
        
        let seat = RCLiveVideoEngine.shared().currentSeats.first { seat in
            seat.userId == user.userId
        }
        let index = RCLiveVideoEngine.shared().currentSeats.firstIndex { seat in
            seat.userId == user.userId
        }
        
        let dependency = UserOperationDependency(room: room,
                                                 userId: user.userId,
                                                 userRole: userType,
                                                 userSeatIndex: index,
                                                 userSeatMute: seat?.mute,
                                                 userSeatLock: seat?.lock)
        let controller = UserOperationViewController(dependency: dependency,
                                                     delegate: delegate)
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .popover
        present(controller, animated: true)
    }
}
