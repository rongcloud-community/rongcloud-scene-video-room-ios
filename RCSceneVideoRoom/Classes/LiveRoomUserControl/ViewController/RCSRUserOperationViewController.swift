
import SVProgressHUD
import RCSceneRoom

class RCSRUserOperationViewController: UIViewController {
    private var dependency: RCSRUserOperationDependency
    weak var delegate:RCSRUserOperationProtocol?
    private lazy var avatarImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFill
        instance.image = RCSCAsset.Images.defaultAvatar.image
        instance.layer.cornerRadius = 28
        instance.layer.masksToBounds = true
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var giftButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = RCSCAsset.Colors.hexCDCDCD.color.withAlphaComponent(0.2)
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        instance.setTitle("送礼物", for: .normal)
        instance.setTitleColor(UIColor.white, for: .normal)
        instance.layer.cornerRadius = 22
        instance.backgroundColor = RCSCAsset.Colors.hexEF499A.color
        instance.addTarget(self, action: #selector(handleSendGift), for: .touchUpInside)
        return instance
    }()
    private lazy var sendMessageButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        instance.setTitle("发私信", for: .normal)
        instance.setTitleColor(RCSCAsset.Colors.hexEF499A.color, for: .normal)
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 22
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = RCSCAsset.Colors.hexEF499A.color.cgColor
        instance.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return instance
    }()
    private lazy var followButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        instance.setTitle("关注", for: .normal)
        instance.setTitleColor(RCSCAsset.Colors.hexEF499A.color, for: .normal)
        instance.backgroundColor = .clear
        instance.layer.cornerRadius = 22
        instance.layer.borderWidth = 1.0
        instance.layer.borderColor = RCSCAsset.Colors.hexEF499A.color.cgColor
        instance.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return instance
    }()
    private lazy var manageButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        instance.titleLabel?.font = .systemFont(ofSize: 13)
        instance.setTitle("设为管理", for: .normal)
        instance.setTitleColor(UIColor(hexInt: 0xdfdfdf), for: .normal)
        instance.setImage(RCSCAsset.Images.emptyStar.image, for: .normal)
        instance.addTarget(self, action: #selector(setManager), for: .touchUpInside)
        instance.centerTextAndImage(spacing: 5)
        return instance
    }()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView()
        instance.distribution = .fillEqually
        instance.backgroundColor = RCSCAsset.Colors.hex03062F.color.withAlphaComponent(0.16)
        return instance
    }()
    private lazy var pickUpButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("邀请上麦", for: .normal)
        instance.setImage(RCSCAsset.Images.pickUserUpSeatIcon.image, for: .normal)
        instance.addTarget(self, action: #selector(handlePickUpUser), for: .touchUpInside)
        return instance
    }()
    private lazy var pickDownButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("抱下麦", for: .normal)
        instance.setImage(RCSCAsset.Images.pickUserDownSeatIcon.image, for: .normal)
        instance.addTarget(self, action: #selector(handlekickUserOut), for: .touchUpInside)
        return instance
    }()
    private lazy var lockSeatButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("关闭座位", for: .normal)
        instance.setImage(RCSCAsset.Images.voiceroomSettingLockallseat.image, for: .normal)
        instance.addTarget(self, action: #selector(handleLockSeat), for: .touchUpInside)
        return instance
    }()
    private lazy var muteButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("座位禁麦", for: .normal)
        instance.setImage(RCSCAsset.Images.voiceroomSettingMuteall.image, for: .normal)
        instance.addTarget(self, action: #selector(handleMuteSeat), for: .touchUpInside)
        return instance
    }()
    private lazy var kickOutButton: UIButton = {
        let instance = UIButton()
        instance.backgroundColor = .clear
        instance.titleLabel?.font = .systemFont(ofSize: 12)
        instance.setTitle("踢出房间", for: .normal)
        instance.setImage(RCSCAsset.Images.kickOutRoomIcon.image, for: .normal)
        instance.addTarget(self, action: #selector(handleKickOut), for: .touchUpInside)
        return instance
    }()
    private var isFollow = false
    
    private lazy var userService = RCSceneRoomService()
    
    init(dependency: RCSRUserOperationDependency,
                delegate: RCSRUserOperationProtocol?) {
        self.dependency = dependency
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        fetchUserInfo()
        setupButtonState()
        setupManagerButton()
        setupStackView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.popMenuClip(corners: [.topLeft, .topRight], cornerRadius: 22, centerCircleRadius: 37)
        pickUpButton.alignImageAndTitleVertically(padding: 8)
        pickDownButton.alignImageAndTitleVertically(padding: 8)
        lockSeatButton.alignImageAndTitleVertically(padding: 8)
        muteButton.alignImageAndTitleVertically(padding: 8)
        kickOutButton.alignImageAndTitleVertically(padding: 8)
        manageButton.roundCorners(corners: [.bottomLeft, .topRight], radius: 22)
    }
    
    private func fetchUserInfo() {
        RCSceneUserManager.shared.refreshUserInfo(userId: dependency.userId) { [weak self] user in
            guard let self = self else { return }
            self.avatarImageView.kf.setImage(with: URL(string: user.portraitUrl), placeholder: RCSCAsset.Images.defaultAvatar.image)
            self.nameLabel.text = user.userName
            self.isFollow = user.isFollow
            self.followButton.setTitle(self.isFollow ? "已关注" : "关注", for: .normal)
        }
    }
    
    @objc private func setManager() {
        let setManager = dependency.userRole != .manager
        let roomId = dependency.room.roomId
        let userId = dependency.userId
        userService.setRoomManager(roomId: roomId, userId: userId, isManager: setManager) { [weak self] result in
            switch result.map(RCSceneResponse.self) {
            case let .success(res):
                if let self = self, res.validate() {
                    self.setupManagerButton()
                    self.dismiss(animated: true)
                    self.delegate?.didSetManager(userId: self.dependency.userId, isManager: setManager)
                }
            case let .failure(error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(avatarImageView)
        container.addSubview(nameLabel)
        container.addSubview(giftButton)
        container.addSubview(sendMessageButton)
        container.addSubview(followButton)
        container.addSubview(stackView)
        container.addSubview(manageButton)
        
        container.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
        }
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.size.equalTo(CGSize(width: 56, height: 56))
            make.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        giftButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18.resize)
            make.height.equalTo(44.resize)
            make.width.equalTo(104.resize)
            make.top.equalTo(nameLabel.snp.bottom).offset(30.resize)
        }
        
        sendMessageButton.snp.makeConstraints { make in
            make.size.equalTo(giftButton)
            make.centerY.equalTo(giftButton)
            make.centerX.equalToSuperview()
        }
        
        followButton.snp.makeConstraints { make in
            make.size.equalTo(giftButton)
            make.centerY.equalTo(giftButton)
            make.right.equalToSuperview().inset(18.resize)
        }
        
        if shouldShowFunctionMenu() {
            stackView.snp.makeConstraints {
                $0.top.equalTo(giftButton.snp.bottom).offset(25)
                $0.height.equalTo(135)
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        } else {
            sendMessageButton.snp.remakeConstraints { make in
                make.size.equalTo(giftButton)
                make.centerY.equalTo(giftButton)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(25)
            }
        }
        
        manageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(37)
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 45))
        }
    }
    
    private func shouldShowFunctionMenu() -> Bool {
        if dependency.currentUserRole == .creator { return true }
        if dependency.currentUserRole == .manager {
            return dependency.userRole == .audience
        }
        return false
    }
    
    private func setupStackView() {
        let buttons: [UIButton] = {
            switch dependency.currentUserRole {
            case .audience: return []
            default: return [kickOutButton]
            }
        }()
        buttons.forEach { stackView.addArrangedSubview($0) }
    }
    
    private func setupManagerButton() {
        if dependency.userRole == .manager {
            manageButton.setImage(RCSCAsset.Images.fullStar.image, for: .normal)
            manageButton.setTitle("撤回管理", for: .normal)
        } else {
            manageButton.setImage(RCSCAsset.Images.emptyStar.image, for: .normal)
            manageButton.setTitle("设为管理", for: .normal)
        }
        manageButton.isHidden = !(dependency.currentUserRole == .creator)
    }
    
    private func setupButtonState() {
        if dependency.userSeatMute == true {
            muteButton.setTitle("座位开麦", for: .normal)
            muteButton.setImage(RCSCAsset.Images.voiceroomSettingUnmuteall.image, for: .normal)
        } else {
            muteButton.setTitle("座位禁麦", for: .normal)
            muteButton.setImage(RCSCAsset.Images.voiceroomSettingMuteall.image, for: .normal)
        }
    }
    
    @objc private func handleSendGift() {
        dismiss(animated: true, completion: nil)
        delegate?.didClickedSendGift(userId: dependency.userId)
    }
    
    @objc private func handleSendMessage() {
        let userId = dependency.userId
        let delegate = self.delegate
        dismiss(animated: true) {
            delegate?.didClickedPrivateChat(userId: userId)
        }
    }
    
    @objc private func handleFollow() {
        let userId = dependency.userId
        let follow = !isFollow
        userService.follow(userId: userId) { [weak self] result in
            switch result.map(RCSceneResponse.self) {
            case let .success(res):
                if res.validate() {
                    self?.onFollow(userId, follow: follow)
                } else {
                    SVProgressHUD.showError(withStatus: "网络请求失败")
                }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    private func onFollow(_ userId: String, follow: Bool) {
        isFollow = follow
        followButton.setTitle(follow ? "已关注" : "关注", for: .normal)
        delegate?.didFollow(userId: userId, isFollow: isFollow)
    }
    
    @objc private func handlePickUpUser() {
        dismiss(animated: true, completion: nil)
        delegate?.didClickedInvite(userId: dependency.userId)
    }
    
    @objc private func handlekickUserOut() {
        guard let seatIndex = dependency.userSeatIndex else {
            return
        }
        delegate?.kickUserOffSeat(seatIndex: UInt(seatIndex))
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLockSeat() {
        guard let index = dependency.userSeatIndex else { return }
        if dependency.userSeatLock == true {
            delegate?.lockSeatDidClick(isLock: false, seatIndex: UInt(index))
        } else {
            delegate?.lockSeatDidClick(isLock: true, seatIndex: UInt(index))
        }
        setupButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleMuteSeat() {
        guard
            let seatIndex = dependency.userSeatIndex
        else { return }
        let mute = dependency.userSeatMute == false
        delegate?.muteSeat(isMute: mute, seatIndex: UInt(seatIndex))
        setupButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleKickOut() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.kickOutRoom(userId: self.dependency.userId)
        }
    }
}
