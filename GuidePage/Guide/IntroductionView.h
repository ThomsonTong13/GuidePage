//
//  IntroductionView.h
//  GuidePage
//
//  Created by Thomson on 15/11/24.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IntroductionDelegate;

@interface IntroductionView : UIViewController

@property (nonatomic, weak) id<IntroductionDelegate> delegate;

@end

@protocol IntroductionDelegate <NSObject>

- (void)finished;

@end
