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
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    self.collectionView.allowsMultipleSelection = YES;
    [self.deleteButton setTintColor:UIColor.grayColor];
    [self.deleteButton setEnabled:NO];
    
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
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(err) {
            return;
        }
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        if (array.count > 0) {
            for (NSDictionary *dic in array) {
                PhotoModel *model = [[PhotoModel alloc] init];
                model.identifier = dic[@"Identifier"];
                model.createdData = dic[@"CreatedDate"];
                model.image = dic[@"Image"];
                [photos addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            [self.collectionView reloadData];
        });
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

- (IBAction)deleteButtonWasSelected:(UIBarButtonItem *)sender {
    if (self.selectedPhotos.count > 0) {
        NSURL *url = [NSURL URLWithString:@"http://localhost:9090/"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSMutableArray *photoArray = [[NSMutableArray alloc] initWithCapacity:self.selectedPhotos.count];
        for (PhotoModel *model in self.selectedPhotos) {
            NSDictionary *dic = @{
                @"Identifier": model.identifier,
                @"CreatedDate": model.createdData
            };
            [photoArray addObject:dic];
        }
        NSData *data = [[NSJSONSerialization dataWithJSONObject:photoArray
                                                        options:0
                                                          error:nil] copy];
        request.HTTPBody = data;
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
        NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error = %@", error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
                    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
                }
                [self loadData];
            });
        }];
        [task resume];
    }
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
    PhotoModel *model = self.photos[indexPath.item];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:model.image];
    cell.imageView.image = image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.selectedPhotos) {
        self.selectedPhotos = [[NSMutableArray alloc] init];
    }
    if (self.collectionView.indexPathsForSelectedItems.count > 0) {
        [self.deleteButton setTintColor:UIColor.systemBlueColor];
        [self.deleteButton setEnabled:YES];
    }
    [self.selectedPhotos addObject:self.photos[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView.indexPathsForSelectedItems.count == 0) {
        [self.deleteButton setTintColor:UIColor.grayColor];
        [self.deleteButton setEnabled:NO];
        self.selectedPhotos = nil;
    }
    [self.selectedPhotos removeObject:self.photos[indexPath.item]];
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
