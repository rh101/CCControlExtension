/*
 * CCControlPicker.m
 *
 * Copyright 2013 Yannick Loriot. All rights reserved.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCControlPicker.h"
#import "ARCMacro.h"

#define CCControlPickerDefaultRowHeight 44 //px

@interface CCControlPicker ()
@property (nonatomic, strong) UIPanGestureRecognizer    *panRecognizer;
@property (nonatomic, strong) NSMutableArray            *cells;
@property (nonatomic, assign) NSInteger                selectedRow;

- (void)needsLayoutWithRowNumber:(NSUInteger)rowNumber;

@end

@implementation CCControlPicker
@synthesize panRecognizer   = _panRecognizer;
@synthesize cells           = _cells;
@synthesize selectedRow     = _selectedRow;
@synthesize dataSource      = _dataSource;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_panRecognizer);
    SAFE_ARC_RELEASE(_cells);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithForegroundSprite:(CCSprite *)foregroundSprite selectionSprite:(CCSprite *)selectionSprite
{
    if ((self = [super init]))
    {
        NSAssert(foregroundSprite,   @"Foreground sprite must be not nil");
        NSAssert(selectionSprite,    @"Selection sprite must be not nil");
        
        self.ignoreAnchorPointForPosition   = NO;
        self.contentSize                    = foregroundSprite.contentSize;
        self.anchorPoint                    = ccp(0.5f, 0.5f);
        self.cells                          = [NSMutableArray array];
        self.selectedRow                    = 0;
        
        CGPoint center                      = ccp (self.contentSize.width / 2, self.contentSize.height /2);
        foregroundSprite.position           = center;
        [self addChild:foregroundSprite z:0];
        
        selectionSprite.position            = center;
        [self addChild:selectionSprite z:2];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    self.panRecognizer                      = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    _panRecognizer.delegate                 = self;
    _panRecognizer.minimumNumberOfTouches   = 1;
    _panRecognizer.maximumNumberOfTouches   = 1;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_panRecognizer];
    
    [self reloadComponent];
}

- (void)onExit
{
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_panRecognizer];
    
    [super onExit];
}

- (void)visit
{
    
	if (!self.visible)
		return;
    
	glEnable(GL_SCISSOR_TEST);
    
    CGRect scissorRect  = [self boundingBox];
    
	scissorRect         = CGRectMake(scissorRect.origin.x * CC_CONTENT_SCALE_FACTOR(),
                                     scissorRect.origin.y * CC_CONTENT_SCALE_FACTOR(),
                                     scissorRect.size.width * CC_CONTENT_SCALE_FACTOR(),
                                     scissorRect.size.height * CC_CONTENT_SCALE_FACTOR());
    
	glScissor(scissorRect.origin.x, scissorRect.origin.y,
			  scissorRect.size.width, scissorRect.size.height);
    
	[super visit];
    
	glDisable(GL_SCISSOR_TEST);
}

#pragma mark Properties

#pragma mark - CCControlPicker Public Methods

- (double)rowHeight
{
    return CCControlPickerDefaultRowHeight;
}

- (NSUInteger)numberOfRows
{
    return 0;
}

- (void)reloadComponent
{
    if (_dataSource)
    {
        [self needsLayoutWithRowNumber:[_dataSource numberOfRowsInPickerControl:self]];
    }
    
    [self needsLayoutWithRowNumber:0];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated
{
    
}

- (NSInteger)selectedRow
{
    return _selectedRow;
}

#pragma mark - CCControlPicker Private Methods

- (void)needsLayoutWithRowNumber:(NSUInteger)rowNumber
{
    for (NSUInteger i = 0; i < rowNumber; i++)
    {
        CCLabelTTF *lab = [CCLabelTTF labelWithString:[_dataSource pickerControl:self titleForRow:i]
                                           dimensions:CGSizeMake(self.contentSize.width, 30)
                                           hAlignment:UITextAlignmentCenter
                                             fontName:@"Arial"
                                             fontSize:25];
        lab.color       = ccWHITE;
        lab.position    = ccp (self.contentSize.width / 2, self.contentSize.height / 2);
        [self addChild:lab z:1];
    }
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return NO;
}

#pragma mark - UIGestureRecognizer Delegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    CGPoint gestureLocation = [recognizer locationInView:recognizer.view];
    gestureLocation         = [[CCDirector sharedDirector] convertToGL:gestureLocation];
    gestureLocation         = [[self parent] convertToNodeSpace:gestureLocation];
    
    if ([self isPointInside:gestureLocation])
    {
        return YES;
    }
    
    return NO;
}

- (void)panAction:(UIGestureRecognizer *)recognizer
{
    NSLog(@"here");
}

@end
