//
//  UserCommentTableViewCell.m
//  Thatso
//
//  Created by John A Seubert on 10/21/14.
//  Copyright (c) 2014 John Seubert. All rights reserved.
//

#import "UserCommentTableViewCell.h"
#import "UIButton+CustomButtons.h"

@implementation UserCommentTableViewCell 


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        [self setBackgroundColor:[UIColor blueAppColor]];
    
        self.userCommentTextField = [[UserCommentTextField alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 110, self.frame.size.height - 20)];
        [self.userCommentTextField setBackgroundColor:[UIColor whiteColor]];
        [self.userCommentTextField setFont:[UIFont defaultAppFontWithSize:16.0f]];
        [[self.userCommentTextField  layer] setCornerRadius:self.userCommentTextField.frame.size.height/4];
        [self.userCommentTextField setClipsToBounds:YES];
        [self.userCommentTextField setPlaceholder:@"Enter response"];

        
        [self addSubview:self.userCommentTextField];
        
        self.enterButton = [[UIButton alloc] initWithFrame:CGRectMake(self.userCommentTextField.frame.origin.x + self.userCommentTextField.frame.size.width + 10, 10, 80, self.frame.size.height - 20)];
        [self.enterButton fratButtonWithBorderWidth:1.0f fontSize:16.0f cornerRadius:self.enterButton.frame.size.height/4];
        [self.enterButton setTitle:@"ThatSo" forState:UIControlStateNormal];
        
        [self addSubview:self.enterButton];
        
    }
    return self;
}

-(IBAction)clickedSubmitComment:(id)sender
{
    NSLog(@"clickedSubmitComment");
   // [self uploadComment];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
 //   [self uploadComment];
    return YES;
}

-(void)uploadComment
{
    //ToO. Check comment is a ok.
    if(self.userCommentTextField.text == nil || self.userCommentTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Enter Empty Comment"
                                                        message:@"Think of something hurtful to say."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
  //  [Comms addComment:self.userCommentTextField.text to:self.toUser toGameId:self.gameID inRound:self.roundNumber withCategory:self.category];
    [self.userCommentTextField setText:@""];
}



@end
