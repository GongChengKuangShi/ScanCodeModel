//
//  SGQRCodeScanningViewController.m
//  XRHQRCodeExample
//
//  Created by xiangronghua on 2017/6/26.
//  Copyright © 2017年 xiangronghua. All rights reserved.
//

#import "SGQRCodeScanningViewController.h"
#import "SGQRCode.h"
#import "ScanSuccessJumpViewController.h"

@interface SGQRCodeScanningViewController () <SGQRCodeManagerDelegate>

@property (strong, nonatomic) SGQRCodeScanningView *scanningView;

@end

@implementation SGQRCodeScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.scanningView];
    [self setupNavigationBar];
    [self setupQRCodeScanning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView addTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanningView removeTimer];
}

- (void)dealloc {
    NSLog(@"SGQRCodeScanningVC - dealloc");
    [self removeScanningView];
}

- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [SGQRCodeScanningView scanningViewWithFrame:self.view.bounds layer:self.view.layer];
    }
    return _scanningView;
}

- (void)removeScanningView {
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)rightBarButtonItenAction {
    [[SGQRCodeManager sharedQRCodeManager] SG_readQRCodeFromAlbum];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 栅栏函数
    dispatch_barrier_async(queue, ^{
        BOOL isPHAuthorization = [SGQRCodeManager sharedQRCodeManager].isPHAuthorization;
        if (isPHAuthorization == YES) {
            [self removeScanningView];
        }
    });
}

#pragma mark - SGQRCodeManagerDelegate

- (void)manager:(SGQRCodeManager *)manager imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.view addSubview:self.scanningView];
}

- (void)manager:(SGQRCodeManager *)manager imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:info [UIImagePickerControllerOriginalImage]];
    }];
}

- (void)manager:(SGQRCodeManager *)manager captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"metadataObjects - - %@",metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [manager SG_palySoundName:@"SGQRCode.bundle/sound.caf"];
        [manager SG_stopRunning];
        [manager SG_videoPreviewLayerRemoveFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        ScanSuccessJumpViewController *jumpVC = [[ScanSuccessJumpViewController alloc] init];
        jumpVC.jump_URL = [obj stringValue];
        [self.navigationController pushViewController:jumpVC animated:YES];
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

#pragma mark - 从相册中识别二维码, 并进行界面跳转
- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    image = [UIImage imageSizeWithScreenImage:image];
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
   //取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count == 0) {
        NSLog(@"暂未识别出扫描的二维码");
        return;
    }
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *resultStr = feature.messageString;
        NSLog(@"scannedResult - - %@", resultStr);
        if ([resultStr hasPrefix:@"http"]) {
            ScanSuccessJumpViewController *jumpVC = [[ScanSuccessJumpViewController alloc] init];
            jumpVC.jump_URL = resultStr;
            [self.navigationController pushViewController:jumpVC animated:YES];
        } else {
            ScanSuccessJumpViewController *jumpVC = [[ScanSuccessJumpViewController alloc] init];
            jumpVC.jump_bar_code = resultStr;
            [self.navigationController pushViewController:jumpVC animated:YES];
        }
    }
}

- (void)setupQRCodeScanning {
    SGQRCodeManager *manager = [SGQRCodeManager sharedQRCodeManager];
    manager.currentVC = self;
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [manager SG_setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr];
    manager.delegate = self;
}



@end
