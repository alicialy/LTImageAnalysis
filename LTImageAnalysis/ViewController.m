//
//  ViewController.m
//  LTImageAnalysis
//
//  Created by Alicia on 2017/10/26.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import "ViewController.h"
#import "LTCameraViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
#if TARGET_IPHONE_SIMULATOR
    [self presentViewController:self.imagePicker animated:YES completion:nil];
#endif
}


#pragma mark - Init

- (void)setupViews {
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
//    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
   
    [picker dismissViewControllerAnimated:YES completion:nil];
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
