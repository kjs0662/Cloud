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
#import "PhotoModel.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LibraryViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    self.collectionView.allowsMultipleSelection = YES;
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
        NSLog(@"HTTP response results : %@", [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding]);
        NSError *err = nil;
        NSDictionary <NSString *, id> *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(err) {
            return;
        }
        if (json[@"Images"]) {
            if ([json[@"Images"] isKindOfClass:NSArray.class]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.photos = json[@"Images"];
                    [self.collectionView reloadData];
                });
            }
        }
    }];
    [task resume];
}

- (IBAction)plusButtonSelected:(UIBarButtonItem *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LibraryView *libraryView = [sb instantiateViewControllerWithIdentifier:@"LibraryView"];
    libraryView.delegate = self;
    libraryView.modalPresentationStyle = UIModalPresentationPopover;
    [self.navigationController presentViewController:libraryView animated:YES completion:nil];
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
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.photos[indexPath.item]];
    cell.imageView.image = image;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat targetSize = floorf(self.view.bounds.size.width)/3 - 2;
    return CGSizeMake(targetSize, targetSize);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma mark - LibraryViewDelgate

- (void)libraryViewDelegateDidUploadPhoto:(UIViewController *)vc {
    [self loadData];
}


@end
