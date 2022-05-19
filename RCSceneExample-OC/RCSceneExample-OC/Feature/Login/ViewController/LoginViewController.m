//
//  LoginViewController.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "LoginViewController.h"

#import "RCSceneBridge.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (IBAction)login {
    [self.view endEditing:YES];
    
    NSString *phone = self.textField.text;
    if (phone.length == 0) {
        return;
        //        return SVProgressHUD.showError(withStatus: "请输入正确手机号")
    }
    
    __weak typeof(self) weakSelf = self;
    [RCSceneBridge login:phone success:^(UserModel * model) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString * error) {
        NSLog(@"login error %@", error);
    }];
}

@end
