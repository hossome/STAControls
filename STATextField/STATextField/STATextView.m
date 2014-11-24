//
//  STATextView.m
//  STATextField
//
//  Created by Aaron Jubbal on 11/21/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import "STATextView.h"
#import "STATextViewBase+PrivateHeaders.h"

@interface STATextView () {
    NSString *_internalPlaceholder;
    NSAttributedString *_internalAttributedPlaceholder;
    CGFloat _initialYPosition;
    NSTimeInterval _keyboardAnimationDuration;
    UIViewAnimationCurve _keyboardanimationCurve;
    CGFloat _topOfKeyboardYPosition;
}

@property (nonatomic, assign) BOOL nextShowKeyboardNotificationForSelf;
@property (nonatomic, assign) BOOL nextHideKeyboardNotificationForSelf;

@end


@implementation STATextView

- (void)animateSelfToPosition:(CGFloat)position {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:_keyboardAnimationDuration];
        [UIView setAnimationCurve:_keyboardanimationCurve];
        
        CGRect newTextViewFrame = self.frame;
        newTextViewFrame.origin.y = position;
        self.frame = newTextViewFrame;
        
        [UIView commitAnimations];
    });
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&_keyboardanimationCurve];
        [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&_keyboardAnimationDuration];
        
        if (!_topOfKeyboardYPosition) {
            CGRect keyboardEndFrame;
            [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
            _topOfKeyboardYPosition = keyboardEndFrame.origin.y - self.frame.size.height;
        }
        
        if (!self.nextShowKeyboardNotificationForSelf) {
            return;
        }
        self.nextShowKeyboardNotificationForSelf = NO;
        
        CGRect keyboardEndFrame;
        [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
        _topOfKeyboardYPosition = keyboardEndFrame.origin.y - self.frame.size.height;
        
        if (self.animatesToTopOfKeyboard) {
            [self animateSelfToPosition:_topOfKeyboardYPosition];
        }
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&_keyboardanimationCurve];
        [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&_keyboardAnimationDuration];
        
        if (!self.nextHideKeyboardNotificationForSelf) {
            return;
        }
        self.nextHideKeyboardNotificationForSelf = NO;
        
        if (self.animatesToTopOfKeyboard) {
            [self animateSelfToPosition:_initialYPosition];
        }
    });
}

- (BOOL)becomeFirstResponder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [super becomeFirstResponder];
    
    if (self.animatesToTopOfKeyboard) {
        [self animateSelfToPosition:_topOfKeyboardYPosition];
    }
    
    return YES;
}

- (BOOL)resignFirstResponder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [super resignFirstResponder];
    
    if (self.animatesToTopOfKeyboard) {
        [self animateSelfToPosition:_initialYPosition];
    }
    
    return YES;
}

- (void)initInternal {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [super initInternal];
    
    _initialYPosition = self.frame.origin.y;
    self.animatesToTopOfKeyboard = NO;
    self.nextHideKeyboardNotificationForSelf = NO;
    self.nextShowKeyboardNotificationForSelf = NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.nextShowKeyboardNotificationForSelf = YES;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.nextHideKeyboardNotificationForSelf = YES;
    
    return YES;
}

@end
