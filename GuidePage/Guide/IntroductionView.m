//
//  IntroductionView.m
//  GuidePage
//
//  Created by Thomson on 15/11/24.
//  Copyright © 2015年 Kemi. All rights reserved.
//

#import "IntroductionView.h"
#import "GuideMacros.h"
#import <Masonry.h>

static CGFloat const PageControlHeight = 30.0;

@interface IntroductionView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *pagingScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

/** introduction images */
@property (nonatomic, strong) NSArray *imageNames;
/** introduction imageViews */
@property (nonatomic, strong) NSArray *scrollViewPages;

@end

@implementation IntroductionView

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.imageNames = @[ @"guide_page_1.jpg", @"guide_page_2.jpg", @"guide_page_3.jpg" ];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.pagingScrollView];
    [self.view addSubview:self.pageControl];

    [self.pagingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.edges.equalTo(self.view);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.and.right.equalTo(self.view);
        make.top.equalTo(@(kScreenHeight - PageControlHeight));
        make.height.equalTo(@(PageControlHeight));
    }];

    [self loadPages];
}

- (void)loadPages
{
    self.pageControl.numberOfPages = [self numberOfPagesInPagingScrollView];
    self.pagingScrollView.contentSize = [self contentSizeOfScrollView];

    __block CGFloat x = 0;
    [[self scrollViewPages] enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop)
     {
         imageView.frame = CGRectMake(x, 0, kScreenWidth, kScreenHeight);
         [self.pagingScrollView addSubview:imageView];

         x += kScreenWidth;
     }];

    if (self.pageControl.numberOfPages == 1)
    {
        self.pageControl.alpha = 0;
    }

    // fix ScrollView can not scrolling if it have only one page
    if (self.pagingScrollView.contentSize.width == self.pagingScrollView.frame.size.width)
    {
        self.pagingScrollView.contentSize = CGSizeMake(self.pagingScrollView.contentSize.width + 1, self.pagingScrollView.contentSize.height);
    }
}

- (UIImageView *)imageViewWithName:(NSString *)imageName
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;

    return imgView;
}

- (CGSize)contentSizeOfScrollView
{
    return CGSizeMake(kScreenWidth * self.scrollViewPages.count, kScreenHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / (scrollView.contentSize.width / [self numberOfPagesInPagingScrollView]);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0)
    {
        if (![self hasNext:self.pageControl])
        {
            __weak __typeof(self)weakSelf = self;

            [UIView animateWithDuration:1.f
                             animations:^{

                                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                                 strongSelf.view.alpha = 0;
                             }
                             completion:^(BOOL finished) {

                                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                                 [strongSelf.view removeFromSuperview];
                             }];
            
            double delayInSeconds = 0.8;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                __strong __typeof(weakSelf)strongSelf = weakSelf;

                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(finished)])
                {
                    [strongSelf.delegate finished];
                }
            });
        }
    }
}

#pragma mark - UIScrollView & UIPageControl DataSource

- (BOOL)hasNext:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages > pageControl.currentPage + 1;
}

- (BOOL)isLast:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages == pageControl.currentPage + 1;
}

- (NSInteger)numberOfPagesInPagingScrollView
{
    return [[self imageNames] count];
}

- (void)pagingScrollViewDidChangePages:(UIScrollView *)pagingScrollView
{
    if ([self isLast:self.pageControl])
    {
        if (self.pageControl.alpha == 1)
        {
            __weak __typeof(self)weakSelf = self;

            [UIView animateWithDuration:0.4
                             animations:^{

                                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                                 strongSelf.pageControl.alpha = 0;
                             }];
        }
    }
    else
    {
        if (self.pageControl.alpha == 0)
        {
            __weak __typeof(self)weakSelf = self;

            [UIView animateWithDuration:0.4
                             animations:^{

                                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                                 strongSelf.pageControl.alpha = 1;
                             }];
        }
    }
}

#pragma mark - getter & setter

- (UIScrollView *)pagingScrollView
{
    if (_pagingScrollView)
    {
        return _pagingScrollView;
    }

    _pagingScrollView = [UIScrollView new];
    _pagingScrollView.delegate = self;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;

    return _pagingScrollView;
}

- (UIPageControl *)pageControl
{
    if (_pageControl)
    {
        return _pageControl;
    }

    _pageControl = [UIPageControl new];
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.enabled = NO;

    return _pageControl;
}

- (NSArray *)scrollViewPages
{
    if (self.imageNames.count == 0)
    {
        return nil;
    }

    if (_scrollViewPages)
    {
        return _scrollViewPages;
    }

    __block NSMutableArray *array = [NSMutableArray new];

    [self.imageNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        UIImageView *imageView = [self imageViewWithName:obj];
        [array addObject:imageView];
    }];

    _scrollViewPages = array;

    return _scrollViewPages;
}

@end
