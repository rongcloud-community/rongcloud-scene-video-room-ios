//
//  ViewController.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "ViewController.h"

#import "HomeViewModel.h"
#import "RCVideoRoomCell.h"
#import "RCSceneBridge.h"

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
    
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    self.tableView.refreshControl = control;
    [control addTarget:self
                action:@selector(reloadData)
      forControlEvents: UIControlEventValueChanged];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self connectIM];
}

- (void)reloadData {
    __weak typeof(self) weakSelf = self;
    [self.viewModel fetchData:^(NSArray<RoomModel *> * rooms) {
        weakSelf.rooms = rooms;
        [weakSelf.tableView reloadData];
    } failure:^(NSString * error) {
        NSLog(@"fetch data failed %@", error);
    }];
}

- (IBAction)create {
    [self show:nil];
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
    [self show:self.rooms[indexPath.row]];
}

@end
