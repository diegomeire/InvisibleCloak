//
//  OpenCVWrapper.h
//  InvisibleCloak
//
//  Created by Diego Meire on 31/07/19.
//  Copyright © 2019 Diege Miere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol OpenCVWrapperDelegate

- (void) pictureTakenWithColors:(NSArray *)colors;

@end


@interface OpenCVWrapper : NSObject



- (instancetype)init;
- (void) createOpenCVVideoCameraWithImageView:(UIImageView *)imageView;
- (void) startVideo;
- (void) stopVideo;
- (void) switchVideoCamera;
    
- (void) createOpenCVPhotoCameraWithImageView:(UIImageView *)imageView;
- (void) startPhoto;
- (void) stopPhoto;
- (void) takePicture;
- (void) switchPhotoCamera;

- (void) getBackground;
+ (instancetype)shared;

- (NSArray*) getColors;
- (NSArray*) getColors:(int)numberOfColors useSaliency:(bool)saliency;
- (NSArray*) getColorsForImage:(UIImage *)image;

- (void) clearColorsToFind;
- (void) addColorToFind:(UIColor *)color;


@property (nonatomic, assign) CGFloat hue;
@property (nonatomic, assign) CGFloat saturation;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) bool fullColorRange;


@property (nonatomic, assign) int numberOfMeanColors;

@property (nonatomic, weak) id <OpenCVWrapperDelegate> delegate;



@end

