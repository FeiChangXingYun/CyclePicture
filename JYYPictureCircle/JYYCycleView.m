//
//  JYYCycleView.m
//  JYYPictureCircle
//
//  Created by Yanyan Jiang on 2017/11/29.
//  Copyright © 2017年 Yanyan Jiang. All rights reserved.
//

#import "JYYCycleView.h"
#import "JYYCollectionViewCell.h"
@interface JYYCycleView()<UICollectionViewDelegate,UICollectionViewDataSource>{
    JYYCollectionViewCell *_lastCell;
    JYYCollectionViewCell *_showingCell;
    JYYCollectionViewCell *_nextCell;
}

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIPageControl *pageControl;
//当前显示图像的索引
@property (assign, nonatomic) NSInteger currentIndex;


@end

@implementation JYYCycleView

static NSString * const reuserIdentifier = @"cell";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentIndex = 0;
        [self.collectionView registerClass:[JYYCollectionViewCell class] forCellWithReuseIdentifier:reuserIdentifier];
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        [self addTimer];
    }
    return self;
}

#pragma mark -setter & getter
-(UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.itemSize = self.bounds.size;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}


-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-50, self.bounds.size.width, 50)];
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor magentaColor];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        [_pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}



#pragma mark -UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JYYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserIdentifier forIndexPath:indexPath];
    //刚开始向右滑动的时候indexPath.item是2 但调用 dispatch_async(dispatch_get_main_queue(), ^{
    //[scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width, 0) animated:NO];
    //    });时indexPath.item就会变成1;   2，1    2，1    2，1    2，1
    
    //如果向左滑动的时候indexPath.item是0,但是调用dispatch_async(dispatch_get_main_queue(), ^{
    //[scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width, 0) animated:NO];
    // });时indexPath.item就会变成1;      0，1    0，1    0，1    0，1
    NSInteger index = (indexPath.item-1+self.imageURLS.count+self.currentIndex)%self.imageURLS.count;
    cell.imageUrl = self.imageURLS[index];
    //indexPath.item == 0 时显示的是最后一张图片
    //indexPath.item == 1 时显示的是第0张图片
    //indexPath.item == 2 时显示的是第1张图片
        switch (indexPath.item) {
        case 0:
            _lastCell = cell;
            break;
        case 1:
            _showingCell = cell;
            break;
        case 2:
            _nextCell = cell;
            break;
        default:
            break;
    }
    return cell;
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger offSet = scrollView.contentOffset.x/scrollView.bounds.size.width-1;
    //如果页面没有变化，直接返回；offSet 只有 -1,0,1 三个值
    if (offSet == 0){
        return;
    }
    //在这里 offset 只有 -1，1;向右滑一直是加+1(也就是说offset是1);向左滑一直是加-1(也就是说offset是-1)
    self.currentIndex = (self.currentIndex+offSet+self.imageURLS.count)%self.imageURLS.count;
    self.pageControl.currentPage = self.currentIndex;//设置指示器的当前指示页
    //滑动结束之后indexPath.item的索引始终是1
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.currentIndex==0){
            _lastCell.imageUrl = self.imageURLS[self.imageURLS.count-1];
        }else{
            _lastCell.imageUrl = self.imageURLS[self.currentIndex-1];
        }
        if(self.currentIndex == self.imageURLS.count-1){
            _nextCell.imageUrl = self.imageURLS[0];
        }else{
            _nextCell.imageUrl = self.imageURLS[self.currentIndex+1];
        }
        _showingCell.imageUrl = self.imageURLS[self.currentIndex];
        [self.collectionView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
    });
    
}


//开始拖拽时调用此方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //移除定时器
    [self removeTimer];
}


//停止拖拽时调用此方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}


#pragma mark 自定义方法
//添加定时器
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scrollViewPageController) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}


//移除定时器
-(void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}


//定时器绑定的方法
- (void)scrollViewPageController{
    //自动滚动到第二个item(第一种方法)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:CGPointMake(2*self.bounds.size.width, 0) animated:YES];
    });
    
    //在动画结束后 调用停止的方法 返回第一个item
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        [self scrollViewDidEndDecelerating:self.collectionView];
    });
}


#pragma mark -addTarget(pageControl绑定的方法)
- (void)pageControlChanged:(UIPageControl*)pageControl{
    [self removeTimer];
    [self scrollViewPageController];
    [self addTimer];
}


-(void)setImageURLS:(NSArray *)imageURLS{
    _imageURLS = imageURLS;
    self.pageControl.numberOfPages = self.imageURLS.count;
}

#pragma mark -UICollectionViewDelegate
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
