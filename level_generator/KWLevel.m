//
//  KWLevel.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "KWLevel.h"
#import "KWLevelCell.h"
#import "ShortestPathStep.h"
#import "WallObject.h"

@implementation KWLevel

-(instancetype)initWithLevelSize:(CGSize)levelSize{
    if (self = [super init]) {
        _levelSize = levelSize;
        _chanceToBecomeWall = 0.35;
        _floorsToWallConversion = 4;
        _wallsToFloorConversion = 3;
        _numberOfTransitionSteps = 10;
        _connectedCave = NO;
    }
    
    return self;
}

-(void)generateWithSeed:(unsigned int)seed {
    
    NSLog(@"Generating cave...");
    NSDate *startDate = [NSDate date];
    
    srandom(seed);
    
    [self initializeGrid];
    
    for (NSUInteger step = 0; step < self.numberOfTransitionSteps; step++) {
        [self transitionStep];
    }
    
    [self identifyCaverns];
    
    if (self.connectedCave) {
        [self connectToMainCavern];
    } else {
        [self removeDisconnectedCaverns];
    }
    
    [self identifyCaverns];
    
    [self generateTiles];
    
    NSLog(@"Generated cave in %f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
    
}

-(CGPoint)randomPositionInMainPlayArea {
    
    NSUInteger mainCavernIndex = [self mainCavernIndex];
    NSArray *mainCavern = (NSArray *)self.caverns[mainCavernIndex];
    
    NSUInteger mainCavernCount = [mainCavern count];
    KWLevelCell *entranceCell = (KWLevelCell *)mainCavern[arc4random() % mainCavernCount];
    
    return [self positionForGirdCoordinate:entranceCell.coordinate];
}

-(void)initializeGrid {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.levelSize.height];
    
    for (uint32_t y = 0; y < self.levelSize.height; y++) {
        
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.levelSize.width];
        
        for (uint32_t x = 0; x < self.levelSize.width; x++) {
            CGPoint coordiante = CGPointMake(x, y);
            KWLevelCell *cell = [[KWLevelCell alloc] initWithCoordinate:coordiante];
            if ([self isEdgeAtGridCoordinate:coordiante]) {
                cell.type = LevelCellType_Wall;
            } else {
                cell.type = [self randomNumberBetween0and1] < self.chanceToBecomeWall ? LevelCellType_Wall : LevelCellType_Floor;
            }
            [row addObject:cell];
        }
        
        [temp addObject:row];
    }
    
    self.grid = [NSArray arrayWithArray:temp];
}

-(void)generateTiles {
    for (uint32_t y = 0; y < self.levelSize.height; y++){
        for (uint32_t x = 0; x < self.levelSize.width; x++) {
            
            KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(x, y)];
            
            if (!cell) continue;
            
            SKSpriteNode *node;
            
            switch (cell.type) {
                case LevelCellType_Invalid: {
                    break;
                }
                case LevelCellType_Wall: {
                    
                    node = [WallObject basicWall];
                    
                    NSArray *sorrundingCells = [self adjacentCellsForCellCoordinate:CGPointMake(x, y)];
                    for (KWLevelCell* cell in sorrundingCells){
                        if (cell.type == LevelCellType_Floor) {
                            [(WallObject*)node setupWallPhysics];
                            break;
                        }
                    }
                    
                    break;
                }
                case LevelCellType_Floor: {
                    node = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(kTileSize, kTileSize)];
                    
                    break;
                }
                case LevelCellType_Max: {
                    break;
                }
            }
            
            if (node)
            {
                node.position = [self positionForGirdCoordinate:CGPointMake(x, y)];
                [self addChild:node];
            }
            
        }
    }
}

-(void)transitionStep {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.levelSize.height];
    
    for (NSUInteger y = 0; y < self.levelSize.height; y++) {
        
        NSMutableArray *newRow = [NSMutableArray arrayWithCapacity:self.levelSize.width];
        
        for (NSUInteger x = 0; x < self.levelSize.width; x++) {
            
            CGPoint coordiante = CGPointMake(x , y);
            
            NSUInteger mooreNeighborWallCount = [self countWallMooreNeighborsFromGridCoordinate:coordiante];
            
            KWLevelCell *oldCell = [self levelCellFromGridCoordinate:coordiante];
            KWLevelCell *newCell = [[KWLevelCell alloc] initWithCoordinate:coordiante];
            
            if (oldCell.type == LevelCellType_Wall) {
                newCell.type = (mooreNeighborWallCount < self.wallsToFloorConversion) ? LevelCellType_Floor : LevelCellType_Wall;
            } else {
                newCell.type = (mooreNeighborWallCount > self.floorsToWallConversion) ? LevelCellType_Wall : LevelCellType_Floor;
            }
            [newRow addObject:newCell];
        }
        
        [temp addObject:newRow];
    }
    
    self.grid = [NSArray arrayWithArray:temp];
}

-(void)identifyCaverns{
    self.caverns = [NSMutableArray new];
    
    NSMutableArray *floodFillArray = [NSMutableArray arrayWithCapacity:self.levelSize.height];
    
    for (NSUInteger y = 0; y < self.levelSize.height; y++) {
        
        NSMutableArray *floodFillArrayRow = [NSMutableArray arrayWithCapacity:self.levelSize.width];
        
        for (NSUInteger x = 0; x < self.levelSize.width; x++) {
            KWLevelCell *cellToCopy = (KWLevelCell*)[[self.grid objectAtIndex:y] objectAtIndex:x];
            KWLevelCell *copiedCell = [[KWLevelCell alloc] initWithCoordinate:cellToCopy.coordinate];
            copiedCell.type = cellToCopy.type;
            [floodFillArrayRow addObject:copiedCell];
        }
        
        [floodFillArray addObject:floodFillArrayRow];
    }
    
    NSInteger fillNumber = LevelCellType_Max;
    for (NSUInteger y = 0; y < self.levelSize.height; y++) {
        for (NSUInteger x = 0; x < self.levelSize.width; x++) {
            KWLevelCell *cell = (KWLevelCell*)[[floodFillArray objectAtIndex:y] objectAtIndex:x];
            if (cell.type == LevelCellType_Floor) {
                [self.caverns addObject:[NSMutableArray array]];
                [self floodFillCavern:floodFillArray fromCoordinate:CGPointMake(x, y) fillNumber:fillNumber];
                fillNumber++;
            }
        }
    }
    
    NSLog(@"Number of caverns in cave: %lu", (unsigned long)[self.caverns count]);
}

-(void)floodFillCavern:(NSMutableArray*)array fromCoordinate:(CGPoint)coordinate fillNumber:(NSUInteger)fillNumber {
    
    KWLevelCell *cell = (KWLevelCell*)[[array objectAtIndex:coordinate.y] objectAtIndex:coordinate.x];
    
    if (cell.type != LevelCellType_Floor) return;
    
    cell.type = fillNumber;
    
    [[self.caverns lastObject] addObject:cell];
    
    if (coordinate.x > 0) {
        [self floodFillCavern:array fromCoordinate:CGPointMake(coordinate.x - 1, coordinate.y)
                   fillNumber:fillNumber];
    }
    if (coordinate.x < self.levelSize.width - 1) {
        [self floodFillCavern:array fromCoordinate:CGPointMake(coordinate.x + 1, coordinate.y)
                   fillNumber:fillNumber];
    }
    if (coordinate.y > 0) {
        [self floodFillCavern:array fromCoordinate:CGPointMake(coordinate.x, coordinate.y - 1)
                   fillNumber:fillNumber];
    }
    if (coordinate.y < self.levelSize.height - 1) {
        [self floodFillCavern:array fromCoordinate:CGPointMake(coordinate.x, coordinate.y + 1)
                   fillNumber:fillNumber];
    }
    
}

-(NSInteger)mainCavernIndex {
    NSInteger mainCavernIndex = -1;
    NSUInteger maxCavernSize = 0;
    
    for (NSUInteger i = 0; i < self.caverns.count; i++) {
        
        NSUInteger caveCellCount = ((NSArray*)[self.caverns objectAtIndex:i]).count;
        
        if (caveCellCount > maxCavernSize) {
            maxCavernSize = caveCellCount;
            mainCavernIndex = i;
        }
    }
    return mainCavernIndex;
}

-(void)connectToMainCavern {
    NSUInteger mainCavernIndex = [self mainCavernIndex];
    
    NSArray *mainCavern = (NSArray*)[self.caverns objectAtIndex:mainCavernIndex];
    
    for (NSUInteger cavernIndex = 0; cavernIndex < self.caverns.count; cavernIndex++) {
        if (cavernIndex == mainCavernIndex) continue;
        
        NSArray *originalCavern = [self.caverns objectAtIndex:cavernIndex];
        
        KWLevelCell *originalCell = (KWLevelCell*)[originalCavern objectAtIndex:arc4random() % originalCavern.count];
        KWLevelCell *destCell = (KWLevelCell*)[mainCavern objectAtIndex:arc4random() % mainCavern.count];
        
        [self createPathBetweenOrigin:originalCell andDestination:destCell];
    }
}

-(void)createPathBetweenOrigin:(KWLevelCell*)orginCell andDestination:(KWLevelCell*)destination {
    
    NSMutableArray *openSteps = [NSMutableArray new];
    NSMutableArray *closedSteps = [NSMutableArray new];
    
    [self insertStep:[[ShortestPathStep alloc] initWithPosition:orginCell.coordinate] inList:openSteps];
    
    do {
        // Get the lowest F cost step.
        // Because the list is ordered, the first step is always the one with the lowest F cost.
        ShortestPathStep *currentStep = [openSteps firstObject];
        
        // Add the current step to the closed list
        [closedSteps addObject:currentStep];
        
        // Remove it from the open list
        [openSteps removeObjectAtIndex:0];
        
        // If the currentStep is the desired cell coordinate, we are done!
        if (CGPointEqualToPoint(currentStep.position, destination.coordinate)) {
            // Turn the path into floors to connect the caverns
            do {
                if (currentStep.parent != nil) {
                    KWLevelCell *cell = [self levelCellFromGridCoordinate:currentStep.position];
                    cell.type = LevelCellType_Floor;
                }
                currentStep = currentStep.parent; // Go backwards
            } while (currentStep != nil);
            break;
        }
        
        // Get the adjacent cell coordinates of the current step
        NSArray *adjSteps = [self adjacentCellsCoordinateForCellCoordinate:currentStep.position];
        
        for (NSValue *v in adjSteps) {
            ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue]];
            
            // Check if the step isn't already in the closed set
            if ([closedSteps containsObject:step]) {
                continue; // ignore it
            }
            
            // Compute the cost form the current step to that step
            NSInteger moveCost = [self costToMoveFromStep:currentStep toAdjacentStep:step];
            
            // Check if the step is already in the open list
            NSUInteger index = [openSteps indexOfObject:step];
            
            if (index == NSNotFound) { // Not on the open list, so add it
                
                // Set the current step as the parent
                step.parent = currentStep;
                
                // The G score is equal to the parent G score plus the cost to move from the parent to it
                step.gScore = currentStep.gScore + moveCost;
                
                // Compute the H score, which is the estimated move cost to move from that step
                // to the desired cell coordinate
                step.hScore = [self computeHScoreFromCoordinate:step.position
                                                   toCoordinate:destination.coordinate];
                
                // Adding it with the function which is preserving the list ordered by F score
                [self insertStep:step inList:openSteps];
                
            } else { // Already in the open list
                
                // To retrieve the old one, which has its scores already computed
                step = [openSteps objectAtIndex:index];
                
                // Check to see if the G score for that step is lower if we use the current step to get there
                if ((currentStep.gScore + moveCost) < step.gScore) {
                    
                    // The G score is equal to the parent G score plus the cost to move the parent to it
                    step.gScore = currentStep.gScore + moveCost;
                    
                    // Because the G score has changed, the F score may have changed too.
                    // So to keep the open list ordered we have to remove the step, and re-insert it with
                    // the insert function, which is preserving the list ordered by F score.
                    ShortestPathStep *preservedStep = [[ShortestPathStep alloc] initWithPosition:step.position];
                    
                    // Remove the step from the open list
                    [openSteps removeObjectAtIndex:index];
                    
                    // Re-insert the step to the open list
                    [self insertStep:preservedStep inList:openSteps];
                }
            }
        }
        
    } while ([openSteps count] > 0);
    
}

- (void)constructPathFromStep:(ShortestPathStep *)step
{
    do {
        if (step.parent != nil) {
            KWLevelCell *cell = [self levelCellFromGridCoordinate:step.position];
            cell.type = LevelCellType_Floor;
        }
        step = step.parent; // Go backwards
    } while (step != nil);
}

-(void)removeDisconnectedCaverns {
    NSInteger mainCavernIndex = [self mainCavernIndex];
    NSUInteger cavernsCount = self.caverns.count;
    
    if (cavernsCount > 0) {
        for (NSUInteger i = 0; i < cavernsCount; i++) {
            if (i != mainCavernIndex) {
                NSArray *array = (NSArray*)[self.caverns objectAtIndex:i];
                
                for (KWLevelCell *cell in array) {
                    KWLevelCell *realCell = (KWLevelCell*)[[self.grid objectAtIndex:cell.coordinate.y] objectAtIndex:cell.coordinate.x];
                    realCell.type = LevelCellType_Wall;
                }
            }
        }
    }
}

- (void)insertStep:(ShortestPathStep *)step inList:(NSMutableArray *)list {
    NSInteger stepScore = [step fScore];
    NSInteger count = list.count;
    NSInteger i = 0;
    
    for (; i < count; i++) {
        if (stepScore <= [[list objectAtIndex:i] fScore]){
            break;
        }
    }
    
    [list insertObject:step atIndex:i];
    
}

- (NSInteger)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep
{
    // Always returns one, as it is equally expensive to move either up, down, left or right.
    return 1;
}

- (NSInteger)computeHScoreFromCoordinate:(CGPoint)fromCoordinate toCoordinate:(CGPoint)toCoordinate
{
    // Get the cell at the toCoordinate to calculate the hScore
    KWLevelCell *cell = [self levelCellFromGridCoordinate:toCoordinate];
    
    // It is 10 times more expensive to move through wall cells than floor cells.
    NSUInteger multiplier = cell.type == LevelCellType_Wall ? 10 : 1;
    
    return multiplier * (fabs(toCoordinate.x - fromCoordinate.x) + fabs(toCoordinate.y - fromCoordinate.y));
}

-(NSArray*)adjacentCellsForCellCoordinate:(CGPoint)cellCoordinate {
    NSMutableArray *cells = [NSMutableArray new];
    NSArray *cellCoordinates = [self adjacentCellsCoordinateForCellCoordinate:cellCoordinate];
    
    for (NSValue *v in cellCoordinates) {
        [cells addObject:[self levelCellFromGridCoordinate:v.CGPointValue]];
    }
    
    return [NSArray arrayWithArray:cells];
}

- (NSArray *)adjacentCellsCoordinateForCellCoordinate:(CGPoint)cellCoordinate
{
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:4];
    
    // Top
    CGPoint p = CGPointMake(cellCoordinate.x, cellCoordinate.y - 1);
    if ([self isValidCoordinate:p]) {
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    }
    
    // Left
    p = CGPointMake(cellCoordinate.x - 1, cellCoordinate.y);
    if ([self isValidCoordinate:p]) {
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    }
    
    // Bottom
    p = CGPointMake(cellCoordinate.x, cellCoordinate.y + 1);
    if ([self isValidCoordinate:p]) {
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    }
    
    // Right
    p = CGPointMake(cellCoordinate.x + 1, cellCoordinate.y);
    if ([self isValidCoordinate:p]) {
        [tmp addObject:[NSValue valueWithCGPoint:p]];
    }
    
    return [NSArray arrayWithArray:tmp];
}

-(NSUInteger)countWallMooreNeighborsFromGridCoordinate:(CGPoint)coordiante {
    NSUInteger wallCount = 0;
    
    for (NSInteger i = -1; i < 2; i++) {
        for (NSInteger j = -1; j < 2; j++) {
            if (i == 0 &&j == 0) continue;
            
            CGPoint neighborCoordinate = CGPointMake(coordiante.x + i, coordiante.y + j);
            if (![self isValidCoordinate:neighborCoordinate])
                wallCount += 1;
            else if ([self levelCellFromGridCoordinate:neighborCoordinate].type == LevelCellType_Wall) {
                wallCount += 1;
            }
        }
    }
    
    return wallCount;
}

-(KWLevelCell*)levelCellFromGridCoordinate:(CGPoint)coordiante {
    if ([self isValidCoordinate:coordiante])
        return (KWLevelCell*)[[self.grid objectAtIndex:coordiante.y] objectAtIndex:coordiante.x];
    
    return nil;
}

- (BOOL)isEdgeAtGridCoordinate:(CGPoint)coordinate
{
    return ((NSUInteger)coordinate.x == 0 ||
            (NSUInteger)coordinate.x == (NSUInteger)self.levelSize.width - 1 ||
            (NSUInteger)coordinate.y == 0 ||
            (NSUInteger)coordinate.y == (NSUInteger)self.levelSize.height - 1);
}

-(BOOL)isValidCoordinate:(CGPoint)coordinate {
    return !(coordinate.x < 0 || coordinate.x >= self.levelSize.width || coordinate.y < 0 || coordinate.y >= self.levelSize.height);
}

-(CGPoint)positionForGirdCoordinate:(CGPoint)coordinate {
    return CGPointMake(coordinate.x * kTileSize, coordinate.y * kTileSize);
}

- (CGFloat) randomNumberBetween0and1 {
    return random() / (float)0x7fffffff;
}

@end
