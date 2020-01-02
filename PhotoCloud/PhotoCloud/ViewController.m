//
//  ViewController.m
//  PhotoCloud
//
//  Created by Jinseon Kim on 2019/12/31.
//  Copyright © 2019 Jinseon Kim. All rights reserved.
//

#import "ViewController.h"
#import "PhotoCell.h"
#import "LibraryView.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    
    [self loadData];
}

- (void)loadData {
    NSURL *url = [NSURL URLWithString:@"http://localhost:9090/"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data || error) {
            return;
        }
        NSError *err = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if(err) {
            return;
        }
        NSDictionary <NSString *, id> *json = jsonObj;
        
    }];
    [task resume];
    
    
}

- (IBAction)plusButtonSelected:(UIBarButtonItem *)sender {
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    return cell;
}


@end
