//
//  LoginViewController.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "LoginViewController.h"

#import "RCSceneExample_OC-Swift.h"

@interface LoginViewController ()

@property (nonatomic, strong) RCVideoRoomService *service;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self.service loginWithPhone:phone success:^(UserModel *userModel){
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString * error) {
        NSLog(@"login error %@", error);
    }];
}

@end
