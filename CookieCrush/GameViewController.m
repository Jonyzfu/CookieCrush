//
//  GameViewController.m
//  CookieCrush
//
//  Created by Jonyzfu on 4/14/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "Level.h"

@interface GameViewController ()

@property(strong, nonatomic) Level *level;
@property(strong, nonatomic) GameScene *scene;

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)beginGame {
    [self shuffle];
}

- (void)shuffle {
    NSSet *newCookies = [self.level shuffle];
    [self.scene addSpritesForCookies:newCookies];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
    /*
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    * Sprite Kit applies additional optimizations to improve rendering performance *
    skView.ignoresSiblingOrder = YES;
    */
    
    // Create and configure the scene.
    self.scene = [GameScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Load the level.
    self.level = [[Level alloc] initWithFile:@"Level_1"];
    self.scene.level = self.level;
    
    // Load the Tile.
    [self.scene addTiles];
    
    // Create the block and assign it to Scene's swipeHandler property
    id block = ^(Swap *swap) {
        // While the animation is happening, it's not able to touch anything else
        self.view.userInteractionEnabled = NO;
        
        if ([self.level isPossibleSwap:swap]) {
            // Update the data model
            [self.level performSwap:swap];
            
            // Update the view
            [self.scene animateSwap:swap completion:^{
                [self handleMatches];
            }];
        } else {
            [self.scene animateInvalidSwap:swap completion:^ {
                self.view.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    
    // Present the scene.
    [skView presentScene:self.scene];
    
    // Start the game.
    [self beginGame];
}

- (void)handleMatches {
    NSSet *chains = [self.level removeMatches];
    // Todo
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
