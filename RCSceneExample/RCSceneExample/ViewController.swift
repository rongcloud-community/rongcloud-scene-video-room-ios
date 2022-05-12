//
//  ViewController.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/19.
//

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
    
    @IBAction func create() {
        let controller = RCVideoRoomController()
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
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
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
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
