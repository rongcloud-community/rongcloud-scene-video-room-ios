//
//  LoginViewController.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/29.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var phoneTF: UITextField!
    
    private lazy var service = RCVideoRoomService()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneTF.becomeFirstResponder()
    }
    
    @IBAction func login() {
        view.endEditing(true)
        
        guard let text = phoneTF.text, text.count == 11 else {
            return SVProgressHUD.showError(withStatus: "请输入正确手机号")
        }
        
        service.login(phone: text) { [weak self] result in
            switch result {
            case .success:
                self?.navigationController?.popViewController(animated: true)
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }

}
