//
//  YXCycleLabel.h
//
//  Created by majianghai on 2019/1/14.
//

#import "YXCycleLabel.h"

//单次循环的时间
static const NSInteger animationDuration = 15;

@interface YXCycleLabel()<CAAnimationDelegate>
{
    //左侧label的frame
    CGRect currentFrame;
    
    //右侧label的frame
    CGRect behindFrame;
    
    //存放左右label的数组
    NSMutableArray *labelArray;
    
    //label的高度
    CGFloat labelHeight;
}
@property (nonatomic, strong) UILabel *firstLB;
@property (nonatomic, strong) UILabel *secondLB;
@end

@implementation YXCycleLabel

- (void)setupFrame  {
    
    if (self.secondLB.text == nil ||
        self.secondLB.font == nil ||
        self.secondLB.textColor == nil)
    {return;}
    
    CGFloat viewHeight = self.frame.size.height;
    labelHeight = viewHeight;
    
    //计算文本的宽度
    CGFloat calcuWidth = [self widthForTextString:self.secondLB.text height:labelHeight font:self.font];
    
    //这两个frame很重要 分别记录的是左右两个label的frame 而且后面也会需要到这两个frame
    currentFrame = CGRectMake(0, 0, calcuWidth, labelHeight);
    behindFrame = CGRectMake(currentFrame.origin.x+currentFrame.size.width, 0, calcuWidth, labelHeight);
    
    self.firstLB.frame = currentFrame;
    [self addSubview:self.firstLB];
    
    labelArray = [NSMutableArray arrayWithObject:self.firstLB];
    
    //如果文本的宽度大于视图的宽度才开始跑
    if (calcuWidth> self.frame.size.width) {
        self.secondLB.frame = behindFrame;
        [labelArray addObject:self.secondLB];
        [self addSubview:self.secondLB];
        
        [self doCustomAnimation];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setText:(NSString *)text {
    
    text = [text stringByAppendingString:@"           "];
    self.firstLB.text = text;
    self.secondLB.text = text;
    [self setupFrame];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    
    self.firstLB.textColor = textColor;
    self.secondLB.textColor = textColor;
    [self setupFrame];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    self.firstLB.font = font;
    self.secondLB.font = font;
    [self setupFrame];
}

- (UILabel *)firstLB {
    if (_firstLB == nil) {
        _firstLB = [UILabel new];
    }
    return _firstLB;
}

- (UILabel *)secondLB {
    if (_secondLB == nil) {
        _secondLB = [UILabel new];
    }
    return _secondLB;
}


- (void)doCustomAnimation
{
    //取到两个label
    UILabel *lableOne = labelArray[0];
    UILabel *lableTwo = labelArray[1];
    
    [lableOne.layer removeAnimationForKey:@"LabelOneAnimation"];
    [lableTwo.layer removeAnimationForKey:@"LabelTwoAnimation"];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.values = @[[NSValue valueWithCGPoint:CGPointMake(lableOne.frame.origin.x+currentFrame.size.width/2, lableOne.frame.origin.y+labelHeight/2)],[NSValue valueWithCGPoint:CGPointMake(lableOne.frame.origin.x-currentFrame.size.width/2, lableOne.frame.origin.y+labelHeight/2)]];
    animation.duration = animationDuration;
    animation.delegate = self;
    animation.calculationMode = kCAAnimationLinear;
    animation.removedOnCompletion = NO;
    [lableOne.layer addAnimation:animation forKey:@"LabelOneAnimation"];
    
    
    CAKeyframeAnimation *animationTwo = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animationTwo.values = @[[NSValue valueWithCGPoint:CGPointMake(lableTwo.frame.origin.x+currentFrame.size.width/2, lableTwo.frame.origin.y+labelHeight/2)],[NSValue valueWithCGPoint:CGPointMake(lableTwo.frame.origin.x-currentFrame.size.width/2, lableTwo.frame.origin.y+labelHeight/2)]];
    animationTwo.duration = animationDuration;
    animationTwo.delegate = self;
    animationTwo.removedOnCompletion = NO;
    animationTwo.calculationMode = kCAAnimationLinear;
    
    [lableTwo.layer addAnimation:animationTwo forKey:@"LabelTwoAnimation"];
}



- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    UILabel *lableOne = labelArray[0];
    UILabel *lableTwo = labelArray[1];
    
    if (anim == [lableOne.layer animationForKey:@"LabelOneAnimation"]) {
        
        //两个label水平相邻摆放 内容一样 label1为初始时展示的 label2位于界面的右侧，未显示出来
        //当完成动画时，即第一个label在界面中消失，第二个label位于第一个label的起始位置时，把第一个label放置到第二个label的初始位置
        lableOne.frame = behindFrame;
        
        lableTwo.frame = currentFrame;
        
        //在数组中将第一个label放置到右侧，第二个label放置到左侧（因为此时展示的就是labelTwo）
        [labelArray replaceObjectAtIndex:1 withObject:lableOne];
        [labelArray replaceObjectAtIndex:0 withObject:lableTwo];
        
        [self doCustomAnimation];
    }
}


- (CGFloat) widthForTextString:(NSString *)tStr height:(CGFloat)tHeight font:(UIFont *)font{
    
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGRect rect = [tStr boundingRectWithSize:CGSizeMake(MAXFLOAT, tHeight) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width+5;
}


- (void)start
{
    UILabel *lableOne = labelArray[0];
    [self resumeLayer:lableOne.layer];
    
    UILabel *lableTwo = labelArray[1];
    [self resumeLayer:lableTwo.layer];
}


//恢复动画
- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pauseTime = [layer timeOffset];
    
    layer.speed = 1.0;
    
    layer.timeOffset = 0.0;
    
    layer.beginTime = 0.0;
    
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil]-pauseTime;
    
    layer.beginTime = timeSincePause;
}


@end
