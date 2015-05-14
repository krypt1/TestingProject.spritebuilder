#import "MainScene.h"

static const float scrollSpeed = -80.f;

static const CGFloat firstObstaclePosition = 600.f;
static const CGFloat distanceBetweenObstacles = -160.f;

@implementation MainScene
{
//variables
CCPhysicsNode *_physicsNode;
CCNode *_wall1;
CCNode *_wall2;
NSArray *_walls;
NSMutableArray *_obstacles;
}

-(void)didLoadFromCCB
{
    _walls = @[_wall1, _wall2];
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
}

-(void)spawnNewObstacle
{
    //Last object in obstacles array
    CCNode *previousObstacle = [_obstacles lastObject];
    
    CGFloat previousObstacleYPosition = previousObstacle.position.y;
    if (!previousObstacle) {
        //this is the first obstacle
        previousObstacleYPosition = firstObstaclePosition;
    }
    
    CCNode *obstacle = [CCBReader load:@"Obstacle"];
    obstacle.position = ccp(0, previousObstacleYPosition + distanceBetweenObstacles);
    //Add obstacle to the container of z-order 0
    [_physicsNode addChild:obstacle];
    //Insert obstacle at the end of the array
    [_obstacles addObject:obstacle];
    
}

- (void)update:(CCTime)delta {
    
    _physicsNode.position = ccp(_physicsNode.position.x, _physicsNode.position.y - (scrollSpeed *delta));
    
    // loop the ground
    for (CCNode *wall in _walls) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:wall.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.y <= (-1 * wall.contentSize.height)) {
            wall.position = ccp(wall.position.x, wall.position.y + 2 * wall.contentSize.height);
        }
    }
    
    
    
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles)
    {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        
        if (obstacleScreenPosition.y > (_physicsNode.contentSize.height + obstacle.contentSize.height))
        {
            if (!offScreenObstacles)
            {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles)
    {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        //for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
}


@end
