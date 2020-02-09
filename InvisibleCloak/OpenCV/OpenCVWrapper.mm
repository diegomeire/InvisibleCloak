//
//  OpenCVWrapper.m
//  InvisibleCloak
//
//  Created by Diego Meire on 31/07/19.
//  Copyright © 2019 Diege Miere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenCVWrapper.h"
// OpenCV
#import <opencv2/calib3d.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#import <CoreMedia/CoreMedia.h>

#include "opencv2/saliency.hpp"

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

using namespace std;
using namespace cv;
using namespace saliency;

@interface OpenCVWrapper() <CvVideoCameraDelegate, CvPhotoCameraDelegate>

@end



@implementation OpenCVWrapper {
    
    CvVideoCamera * videoCamera;
    
    CvPhotoCamera * photoCamera;
    
    cv::Mat background;
    
    cv::dnn::Net net;
    
    cv::Mat processingImage;
    
    bool isCapturingBackground;
    
    NSMutableArray *colorsToFind;
    
}



@synthesize numberOfMeanColors = _numberOfMeanColors;

- (instancetype)init {
    self = [super init];
    colorsToFind = [[NSMutableArray alloc]init];
    return self;
}


+ (instancetype)shared
{
    static OpenCVWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OpenCVWrapper alloc] init];
        sharedInstance.numberOfMeanColors = 10;
    });
    return sharedInstance;
}

//**************************************
- (void) createOpenCVVideoCameraWithImageView:(UIImageView *)imageView {
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto;
    videoCamera.rotateVideo = NO; // Ensure proper orientation
    videoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
    videoCamera.delegate = self;
    
    isCapturingBackground = false;
    
}
//**************************************



//**************************************

- (void) createOpenCVPhotoCameraWithImageView:(UIImageView *)imageView {
    
    photoCamera = [[CvPhotoCamera alloc] initWithParentView:imageView];
    photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    photoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
    photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto;
    photoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
    photoCamera.delegate = self;
    [photoCamera unlockFocus];
    
}
//**************************************




//**************************************
- (void) getBackground {
    isCapturingBackground = true;
}
//**************************************

//**************************************
- (void) clearColorsToFind
{
    [colorsToFind removeAllObjects];
}
//**************************************



//**************************************
- (void) addColorToFind:(UIColor*)color{
    [colorsToFind addObject:color];
}
//**************************************



//**************************************
- (void)processImage:(cv::Mat &)img {

    if (isCapturingBackground) {
       cv::copyTo(img, background, cv::Mat());
       isCapturingBackground = false;
    }
    
    cv::Mat hsv;
    cv::cvtColor(img, hsv, cv::COLOR_BGR2HSV);
    
    cv::Mat mask1, mask2;
    
    for (int i = 0; i < colorsToFind.count; i ++){
        
        cv::Mat auxMask;
        
        UIColor *color = colorsToFind[i];
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        [color getHue:&hue
           saturation:&saturation
           brightness:&brightness
                alpha:nil];
        
        hue = hue * 180;
        saturation = saturation * 255;
        brightness = brightness * 255;
        
        double minSaturation = 0;
        double maxSaturation = 0;
        
        double minBrightness = 0;
        double maxBrightness = 0;
        
        if (_fullColorRange){
            minSaturation = 50;
            maxSaturation = 255;
//            minBrightness = 50;
            maxBrightness = 255;
        }
        else{
            minSaturation = saturation * 0.3;
            maxSaturation = saturation * 0.7;
            minBrightness = brightness * 0.3;
            maxBrightness = brightness * 0.7;
        }
            
            
        
        if (i == 0){
            cv::inRange( hsv,
                        cv::Scalar( CLAMP( hue - 30, 0, hue - 30 ),
                                    minSaturation, //( saturation * 0.1),
                                    minBrightness),//( brightness * 0.1)),
                        cv::Scalar( CLAMP( hue + 30, hue + 30, 180 ),
                                    maxSaturation,//( saturation * 1.5),
                                    maxBrightness),//( brightness * 1.5)),
                        mask1);
        }
        else{
        
            cv::inRange( hsv,
                        cv::Scalar( CLAMP( hue - 30, 0, hue - 30),
                                   minSaturation,//( saturation * 0.1),
                                   minBrightness),//( brightness * 0.1)),//_value - _valueOffset),
                        cv::Scalar( CLAMP( hue + 30, hue + 30, 180 ),
                                   maxSaturation, //( saturation * 1.5),
                                   maxBrightness),//( brightness * 1.5)),
                        auxMask);
        
            mask1 = mask1 + auxMask;
        }

    }

    
    cv::Mat kernel = cv::Mat::ones(3,3, CV_32F);
    cv::morphologyEx(mask1,mask1,cv::MORPH_OPEN,kernel);
    cv::morphologyEx(mask1,mask1,cv::MORPH_DILATE,kernel);
    
    // creating an inverted mask to segment out the cloth from the frame
    cv::bitwise_not(mask1,mask2);
    cv::Mat res1, res2, final_output;
    
    // Segmenting the cloth out of the frame using bitwise and with the inverted mask
    cv::bitwise_and(img, img, res1, mask2);
    
    // creating image showing static background frame pixels only for the masked region
    bitwise_and(background, background, res2, mask1 );
    
    // Generating the final augmented output.
    addWeighted(res1,1,res2,1,0,final_output);
    
    cv::copyTo(final_output, img, cv::Mat());
}
//**************************************






//**************************************
- (void) photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image{
    
    cv::Mat src;
    
    UIImage *rotatedImage = [self fixOrientationForImage:image];
    
    UIImageToMat(rotatedImage, processingImage, false);
    
    cv::cvtColor(processingImage, processingImage, cv::COLOR_RGBA2BGRA); // Converts matrix to 4 channels and save into gtpl variable.
    
    cv::Mat resized;
    cv::resize(processingImage, resized, cv::Size(300,300));
    
    fastNlMeansDenoisingColored( resized, resized, 3, 3, 7, 21);
    
    NSArray *colors = [self getColors];
    
    [self.delegate pictureTakenWithColors:colors];
    
}
//**************************************




//**************************************
- (void)photoCameraCancel:(CvPhotoCamera *)photoCamera {
    
}
//**************************************


//**************************************
- (void) takePicture{
    
    [photoCamera takePicture];
    
}
//**************************************


//**************************************
- (UIImage *)fixOrientationForImage:(UIImage*)neededImage {
    
    // No-op if the orientation is already correct
    if (neededImage.imageOrientation == UIImageOrientationUp) return neededImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (neededImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.width, neededImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, neededImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (neededImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, neededImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, neededImage.size.width, neededImage.size.height,
                                             CGImageGetBitsPerComponent(neededImage.CGImage), 0,
                                             CGImageGetColorSpace(neededImage.CGImage),
                                             CGImageGetBitmapInfo(neededImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (neededImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,neededImage.size.height,neededImage.size.width), neededImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,neededImage.size.width,neededImage.size.height), neededImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
//**************************************




//**************************************
- (NSArray*) getColorsForImage:(UIImage *)image{
    
    cv::Mat src;
    
    UIImage *rotatedImage = [self fixOrientationForImage:image];
    
    UIImageToMat(rotatedImage, processingImage, false);
    
    processingImage = [self enhanceColors:processingImage];
    
    cv::cvtColor(processingImage, processingImage, cv::COLOR_RGBA2BGRA);
    
    return [self getColors];
}
//**************************************


//**************************************
- (cv::Mat) enhanceColors:(cv::Mat) image {
    
    double alpha = 1.2; /* < Simple contrast control */
    int beta = 0.2;       /* < Simple brightness control */
    
    for( int y = 0; y < image.rows; y++ ) {
        for( int x = 0; x < image.cols; x++ ) {
            for( int c = 0; c < 3; c++ ) {
                image.at<cv::Vec3b>(y,x)[c] = cv::saturate_cast<uchar>( alpha*( image.at<cv::Vec3b>(y,x)[c] ) + beta );
            }
        }
    }
    
    
    return image;
}
//**************************************



//**************************************
- (cv::Mat) getSaliency:(cv::Mat) img{
    
    
    cv::Mat grayCroppedImage;
    cvtColor(img, grayCroppedImage, cv::COLOR_RGB2GRAY );
    
    
    Ptr<Saliency> saliencyAlgorithm;
    Mat saliencyMap;
    Mat binaryMap;
    saliencyAlgorithm = StaticSaliencySpectralResidual::create();
    if( saliencyAlgorithm->computeSaliency( grayCroppedImage, saliencyMap ) )
    {
        StaticSaliencySpectralResidual spec;
        spec.computeBinaryMap( saliencyMap, binaryMap );
    }
    
    for( int y = 0; y < img.rows; y++ ) {
        for( int x = 0; x < img.cols; x++ ){
            for( int z = 0; z < 3; z++){
                if (binaryMap.at<uchar>( y, x) > 0 ){
                    img.at<cv::Vec3b>(y,x)[z]  = img.at<cv::Vec3b>(y,x)[z];
                }
                else{
                    img.at<cv::Vec3b>(y,x)[z]  = 0;
                }
                
            }
        }
    }
    
    
    return img;
}
//**************************************



//**************************************
- (NSArray*) getColors{
    
    return [self getColors:10 useSaliency:false];
}
//**************************************


//**************************************
- (NSArray*) getColors:(int)numberOfColors useSaliency:(bool)saliency{
    
    NSMutableArray *colorArray = [[NSMutableArray alloc]initWithCapacity:numberOfColors];
    
    cv::Mat src;
    cv::cvtColor(processingImage, src, cv::COLOR_BGRA2RGB);
    
    cv::resize(src, src, cv::Size(480, 640));
    
    double size = 300;
    cv::Rect myROI((src.cols - size) / 2,
                   (src.rows - size) / 2,
                   size,
                   size);
    cv::Mat croppedImage = src(myROI);
    
    cv::Mat samples(croppedImage.rows * croppedImage.cols, 3, CV_32F);
    for( int y = 0; y < croppedImage.rows; y++ ) {
        for( int x = 0; x < croppedImage.cols; x++ ){
            for( int z = 0; z < 3; z++){
                samples.at<float>(y + x*croppedImage.rows, z) = croppedImage.at<cv::Vec3b>(y,x)[z];
            }
        }
    }
    
    int clusterCount = numberOfColors;
    cv::Mat labels;
    int attempts = 10;
    cv::Mat centers;
    
    cv::kmeans(samples,
               clusterCount,
               labels,
               cv::TermCriteria(cv::TermCriteria::MAX_ITER + cv::TermCriteria::EPS,
                                50,
                                0.0001),
               attempts, cv::KMEANS_PP_CENTERS, centers );
    
    for (int i = 0; i < clusterCount; i ++){
        [colorArray addObject:[UIColor colorWithRed:CGFloat(centers.at<float>(i, 0)) / 255
                                              green:CGFloat(centers.at<float>(i, 1)) / 255
                                               blue:CGFloat(centers.at<float>(i, 2)) / 255
                                              alpha:1]];
    }
    
    return colorArray;
    
}
//**************************************





//**************************************
- (void)startVideo
{
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront; // Use the front camera
    if (![videoCamera running]){
        [videoCamera start];}
    [self getBackground];
}

- (void)stopVideo
{
    if ([videoCamera running]){
        [videoCamera stop];}
}

- (void) switchVideoCamera{
    [videoCamera stop];
    UIImageView *parentView = (UIImageView *)videoCamera.parentView;
    AVCaptureDevicePosition position = videoCamera.defaultAVCaptureDevicePosition;
    
    
    [self createOpenCVVideoCameraWithImageView:parentView];
    if (position == AVCaptureDevicePositionFront ){
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    }
    else{
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront; // Use the front camera
    }
    
    [videoCamera start];
}
//**************************************


//**************************************
- (void) startPhoto
{
    if (![photoCamera running]){
        [photoCamera start];}
    
}

- (void) stopPhoto
{
    if ([photoCamera running]){
        [photoCamera stop];}
}



- (void) switchPhotoCamera{
    [photoCamera stop];
    UIImageView *parentView = (UIImageView *)photoCamera.parentView;
    AVCaptureDevicePosition position = photoCamera.defaultAVCaptureDevicePosition;
    
    [self createOpenCVPhotoCameraWithImageView:parentView];
    if (position == AVCaptureDevicePositionFront ){
        photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    }
    else{
        photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront; // Use the back camera
    }
    
    [photoCamera start];
}
//**************************************

@end
