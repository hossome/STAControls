//
//  ViewController.m
//  STATextField
//
//  Created by Aaron Jubbal on 10/16/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import "ViewController.h"
#import "STAControls.h"

@interface ViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet STAATMTextField *atmTextField;
@property (nonatomic, strong) IBOutlet STATextField *textField;
@property (nonatomic, strong) IBOutlet STATextField *resizingTextField;
@property (nonatomic, strong) IBOutlet STATextField *dateTextField;
//@property (nonatomic, strong) IBOutlet STAPickerField *dateTextField;
@property (nonatomic, strong) IBOutlet STATextField *nextTextField;
@property (nonatomic, strong) IBOutlet STATextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _atmTextField.placeholder = @"Hello world!";
    _atmTextField.keyboardType = UIKeyboardTypeDecimalPad;
//    _atmTextField.atmEntryEnabled = YES;
    _atmTextField.showBackForwardToolbar = YES;
    
    _textField.resignsFirstResponderUponReturnKeyPress = YES;
    _textField.prevControl = _resizingTextField;
    _textField.nextControl = _dateTextField;
    _textField.showBackForwardToolbar = YES;
//    _textField.showNextButton = YES;
    _textField.placeholder = @"placeholder text";
//    _textField.maxCharacterLength = 15;

//    _resizingTextField = [[STAResizingTextField alloc] initWithFrame:CGRectMake(200, 180, 50, 30)];
    _resizingTextField.borderStyle = UITextBorderStyleRoundedRect;
    _resizingTextField.placeholder = @"Hello world!";
    _resizingTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _resizingTextField.resizesForClearTextButton = YES;
//    [self.view addSubview:_resizingTextField];
    
    [_resizingTextField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    
    _dateTextField.prevControl = _textField;
    _dateTextField.nextControl = _nextTextField;
    _dateTextField.showBackForwardToolbar = YES;
//    _dateTextField.showNextButton = YES;
//    _dateTextField.pickerView.titleArray = @[@[@"Geometry", @"Trigonometry", @"Calculus", @"Chemistry"]];
    
//    _dateTextField.pickerView.pickerViewSelectionBlock = ^void(UIPickerView *pickerView, NSInteger component, NSInteger row, NSString *title){
//        NSLog(@"\npickerView: %@ \ncomponent: %lu\nrow: %lu\ntitle: %@", pickerView, component, row, title);
//    };
    
    [self.nextTextField setClearButtonImage:[UIImage imageNamed:@"CameraImage"]
                                   forState:UIControlStateNormal];
    
//    _textView.expandsUpward = YES;
    _textView.layer.borderWidth = 1.0f;
    _textView.layer.cornerRadius = 5;
    _textView.layer.borderColor = [[UIColor grayColor] CGColor];
    _textView.autoDeterminesHeight = YES;
}

- (void) textFieldDidChange: (UITextField*) textField
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
//    [UIView animateWithDuration:0.1 animations:^{
//        [textField invalidateIntrinsicContentSize];
//    }];
}

- (IBAction)hideKeyboard:(id)sender {
    [_atmTextField resignFirstResponder];
    [_textField resignFirstResponder];
    [_resizingTextField resignFirstResponder];
    [_dateTextField resignFirstResponder];
    [_nextTextField resignFirstResponder];
    [_textView resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
