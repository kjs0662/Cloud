//
//  LibraryView.m
//  PhotoCloud
//
//  Created by Jinseon Kim on 2019/12/31.
//  Copyright © 2019 Jinseon Kim. All rights reserved.
//

#import "LibraryView.h"
#import <Photos/Photos.h>
#import "PhotoCell.h"

@interface LibraryView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) PHFetchResult<PHAsset *> *fetchResults;
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) NSMutableArray *selectedPhotos;
@property (nonatomic) PHImageManager *imageManager;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@end

@implementation LibraryView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self setup];
}

- (void)setup {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES],
    ];
    self.fetchResults = [PHAsset fetchAssetsWithOptions:fetchOptions];
    self.imageManager = [PHImageManager defaultManager];
    self.selectedPhotos = [[NSMutableArray alloc] init];
    self.photos = [[NSMutableArray alloc] init];
    CGFloat targetSize = floorf(self.view.bounds.size.width)/3 - 2;
    for (PHAsset *asset in self.fetchResults) {
        [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(targetSize, targetSize) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self.photos addObject:result];
        }];
    }
    
    self.collectionView.backgroundColor = UIColor.systemBackgroundColor;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    
    [self.uploadButton setTintColor:UIColor.grayColor];
    [self.uploadButton setEnabled:NO];
    
}

- (IBAction)cancelButtonWasSelected:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadButtonWasSelected:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"http://localhost:9090/"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = [self generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:nil images:self.selectedPhotos];
    
    NSURLSessionDataTask *task = [NSURLSession.sharedSession uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result = %@", result);
    }];
    [task resume];
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             images:(NSArray *)images {
    NSMutableData *httpBody = [NSMutableData data];

    // add params (all params are strings)

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    // add image data

    for (UIImage *image in images) {
        float low_bound = 0;
        float high_bound =5000;
        float rndValue = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
        int intRndValue = (int)(rndValue + 0.5);
        NSString *str_image1 = [@(intRndValue) stringValue];
        NSData *imageData = UIImageJPEGRepresentation(image, 90);

        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"files\"; filename=\"%@.png\"\r\n",str_image1] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:imageData];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return httpBody;
}

- (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}


#pragma mark - CollectionViewDelgate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView.indexPathsForSelectedItems.count > 0) {
        [self.uploadButton setTintColor:UIColor.systemBlueColor];
        [self.uploadButton setEnabled:YES];
    }
    [self.selectedPhotos addObject:self.photos[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView.indexPathsForSelectedItems.count == 0) {
        [self.uploadButton setEnabled:NO];
        [self.uploadButton setTintColor:UIColor.grayColor];
    }
    [self.selectedPhotos removeObject:self.photos[indexPath.item]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.imageView.image = self.photos[indexPath.item];
    
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

@end