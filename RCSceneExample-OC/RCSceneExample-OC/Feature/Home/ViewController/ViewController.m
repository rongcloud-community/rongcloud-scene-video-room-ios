//
//  ViewController.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "ViewController.h"

#import "HomeViewModel.h"
#import "RCVideoRoomCell.h"
#import "RCSceneExample_OC-Swift.h"

#import <RongCloudOpenSource/RongIMKit.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HomeViewModel *viewModel;

@property (nonatomic, copy) NSArray<RoomModel *> *rooms;

@end

@implementation ViewController

- (HomeViewModel *)viewModel {
    if (_viewModel) return _viewModel;
    _viewModel = [[HomeViewModel alloc] init];
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakSelf = self;
    [self.viewModel fetchData:^(NSArray<RoomModel *> * rooms) {
        weakSelf.rooms = rooms;
        [weakSelf.tableView reloadData];
    } failure:^(NSString * error) {
        NSLog(@"fetch data failed %@", error);
    }];
}

- (IBAction)create {
    [RCSVRoom show:self.navigationController room:nil];
}

- (void)connectIM {
    if ([[RCIM sharedRCIM] getConnectionStatus] == ConnectionStatus_Connected) {
        return;
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] oc_rongToken];
    if (token == nil) return [self performSegueWithIdentifier:@"Login" sender:nil];
    
    [[RCIM sharedRCIM] initWithAppKey:[AppConfigs appKey]];
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
        
    } success:^(NSString *userId) {
        
    } error:^(RCConnectErrorCode errorCode) {
        
    }];
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCVideoRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return [cell updateUI:self.rooms[indexPath.row]];
}

#pragma mark - UITableViewDelegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [RCSVRoom show:self.navigationController room:self.rooms[indexPath.row]];
}

@end
