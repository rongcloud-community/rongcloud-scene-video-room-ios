//
//  ViewController.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/19.
//

import UIKit
import RongIMKit
import SVProgressHUD
import RCSceneRoom
import RCSceneVideoRoom

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var refreshControl: UIRefreshControl = {
        let instance = UIRefreshControl()
        instance.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return instance
    }()
    
    private var rooms = [RCSceneRoom]()
    
    private var currentPage: Int = 1
    
    private lazy var service = RCVideoRoomService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connection()
    }

    @objc func refresh() {
        service.roomList { result in
            switch result {
            case let .success(rooms):
                self.rooms = rooms
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    @IBAction func test() {
        let controller = UIAlertController(title: "测试", message: "用于测试 RTC 视频合流", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "房间 ID"
        }
        let createAction = UIAlertAction(title: "创建", style: .default) { action in
            guard let roomId = controller.textFields?.first?.text else {
                return debugPrint("room ID nil")
            }
            let create = CreateViewController()
            create.roomID = roomId
            self.navigationController?.pushViewController(create, animated: true)
        }
        let joinAction = UIAlertAction(title: "加入", style: .default) { action in
            guard let roomId = controller.textFields?.first?.text else {
                return debugPrint("room ID nil")
            }
            let join = JoinViewController()
            join.roomID = roomId
            self.navigationController?.pushViewController(join, animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(createAction)
        controller.addAction(joinAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    @IBAction func create() {
        let controller = RCVideoRoomController()
        let _ = VideoRoomCoordinator(rootViewController: navigationController!)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return (cell as! RCVideoRoomCell).updateUI(rooms[indexPath.item])
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = RCVideoRoomController(room: rooms[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

/// Connection
extension ViewController {
    private func connection() {
        if RCIM.shared().getConnectionStatus() == .ConnectionStatus_Connected {
            return
        }
        guard let token = UserDefaults.standard.rongToken() else {
            return performSegue(withIdentifier: "Login", sender: nil)
        }
        RCIM.shared().initWithAppKey(Environment.rcKey)
        RCIM.shared().connect(withToken: token) { code in
            debugPrint("RCIM db open failed: \(code.rawValue)")
        } success: { userId in
            debugPrint("userId: \(userId ?? "")")
            self.refresh()
        } error: { errorCode in
            debugPrint("RCIM connect failed: \(errorCode.rawValue)")
        }
    }
}
