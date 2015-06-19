//
//  QuestionViewController.h
//  Fahrschule
//
//  Created by Johan Olsson on 16.11.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FahrschuleViewController.h"
#import "QuestionModel.h"
//#import "AnswerTableViewCell.h"
//#import "OfficialAnswerTableViewCell.h"
#import "Settings.h"
//#import "HelpLabel.h"
//#import "UIColor+ColorWithHexString.h"
#import "Answer.h"

@interface QuestionViewController : FahrschuleViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
}

@property (nonatomic, assign) BOOL isOfficialLayout;
@property (nonatomic, retain) QuestionModel *questionModel;
@property (nonatomic, readonly) Settings *userSettings;
@property (nonatomic, retain) IBOutlet UITableView *answersTableView;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@property (nonatomic, retain) IBOutlet UIButton *tagQuestionButton;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *questionOverlay;
@property (retain, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UIView *numberOverlay;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutletCollection(UITextField) NSArray *numberTextFields;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *numberTextFieldLabels;
@property (nonatomic, retain) IBOutlet UILabel *numberTextFieldPrefixLabel;
@property (nonatomic, retain) IBOutlet UIImageView *numberImageView;
@property (nonatomic, retain) IBOutlet UIImageView *deletedQuestionSeal;

/**
 * Official exam layout properies
 */
@property (nonatomic, retain) IBOutlet UILabel *prefixLabel;
@property (nonatomic, retain) IBOutlet UILabel *questionsLeftLabel;
@property (nonatomic, retain) IBOutlet UIButton *handInExamButton;
@property (nonatomic, retain) IBOutlet UIButton *nextQuestionButton;
@property (nonatomic, retain) IBOutlet UIImageView *questionLeftImageView;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModel:(QuestionModel *)model isOfficialLayout:(BOOL)isOfficialLayout;
- (void)showSolution:(id)sender;
- (void)didClickImage:(id)sender;
- (IBAction)tagQuestion:(id)sender;
- (IBAction)handInExamAndShowResult:(id)sender;
- (IBAction)nextQuestion:(id)sender;
- (IBAction)showQuestionOverview:(id)sender;
- (void)updateQuestionsLeftLabel:(NSInteger)questionsLeft;

@end
