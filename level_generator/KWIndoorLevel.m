//
//  KWIndoorLevel.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/29/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "KWIndoorLevel.h"
#import "KWLevelCell.h"

#define kMinRoomWidth 12
#define kMinRoohHeight 8

#define kMaxRoomWidth 18
#define kMaxRoomHeight 14

@interface KWIndoorLevel ()

@property (nonatomic, assign) int numberOfCooridors;
@property (nonatomic, assign) float chanceForVerticalCooridor;
@property (nonatomic, assign) float chanceToConnectRooms;
@property (nonatomic, strong) NSMutableArray *rooms;

@end

@implementation KWIndoorLevel

-(instancetype)initWithLevelSize:(CGSize)size
{
    if (self = [super init]) {
        self.levelSize = size;
        self.chanceForVerticalCooridor = 0.25;
        self.chanceToConnectRooms = 0.25;
    }
    return self;
}

-(void)generateWithSeed:(unsigned int)seed {
    
    NSLog(@"Generating indoor level...");
    NSDate *startDate = [NSDate date];
    
    srandom(seed);
    
    self.numberOfCooridors = random() % 5 + 3;
    
    NSLog(@"Number of Cooridors = %d", self.numberOfCooridors);
    
    [self blankOut];
    
    [self initializeCooridors];
    
    [self identifyFloorSpace];
    
    [self generateRooms];
    
    [self identifyRooms:YES];
    
    [self generateDoors];
    
    [self identifyRooms:NO];
    
    [self generateTiles];
    
    NSLog(@"Generated indoor level in %f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
}

-(CGPoint)randomPositionInMainPlayArea {
    
    NSUInteger mainCavernIndex = [self mainRoomIndex];
    NSArray *mainCavern = (NSArray *)self.rooms[mainCavernIndex];
    
    NSUInteger mainCavernCount = [mainCavern count];
    KWLevelCell *entranceCell = (KWLevelCell *)mainCavern[arc4random() % mainCavernCount];
    
    return [self positionForGirdCoordinate:entranceCell.coordinate];
}

-(NSInteger)mainRoomIndex {
    NSInteger mainCavernIndex = -1;
    NSUInteger maxCavernSize = 0;
    
    for (NSUInteger i = 0; i < self.rooms.count; i++) {
        
        NSUInteger caveCellCount = ((NSArray*)[self.rooms objectAtIndex:i]).count;
        
        if (caveCellCount > maxCavernSize) {
            maxCavernSize = caveCellCount;
            mainCavernIndex = i;
        }
    }
    return mainCavernIndex;
}

-(void)blankOut {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.levelSize.height];
    
    for (int y = 0; y < self.levelSize.height; y++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.levelSize.width];
        
        for (int x = 0; x < self.levelSize.width; x++) {
            KWLevelCell *cell = [[KWLevelCell alloc] initWithCoordinate:CGPointMake(x, y)];
            cell.type = LevelCellType_Wall;
            [row addObject:cell];
        }
        
        [temp addObject:row];
    }
    
    self.grid = [NSArray arrayWithArray:temp];
}

-(void)initializeCooridors {
    
    NSMutableArray *startPoints = [NSMutableArray new];
    
    for (int i = 0; i < self.numberOfCooridors; i++){
        
        // get a random start point for the cooridor //
        BOOL validStartPoint = NO;
        CGPoint validPoint;
        
        do {
            CGPoint startPoint = CGPointMake(random() % (int)self.levelSize.width, random() % (int)self.levelSize.height);
            
            if (startPoints.count == 0){
                validStartPoint = YES;
            }
            
            for (NSValue *point in startPoints) {
                CGPoint previousPoint = point.CGPointValue;
                
                if (fabs(previousPoint.y - startPoint.y) > 8){
                    validStartPoint = YES;
                } else {
                    validStartPoint = NO;
                    break;
                }
                
                if (fabs(previousPoint.x - startPoint.x) > 8) {
                    validStartPoint = YES;
                } else {
                    validStartPoint = NO;
                    break;
                }
            }
            
            if (validStartPoint){
                [startPoints addObject:[NSValue valueWithCGPoint:startPoint]];
                validPoint = startPoint;
            }
            
        } while (!validStartPoint);
        
        NSLog(@"Cooridor Start = %@", NSStringFromCGPoint(validPoint));
        
        CGPoint loopPoint = validPoint;
        
        BOOL vertical = ([self randomNumberBetween0and1] > self.chanceForVerticalCooridor) ? YES : NO;
        
        BOOL isValidPoint = YES;
        BOOL shouldContinue = YES;
        
        // first well move right or up //
        
        while (isValidPoint && shouldContinue) {
            KWLevelCell *startCell = [self levelCellFromGridCoordinate:loopPoint];
            
            if (startCell) {
                startCell.type = LevelCellType_Cooridor;
            } else {
                isValidPoint = NO;
            }
            
            if (vertical) {
                CGPoint leftPoint = CGPointMake(loopPoint.x - 1, loopPoint.y);
                CGPoint rightPoint = CGPointMake(loopPoint.x + 1, loopPoint.y);
                
                KWLevelCell *leftCell = [self levelCellFromGridCoordinate:leftPoint];
                
                if (leftCell) {
                    leftCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
                
                KWLevelCell *rightCell = [self levelCellFromGridCoordinate:rightPoint];
                
                if (rightCell) {
                    rightCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
                
            } else {
                CGPoint leftPoint = CGPointMake(loopPoint.x, loopPoint.y - 1);
                CGPoint rightPoint = CGPointMake(loopPoint.x, loopPoint.y + 1);
                
                KWLevelCell *leftCell = [self levelCellFromGridCoordinate:leftPoint];
                
                if (leftCell) {
                    leftCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
                
                KWLevelCell *rightCell = [self levelCellFromGridCoordinate:rightPoint];
                
                if (rightCell) {
                    rightCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
            }
            
            if (vertical)
            loopPoint = CGPointMake(loopPoint.x, loopPoint.y + 1);
            else
            loopPoint = CGPointMake(loopPoint.x + 1, loopPoint.y);
        }
        
        // first well move left or down //
        isValidPoint = YES;
        shouldContinue = YES;
        loopPoint = validPoint;
        
        while (isValidPoint && shouldContinue) {
            KWLevelCell *startCell = [self levelCellFromGridCoordinate:loopPoint];
            
            if (startCell) {
                startCell.type = LevelCellType_Cooridor;
            } else {
                isValidPoint = NO;
            }
            
            if (vertical) {
                CGPoint leftPoint = CGPointMake(loopPoint.x - 1, loopPoint.y);
                CGPoint rightPoint = CGPointMake(loopPoint.x + 1, loopPoint.y);
                
                KWLevelCell *leftCell = [self levelCellFromGridCoordinate:leftPoint];
                
                if (leftCell) {
                    leftCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
                
                KWLevelCell *rightCell = [self levelCellFromGridCoordinate:rightPoint];
                
                if (rightCell) {
                    rightCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
                
            } else {
                CGPoint leftPoint = CGPointMake(loopPoint.x, loopPoint.y - 1);
                CGPoint rightPoint = CGPointMake(loopPoint.x, loopPoint.y + 1);
                
                KWLevelCell *leftCell = [self levelCellFromGridCoordinate:leftPoint];
                
                if (leftCell) {
                    leftCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
                
                KWLevelCell *rightCell = [self levelCellFromGridCoordinate:rightPoint];
                
                if (rightCell) {
                    rightCell.type = LevelCellType_Cooridor;
                } else {
                    isValidPoint = NO;
                }
            }
            
            if (vertical)
            loopPoint = CGPointMake(loopPoint.x, loopPoint.y - 1);
            else
            loopPoint = CGPointMake(loopPoint.x - 1, loopPoint.y);
        }
        
    }
}

-(void)generateRooms {
    for (NSArray *room in self.rooms) {
        
        if (room.count < kMinRoohHeight || [[room firstObject] count] < kMinRoomWidth) continue;
        
        BOOL shouldContinue = YES;
        
        int roomsHeight = (int)room.count / 2;
        if (roomsHeight < kMinRoohHeight)
        roomsHeight = (int)room.count;
        
        int roomsWidth = (int)[[room firstObject] count] / 2;
        if  (roomsWidth < kMinRoomWidth)
        roomsWidth = (int)[[room firstObject] count];
        
        CGPoint startpoint = ((KWLevelCell*)[[room objectAtIndex:1] objectAtIndex:1]).coordinate;
        
        while (shouldContinue) {
            
            for (int y = 0; y < room.count - 1; y++) {
                
                for (int x = 0; x < [[room firstObject]count] - 2; x++) {
                    
                    if (x != 0 && x % roomsWidth == 0) {
                        KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(startpoint.x + x, startpoint.y + y)];
                        cell.type = LevelCellType_Wall;
                    } else if ( y != 0 && y % roomsHeight == 0) {
                        KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(startpoint.x + x, startpoint.y + y)];
                        cell.type = LevelCellType_Wall;
                    } else {
                        KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(startpoint.x + x, startpoint.y + y)];
                        cell.type = LevelCellType_Floor;
                    }
                    
                }
            }
            
            if (roomsHeight > kMinRoohHeight)
            roomsHeight /= 2;
            else
            shouldContinue = NO;
            
            if (roomsWidth > kMinRoomWidth)
            roomsWidth /= 2;
            
        }
        
        // remove dividers //
        
        for (int y = 0; y < self.levelSize.height; y++) {
            for (int x = 0; x < self.levelSize.width; x++) {
                // left and right cells //
                KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(x, y)];
                
                if (cell.type == LevelCellType_Wall){
                    NSMutableArray *temp_cells = [NSMutableArray new];
                    BOOL valid_seperator = YES;
                    
                    int xx = x;
                    
                    while (valid_seperator) {
                        KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(xx, y)];
                        
                        // up cell //
                        KWLevelCell *up = [self levelCellFromGridCoordinate:CGPointMake(cell.coordinate.x, cell.coordinate.y + 1)];
                        KWLevelCell *down = [self levelCellFromGridCoordinate:CGPointMake(cell.coordinate.x, cell.coordinate.y - 1)];
                        
                        if (!up || up.type != LevelCellType_Floor){
                            valid_seperator = NO;
                        }
                        
                        if (!down || down.type != LevelCellType_Floor) {
                            valid_seperator = NO;
                        }
                        
                        if (valid_seperator) {
                            [temp_cells addObject:cell];
                        }
                        
                        xx++;
                    }
                    
                    if ([self randomNumberBetween0and1] < self.chanceToConnectRooms && temp_cells.count > 0) {
                        NSLog(@"Removing number of cells = %lu", (unsigned long)temp_cells.count);
                        
                        for (KWLevelCell *cell in temp_cells)
                        cell.type = LevelCellType_Floor;
                    } else {
                        x = xx - 1;
                    }
                }
                
            }
        }
        
        for (int y = 0; y < self.levelSize.height; y++) {
            for (int x = 0; x < self.levelSize.width; x++) {
                // left and right cells //
                KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(x, y)];
                
                if (cell.type == LevelCellType_Wall){
                    NSMutableArray *temp_cells = [NSMutableArray new];
                    BOOL valid_seperator = YES;
                    
                    int yy = y;
                    
                    while (valid_seperator) {
                        KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(x, yy)];
                        
                        // up cell //
                        KWLevelCell *right = [self levelCellFromGridCoordinate:CGPointMake(cell.coordinate.x + 1, cell.coordinate.y)];
                        KWLevelCell *left = [self levelCellFromGridCoordinate:CGPointMake(cell.coordinate.x - 1, cell.coordinate.y)];
                        
                        if (!right || right.type != LevelCellType_Floor){
                            valid_seperator = NO;
                        }
                        
                        if (!left || left.type != LevelCellType_Floor) {
                            valid_seperator = NO;
                        }
                        
                        if (valid_seperator) {
                            [temp_cells addObject:cell];
                        }
                        
                        yy++;
                    }
                    
                    if ([self randomNumberBetween0and1] < self.chanceToConnectRooms && temp_cells.count > 0) {
                        NSLog(@"Removing number of cells = %lu", (unsigned long)temp_cells.count);
                        
                        for (KWLevelCell *cell in temp_cells)
                        cell.type = LevelCellType_Floor;
                    } else {
                        y = yy - 1;
                    }
                }
                
            }
            
        }
    }
}

-(void)generateDoors {
    for (NSArray *room in self.rooms) {
        
        float chanceToGenerateDoor = 0.5;
        BOOL madeDoor = NO;
        
        for (int y = 0; y < 1; y++) {
            for (int x = 0; x < [[room firstObject]count]; x++) {
                if (madeDoor) break;
                
                KWLevelCell *roomCell = [[room objectAtIndex:y] objectAtIndex:x];
                KWLevelCell *cell = [self levelCellFromGridCoordinate:CGPointMake(roomCell.coordinate.x, roomCell.coordinate.y - 2)];
                if (cell && (cell.type == LevelCellType_Cooridor || cell.type == LevelCellType_Floor)) {
                    KWLevelCell *wallCell = [self levelCellFromGridCoordinate:CGPointMake(roomCell.coordinate.x, roomCell.coordinate.y - 1)];
                    if (wallCell && wallCell.type == LevelCellType_Wall && [self randomNumberBetween0and1] > chanceToGenerateDoor) {
                        wallCell.type = LevelCellType_Floor;
                        madeDoor = YES;
                        break;
                        
                    }
                }
                
                roomCell = [[room lastObject] objectAtIndex:x];
                cell = [self levelCellFromGridCoordinate:CGPointMake(roomCell.coordinate.x, roomCell.coordinate.y + 3)];
                if (cell.type == LevelCellType_Cooridor || cell.type == LevelCellType_Floor) {
                    KWLevelCell *wallCell = [self levelCellFromGridCoordinate:CGPointMake(roomCell.coordinate.x, roomCell.coordinate.y + 2)];
                    if (wallCell && wallCell.type == LevelCellType_Wall && [self randomNumberBetween0and1] < chanceToGenerateDoor) {
                        wallCell.type = LevelCellType_Floor;
                        madeDoor = YES;
                        break;
                        
                    }
                }
            }
        }
    }
}

-(void)floodFillRooms:(NSMutableArray*)array fromCoordinate:(CGPoint)coordinate fillNumber:(NSUInteger)fillNumber {
    
    KWLevelCell *cell = (KWLevelCell*)[[array objectAtIndex:coordinate.y] objectAtIndex:coordinate.x];
    
    if (cell.type != LevelCellType_Floor && cell.type != LevelCellType_Cooridor) return;
    
    cell.type = fillNumber;
    
    [[self.rooms lastObject] addObject:cell];
    
    if (coordinate.x > 0) {
        [self floodFillRooms:array fromCoordinate:CGPointMake(coordinate.x - 1, coordinate.y)
                  fillNumber:fillNumber];
    }
    if (coordinate.x < self.levelSize.width - 1) {
        [self floodFillRooms:array fromCoordinate:CGPointMake(coordinate.x + 1, coordinate.y)
                  fillNumber:fillNumber];
    }
    if (coordinate.y > 0) {
        [self floodFillRooms:array fromCoordinate:CGPointMake(coordinate.x, coordinate.y - 1)
                  fillNumber:fillNumber];
    }
    if (coordinate.y < self.levelSize.height - 1) {
        [self floodFillRooms:array fromCoordinate:CGPointMake(coordinate.x, coordinate.y + 1)
                  fillNumber:fillNumber];
    }
    
}


-(void)floodFillFloorSpace:(NSMutableArray*)array fromCoordinate:(CGPoint)coordinate fillNumber:(NSUInteger)fillNumber {
    
    KWLevelCell *cell = (KWLevelCell*)[[array objectAtIndex:coordinate.y] objectAtIndex:coordinate.x];
    
    if (cell.type != LevelCellType_Wall) return;
    
    cell.type = fillNumber;
    
    [[self.rooms lastObject] addObject:cell];
    
    if (coordinate.x > 0) {
        [self floodFillFloorSpace:array fromCoordinate:CGPointMake(coordinate.x - 1, coordinate.y)
                       fillNumber:fillNumber];
    }
    if (coordinate.x < self.levelSize.width - 1) {
        [self floodFillFloorSpace:array fromCoordinate:CGPointMake(coordinate.x + 1, coordinate.y)
                       fillNumber:fillNumber];
    }
    if (coordinate.y > 0) {
        [self floodFillFloorSpace:array fromCoordinate:CGPointMake(coordinate.x, coordinate.y - 1)
                       fillNumber:fillNumber];
    }
    if (coordinate.y < self.levelSize.height - 1) {
        [self floodFillFloorSpace:array fromCoordinate:CGPointMake(coordinate.x, coordinate.y + 1)
                       fillNumber:fillNumber];
    }
    
}

-(void)identifyRooms:(BOOL)ordered{
    self.rooms = [NSMutableArray new];
    
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
                [self.rooms addObject:[NSMutableArray array]];
                [self floodFillRooms:floodFillArray fromCoordinate:CGPointMake(x, y) fillNumber:fillNumber];
                fillNumber++;
            }
        }
    }
    
    if (ordered) {
        // grid up //
        NSMutableArray *temp = [NSMutableArray new];
        
        for (NSArray *room in self.rooms) {
            int y_index = ((KWLevelCell*)[room firstObject]).coordinate.y;
            
            NSMutableArray *rows = [NSMutableArray new];
            NSMutableArray *column = [NSMutableArray new];
            
            for (KWLevelCell *cell in room) {
                if (cell.coordinate.y == y_index) {
                    [column addObject:cell];
                }
                else {
                    [column sortUsingComparator:^NSComparisonResult(KWLevelCell*  _Nonnull obj1, KWLevelCell*   _Nonnull obj2) {
                        return obj2.coordinate.x < obj1.coordinate.x;
                    }];
                    
                    [rows addObject:column];
                    
                    column = [NSMutableArray new];
                    [column addObject:cell];
                    y_index = cell.coordinate.y;
                }
            }
            
            [temp addObject:rows];
        }
        
        self.rooms = temp;
    }
    
    NSLog(@"Number of rooms in floor plan: %lu", (unsigned long)[self.rooms count]);
}


-(void)identifyFloorSpace{
    self.rooms = [NSMutableArray new];
    
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
            if (cell.type == LevelCellType_Wall) {
                [self.rooms addObject:[NSMutableArray array]];
                [self floodFillFloorSpace:floodFillArray fromCoordinate:CGPointMake(x, y) fillNumber:fillNumber];
                fillNumber++;
            }
        }
    }
    
    // grid up //
    NSMutableArray *temp = [NSMutableArray new];
    
    for (NSArray *room in self.rooms) {
        int y_index = ((KWLevelCell*)[room firstObject]).coordinate.y;
        
        NSMutableArray *rows = [NSMutableArray new];
        NSMutableArray *column = [NSMutableArray new];
        
        for (KWLevelCell *cell in room) {
            if (cell.coordinate.y == y_index) {
                [column addObject:cell];
            }
            else {
                [column sortUsingComparator:^NSComparisonResult(KWLevelCell*  _Nonnull obj1, KWLevelCell*   _Nonnull obj2) {
                    return obj2.coordinate.x < obj1.coordinate.x;
                }];
                
                [rows addObject:column];
                
                column = [NSMutableArray new];
                [column addObject:cell];
                y_index = cell.coordinate.y;
            }
        }
        
        [temp addObject:rows];
    }
    
    self.rooms = temp;
    
    NSLog(@"Number of rooms in floor plan: %lu", (unsigned long)[self.rooms count]);
}

@end
