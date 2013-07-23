//
//  MazeViewController.m
//  Maze
//
//  Created by Gabriela Leichnitz on 7/22/13.
//  Copyright (c) 2013 Gabriela Leichnitz. All rights reserved.
//

#import "MazeViewController.h"

@interface MazeViewController ()

@end

@implementation MazeViewController

- (void)collisionWithWalls {
    
    CGRect frame = self.pacman.frame;
    frame.origin.x = self.currentPoint.x;
    frame.origin.y = self.currentPoint.y;
    
    for (UIImageView *image in self.wall) {
        
        if (CGRectIntersectsRect(frame, image.frame)) {
            
            // Compute collision angle
            CGPoint pacmanCenter = CGPointMake(frame.origin.x + (frame.size.width / 2),
                                               frame.origin.y + (frame.size.height / 2));
            CGPoint imageCenter  = CGPointMake(image.frame.origin.x + (image.frame.size.width / 2),
                                               image.frame.origin.y + (image.frame.size.height / 2));
            CGFloat angleX = pacmanCenter.x - imageCenter.x;
            CGFloat angleY = pacmanCenter.y - imageCenter.y;
            
            if (abs(angleX) > abs(angleY)) {
                _currentPoint.x = self.previousPoint.x;
                self.pacmanXVelocity = -(self.pacmanXVelocity / 2.0);
            } else {
                _currentPoint.y = self.previousPoint.y;
                self.pacmanYVelocity = -(self.pacmanYVelocity / 2.0);
            }
            
        }
        
    }
    
}

- (void)collisionWithGifts {
    
    CALayer *giftLayer1 = [self.gift1.layer presentationLayer];
    CALayer *giftLayer2 = [self.gift2.layer presentationLayer];
    CALayer *giftLayer3 = [self.gift3.layer presentationLayer];
    
    if (CGRectIntersectsRect(self.pacman.frame, giftLayer1.frame)
        || CGRectIntersectsRect(self.pacman.frame, giftLayer2.frame)
        || CGRectIntersectsRect(self.pacman.frame, giftLayer3.frame) ) {
        
        self.currentPoint  = CGPointMake(0, 144);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Mission Failed!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void)collisionWithExit {
    
    if (CGRectIntersectsRect(self.pacman.frame, self.exit.frame)) {
        
        [self.motionManager stopAccelerometerUpdates];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                        message:@"You've won the game!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void)collisionWithBoundaries {
    
    if (self.currentPoint.x < 0) {
        _currentPoint.x = 0;
        self.pacmanXVelocity = -(self.pacmanXVelocity / 2.0);
    }
    
    if (self.currentPoint.y < 0) {
        _currentPoint.y = 0;
        self.pacmanYVelocity = -(self.pacmanYVelocity / 2.0);
    }
    
    if (self.currentPoint.x > self.view.bounds.size.width - self.pacman.image.size.width) {
        _currentPoint.x = self.view.bounds.size.width - self.pacman.image.size.width;
        self.pacmanXVelocity = -(self.pacmanXVelocity / 2.0);
    }
    
    if (self.currentPoint.y > self.view.bounds.size.height - self.pacman.image.size.height) {
        _currentPoint.y = self.view.bounds.size.height - self.pacman.image.size.height;
        self.pacmanYVelocity = -(self.pacmanYVelocity / 2.0);
    }
    
}

- (void)movePacman {
    [self collisionWithWalls];
    
    [self collisionWithExit];
	
    [self collisionWithGifts];
    
    [self collisionWithBoundaries];
    
    self.previousPoint = self.currentPoint;
    
    CGRect frame = self.pacman.frame;
    frame.origin.x = self.currentPoint.x;
    frame.origin.y = self.currentPoint.y;
    
    self.pacman.frame = frame;
    
    // Rotate the main player
    
    CGFloat newAngle = (self.pacmanXVelocity + self.pacmanYVelocity) * M_PI * 4;
    self.angle += newAngle * kUpdateInterval;
    
    CABasicAnimation *rotate;
    rotate                     = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue           = [NSNumber numberWithFloat:0];
    rotate.toValue             = [NSNumber numberWithFloat:self.angle];
    rotate.duration            = kUpdateInterval;
    rotate.repeatCount         = 1;
    rotate.removedOnCompletion = NO;
    rotate.fillMode            = kCAFillModeForwards;
    [self.pacman.layer addAnimation:rotate forKey:@"10"];
}

- (void)update {
    
    NSTimeInterval secondsSinceLastDraw = -([self.lastUpdateTime timeIntervalSinceNow]);
    
    self.pacmanYVelocity = self.pacmanYVelocity - (self.acceleration.x * secondsSinceLastDraw);
    self.pacmanXVelocity = self.pacmanXVelocity - (self.acceleration.y * secondsSinceLastDraw);
    
    CGFloat xDelta = secondsSinceLastDraw * self.pacmanXVelocity * 500;
    CGFloat yDelta = secondsSinceLastDraw * self.pacmanYVelocity * 500;
    
    self.currentPoint = CGPointMake(self.currentPoint.x + xDelta,
                                    self.currentPoint.y + yDelta);
    
    [self movePacman];
    
    self.lastUpdateTime = [NSDate date];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //movement of gifts
    CGPoint origin1 = self.gift1.center;
    CGPoint target1 = CGPointMake(self.gift1.center.x, self.gift1.center.y-50);
    
    CABasicAnimation *bounce1 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    bounce1.fromValue = [NSNumber numberWithInt:origin1.y];
    bounce1.toValue = [NSNumber numberWithInt:target1.y];
    bounce1.duration = 2;
    bounce1.autoreverses = YES;
    bounce1.repeatCount = HUGE_VALF;
    
    [self.gift1.layer addAnimation:bounce1 forKey:@"position"];
    
    CGPoint origin2 = self.gift2.center;
    CGPoint target2 = CGPointMake(self.gift2.center.x, self.gift2.center.y+100);
    CABasicAnimation *bounce2 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    bounce2.fromValue = [NSNumber numberWithInt:origin2.y];
    bounce2.toValue = [NSNumber numberWithInt:target2.y];
    bounce2.duration = 2;
    bounce2.repeatCount = HUGE_VALF;
    bounce2.autoreverses = YES;
    [self.gift2.layer addAnimation:bounce2 forKey:@"position"];
    
    CGPoint origin3 = self.gift3.center;
    CGPoint target3 = CGPointMake(self.gift3.center.x, self.gift3.center.y-300);
    CABasicAnimation *bounce3 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    bounce3.fromValue = [NSNumber numberWithInt:origin3.y];
    bounce3.toValue = [NSNumber numberWithInt:target3.y];
    bounce3.duration = 2;
    bounce3.repeatCount = HUGE_VALF;
    bounce3.autoreverses = YES;
    [self.gift3.layer addAnimation:bounce3 forKey:@"position"];
    
    //movement of pacman
    self.lastUpdateTime = [[NSDate alloc] init];
    
    self.currentPoint  = CGPointMake(0, 144);
    self.motionManager = [[CMMotionManager alloc]  init];
    self.queue         = [[NSOperationQueue alloc] init];
    
    self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
    
    [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error) {
         [(id) self setAcceleration:accelerometerData.acceleration];
         [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
     }];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
