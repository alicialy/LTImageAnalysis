//
//  LTCameraViewController.m
//  LTImageAnalysis
//
//  Created by Alicia on 2017/10/27.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import "LTCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CommonDefine.h"
#import "UIView+LTAddtions.h"
#import "LTProcessImageViewController.h"

#define kButtonWH       50

#define kScaleFactor    0.7


@interface LTCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Capture device, front camera, or back camera, or microphone
@property (nonatomic, strong) AVCaptureDevice *device;

// Input device
@property (nonatomic, strong) AVCaptureDeviceInput *input;

// Output image
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//session
@property (nonatomic, strong) AVCaptureSession *session;

// Preview layer, to capture image
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

// To open photo library
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation LTCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (void)setupViews {
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CGFloat paddingX = (self.view.width - kButtonWH) / 2;
    CGFloat paddingY = self.view.height - MAIN_PADDING - kButtonWH;
    UIButton *photoButton = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, paddingY, kButtonWH, kButtonWH)];
    [photoButton setImage:[UIImage imageNamed:@"camera_photo"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(photoLibAction:) forControlEvents:UIControlEventTouchUpInside];
    
#if TARGET_IPHONE_SIMULATOR
    [self.view addSubview:photoButton];
#else
    [self initDevice];
    
    paddingY -= kButtonWH + MAIN_PADDING;
    UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, paddingY, kButtonWH, kButtonWH)];
    [captureButton setImage:[UIImage imageNamed:@"camera_capture"] forState:UIControlStateNormal];
    [captureButton addTarget:self action:@selector(captureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captureButton];
    
    [self.view addSubview:photoButton];
#endif
}

- (void)initDevice {
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;

    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];

    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark - Actions

- (void)photoLibAction:(UIButton *)sender {

    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)captureAction:(UIButton *)sender {
    sender.enabled = YES;

    AVCaptureConnection *stillImageConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation videoOrientation = [self getVideoOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:videoOrientation];
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!imageDataSampleBuffer) {
            return;
        }
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

        UIImage *image = [UIImage imageWithData:jpegData scale:kScaleFactor];
        [self processImage:image];
    }];
}

#pragma mark - Private Method
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}

- (AVCaptureVideoOrientation)getVideoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        result = AVCaptureVideoOrientationLandscapeRight;
    } else if ( deviceOrientation == UIDeviceOrientationLandscapeRight) {
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return result;
}

- (void)processImage:(UIImage *)image {
    LTProcessImageViewController *cropController = [[LTProcessImageViewController alloc] initWithImage:image];
    [self presentViewController:cropController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self processImage:originalImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Getters and Setters
- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker = pickerController;
    }
    return _imagePicker;
}

@end
