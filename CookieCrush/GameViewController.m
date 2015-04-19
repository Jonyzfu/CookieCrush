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
// You don't need to add the framework to project seperately.
@import AVFoundation;

@interface GameViewController ()

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) GameScene *scene;

@property (assign, nonatomic) NSUInteger movesLeft;
@property (assign, nonatomic) NSUInteger score;

@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UIImageView *gameOverPanel;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;

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
    self.movesLeft = self.level.maximumMoves;
    self.score = 0;
    [self updateLabels];
    [self.level resetComboMultiplier];
    [self.scene animateBeginGame];
    [self shuffle];
}

- (void)shuffle {
    [self.scene removeAllCookiesSprites];
    NSSet *newCookies = [self.level shuffle];
    [self.scene addSpritesForCookies:newCookies];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameOverPanel.hidden = YES;
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
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Mining by Moonlight" withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    [self.backgroundMusic play];
    
    // Start the game.
    [self beginGame];
}

- (void)updateLabels {
    self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
    self.movesLabel.text = [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)self.score];
}

- (void)handleMatches {
    NSSet *chains = [self.level removeMatches];
    if ([chains count] == 0) {
        [self beginNextTurn];
        return;
    }
    
    [self.scene animateMatchedCookies:chains completion:^{
        
        for (Chain *chain in chains) {
            self.score += chain.score;
        }
        [self updateLabels];
        NSArray *columns = [self.level fillHoles];
        [self.scene animateFallingCookies:columns completion:^{
            NSArray *columns = [self.level topUpCookies];
            [self.scene animateNewCookies:columns completion:^{
                [self handleMatches];
            }];
        }];
    }];
}

- (void)decrementMoves {
    self.movesLeft--;
    [self updateLabels];
    if (self.score >= self.level.targetScore) {
        self.gameOverPanel.image = [UIImage imageNamed:@"LevelComplete"];
        [self showGameOver];
    } else if (self.movesLeft == 0) {
        self.gameOverPanel.image = [UIImage imageNamed:@"GameOver"];
        [self showGameOver];
    }
}

- (void)beginNextTurn {
    [self.level resetComboMultiplier];
    [self.level detectPossibleSwaps];
    [self decrementMoves];
    self.view.userInteractionEnabled = YES;
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

- (void)showGameOver {
    [self.scene animateGameOver];
    self.gameOverPanel.hidden = NO;
    self.shuffleButton.hidden = YES;
    self.scene.userInteractionEnabled = NO;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGameOver)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)hideGameOver {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    self.gameOverPanel.hidden = YES;
    self.shuffleButton.hidden = NO;
    self.scene.userInteractionEnabled = YES;
    
    [self beginGame];
}

- (IBAction)shuffleButtonPressed:(id)sender {
    [self shuffle];
    [self decrementMoves];
}

@end
