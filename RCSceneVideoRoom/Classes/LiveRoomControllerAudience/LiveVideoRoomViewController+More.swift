//
//  LiveVideoRoomViewController+More.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/15.
//

import SVProgressHUD

extension LiveVideoRoomViewController {
    @_dynamicReplacement(for: role)
    private var more_role: RCRTCLiveRoleType {
        get { role }
        set {
            role = newValue
            switch role {
            case .broadcaster:
                guard let containerAction = self.roomContainerAction else {return}
                navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                containerAction.disableSwitchRoom()
            case .audience:
                guard let containerAction = self.roomContainerAction else {return}
                navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                containerAction.enableSwitchRoom()
            @unknown default: ()
            }
        }
    }
    
    @_dynamicReplacement(for: m_viewDidLoad)
    private func more_viewDidLoad() {
        m_viewDidLoad()
    }
}


extension LiveVideoRoomViewController: LiveVideoRoomMoreDelegate {
    func sceneRoom(_ view: RCLiveVideoRoomMoreView, didClick action: LiveVideoRoomMoreAction) {
        switch action {
        case .leave:
            leaveRoom()
        case .quit:
            closeRoomDidClick()
        case .minimize:
            if role == .broadcaster {
                return SVProgressHUD.showInfo(withStatus: "连麦中禁止此操作")
            }
            scaleRoomDidClick()
        }
    }
    
    func closeRoomDidClick() {
        let controller = UIAlertController(title: "提示", message: "确定结束本次连麦么？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        let sureAction = UIAlertAction(title: "确认", style: .default) { _ in
            RCSensorAction.connectionWithDraw(self.room).trigger()
            RCLiveVideoEngine.shared()
                .leaveLiveVideo({ [weak self] _ in
                    self?.liveVideoDidFinish(.leave)
                })
        }
        controller.addAction(sureAction)
        present(controller, animated: true)
    }
    
    func scaleRoomDidClick() {
        guard let fm = self.floatingManager, let parent = parent else {
            backTrigger(false)
            return
        }
        fm.show(parent, superView: self.previewView, animated: true)
        needHandleFloatingBack = true
        backTrigger(false)
    }
}

extension UIViewController {
    func backTrigger(_ animated: Bool = true) {
        if presentingViewController != nil {
            return dismiss(animated: animated)
        }
        guard let controller = navigationController else {
            return
        }
        controller.popViewController(animated: animated)
    }
}
