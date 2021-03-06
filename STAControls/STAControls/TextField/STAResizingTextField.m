//
//  STAResizingTextField.m
//  STATextField
//
//  Created by Aaron Jubbal on 10/18/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import "STAResizingTextField.h"
#import "STATextFieldBase+ProvideHeaders.h"
#import "STACommon.h"
#import "STAButton.h"

#define kDynamicResizeThresholdOffset 4

#define kDefaultClearTextButtonOffset 28
#define kDynamicResizeClearTextButtonOffset 0
#define kDynamicResizeClearTextButtonOffsetSelection 31
#define kFixedDecimalClearTextButtonOffset 29
#define kTextFieldSidesBuffer 19

@interface STAResizingTextField () {
    CGFloat _initialTextFieldWidth;
}

@property (nonatomic, assign) BOOL clearButtonIsVisible;

// hack to get around compiler error
@property (nonatomic, weak) id <STAResizingTextFieldDelegate> delegate;

@property (nonatomic, assign) UITextFieldViewMode realRightViewMode;

@property (nonatomic, strong, readwrite) STAButton *customClearButton;

@end

@implementation STAResizingTextField

@dynamic delegate;

- (void)initInternal {
    [super initInternal];
    
    _resizesForClearTextButton = NO;
    _resignsFirstResponderUponReturnKeyPress = YES;
    _initialTextFieldWidth = self.frame.size.width;
    _realRightViewMode = self.rightViewMode;
}

- (void)setNextControl:(UIControl *)nextFirstResponderUponReturnKeyPress {
    self.resignsFirstResponderUponReturnKeyPress = YES;
    _nextControl = nextFirstResponderUponReturnKeyPress;
}

- (void)setRightViewMode:(UITextFieldViewMode)rightViewMode {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    [super setRightViewMode:rightViewMode];
    
    self.realRightViewMode = rightViewMode;
}

- (void)setClearButtonMode:(UITextFieldViewMode)clearButtonMode {
    [super setClearButtonMode:clearButtonMode];
    
    if (clearButtonMode == UITextFieldViewModeAlways) {
        self.clearButtonIsVisible = YES;
    } else if (clearButtonMode == UITextFieldViewModeNever) {
        self.clearButtonIsVisible = NO;
    } else if (clearButtonMode == UITextFieldViewModeWhileEditing) {
        self.clearButtonIsVisible = (self.isEditing && self.text.length > 0);
    } else if (clearButtonMode == UITextFieldViewModeUnlessEditing) {
        self.clearButtonIsVisible = (!self.isEditing && self.text.length > 0);
    }
    self.rightViewMode = clearButtonMode;
}

- (void)setResizesForClearTextButton:(BOOL)resizesForClearTextButton {
    _resizesForClearTextButton = resizesForClearTextButton;
    if ([[UIDevice currentDevice].systemVersion intValue] >= 8) {
        // iOS 8.0 and above
        self.translatesAutoresizingMaskIntoConstraints = resizesForClearTextButton;
    }
}

- (void)setClearButtonImage:(UIImage *)image forState:(UIControlState)state {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (!self.rightView) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
        paddingView.backgroundColor = [UIColor clearColor];
        self.customClearButton = [STAButton buttonWithType:UIButtonTypeCustom];
        self.customClearButton.frame = CGRectMake(6, 6, 18, 18);
        [self.customClearButton addTarget:self
                                   action:@selector(customClearButtonTapped:)
                         forControlEvents:UIControlEventTouchUpInside];
        [paddingView addSubview:self.customClearButton];
        self.rightView = paddingView;
    }
    [self.customClearButton setImage:image forState:state];
    
}

- (void)customClearButtonTapped:(STAButton *)sender {
    BOOL shouldClear = [super clearTextField];
    if (shouldClear) {
        [self updateRightViewMode];
    }
}

- (BOOL)becomeFirstResponder {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    BOOL returnValue = [super becomeFirstResponder];
    
    if (self.clearButtonMode == UITextFieldViewModeWhileEditing) {
        self.clearButtonIsVisible = (self.text.length > 0);
    } else if (self.clearButtonMode == UITextFieldViewModeUnlessEditing) {
        self.clearButtonIsVisible = NO;
    }
    
    [self updateRightViewMode];
//    STALog(@"clear button visible: %d", self.clearButtonIsVisible);
//
//    if (self.resizesForClearTextButton) {
//        [self resizeSelfForClearButton:self.text];
//    }
    return returnValue;
}

- (BOOL)resignFirstResponder {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    BOOL returnValue = [super resignFirstResponder];
    
    if (self.clearButtonMode == UITextFieldViewModeWhileEditing) {
        self.clearButtonIsVisible = NO;
    } else if (self.clearButtonMode == UITextFieldViewModeUnlessEditing) {
        self.clearButtonIsVisible = (self.text.length > 0);;
    }
//
//    STALog(@"clear button visible: %d", self.clearButtonIsVisible);
//
//    if (self.resizesForClearTextButton) {
//        [self resizeSelfToWidthWithoutShrinking:_initialTextFieldWidth];
//    }
    return returnValue;
}

- (void)updateRightViewMode {
    if (self.text.length == 0) {
        super.rightViewMode = UITextFieldViewModeNever;
    } else {
        super.rightViewMode = self.realRightViewMode;
    }
}

- (void)textFieldDidChange:(STATextFieldBase *)sender {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.clearButtonMode == UITextFieldViewModeWhileEditing) {
        self.clearButtonIsVisible = (sender.text.length > 0);
    } else if (self.clearButtonMode == UITextFieldViewModeAlways) {
        self.clearButtonIsVisible = (sender.text.length > 0);
    }
    STALog(@"clear button visible: %d", self.clearButtonIsVisible);
    
    if (self.resizesForClearTextButton) {
        [self resizeSelfForClearButton:self.text];
    }
    
    [self updateRightViewMode];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    STALog(@"%s", __PRETTY_FUNCTION__);
    
//    if (self.resizesForClearTextButton) {
//        NSString *newText = [self.text stringByReplacingCharactersInRange:range
//                                                               withString:string];
//        [self resizeSelfForClearButton:newText];
//    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.resizesForClearTextButton) {
        if (self.text.length < 1) {
            [self resizeSelfToWidthWithoutShrinking:_initialTextFieldWidth];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self resignFirstResponderUponReturnKeyPress] && self.resizesForClearTextButton) {
        [self resizeSelfToWidthWithoutShrinking:_initialTextFieldWidth];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.clearButtonMode == UITextFieldViewModeWhileEditing) {
        self.clearButtonIsVisible = (self.text.length > 0);
    } else if (self.clearButtonMode == UITextFieldViewModeUnlessEditing) {
        self.clearButtonIsVisible = NO;
    }
    STALog(@"clear button visible: %d", self.clearButtonIsVisible);
    
    if (self.resizesForClearTextButton) {
        [self resizeSelfForClearButton:self.text];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.clearButtonMode == UITextFieldViewModeWhileEditing) {
        self.clearButtonIsVisible = (self.text.length > 0);
    } else if (self.clearButtonMode == UITextFieldViewModeUnlessEditing) {
        self.clearButtonIsVisible = NO;
    }
    STALog(@"clear button visible: %d", self.clearButtonIsVisible);
    
    if (self.resizesForClearTextButton) {
        [self resizeSelfForClearButton:self.text];
    }
}

#pragma mark Helpers

- (BOOL)resignFirstResponderUponReturnKeyPress {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    BOOL resignedFirstResponderStatus = NO;
    if (self.resignsFirstResponderUponReturnKeyPress) {
        resignedFirstResponderStatus = [self resignFirstResponder];
        if (self.nextControl) {
            [self.nextControl becomeFirstResponder];
        }
    }
    return resignedFirstResponderStatus;
}

#pragma mark Resizing Helpers

- (void)resizeSelfToWidth:(NSNumber *)width {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat widthFloat = [width floatValue];
    if (widthFloat == self.frame.size.width) {
        return;
    }
    // check with delegate if resizing is appropriate
    if ([self.delegate respondsToSelector:@selector(shouldResizeTextField:fromWidth:toWidth:)]) {
        if (![self.delegate shouldResizeTextField:self fromWidth:self.frame.size.width toWidth:widthFloat]) {
            return;
        }
    }
    
    CGRect selfFrame = self.frame;
    NSInteger changeInLength = widthFloat - self.frame.size.width;
    selfFrame.origin.x -= changeInLength;
    selfFrame.size.width = widthFloat;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15
                              delay:0.01
                            options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                         animations:^{
                             
                             self.frame = selfFrame;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 
                             }
                             self.frame = selfFrame;
                             [self setNeedsLayout];
                         }];
    });
}

- (void)resizeSelfToWidthWithoutShrinking:(CGFloat)width {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (width < _initialTextFieldWidth) {
        width = _initialTextFieldWidth;
    }
    STALog(@"resize to: %f", width);
    [self resizeSelfToWidth:@(width)];
//    [self performSelector:@selector(resizeSelfToWidth:) withObject:@(width) afterDelay:0.1];
}

- (void)resizeSelfToText:(NSString *)text {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat textWidth = [text sizeWithAttributes:@{NSFontAttributeName : self.font}].width;
    if (self.clearButtonMode == UITextFieldViewModeNever) {
        [self resizeSelfToWidthWithoutShrinking:textWidth + kTextFieldSidesBuffer];
    } else if (self.clearButtonMode == UITextFieldViewModeWhileEditing) {
        if (text.length > 0 && self.isEditing) {
            [self resizeSelfToWidthWithoutShrinking:textWidth + kTextFieldSidesBuffer + kDefaultClearTextButtonOffset];
        } else {
            [self resizeSelfToWidthWithoutShrinking:textWidth + kTextFieldSidesBuffer];
        }
    }
}

- (void)resizeSelfForClearButton:(NSString *)text {
    STALog(@"%s", __PRETTY_FUNCTION__);
    
    if (text.length > 0 && self.isEditing && self.clearButtonIsVisible) {
        [self resizeSelfToWidthWithoutShrinking:_initialTextFieldWidth + kDefaultClearTextButtonOffset];
    } else {
        [self resizeSelfToWidthWithoutShrinking:_initialTextFieldWidth];
    }
}

@end
