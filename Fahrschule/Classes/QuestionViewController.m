//
//  QuestionViewController.m
//  Fahrschule
//
//  Created by Johan Olsson on 16.11.11.
//  Copyright (c) 2011 freenet. All rights reserved.
//

#import "QuestionViewController.h"

@implementation QuestionViewController

@synthesize isOfficialLayout=_isOfficialLayout;
@synthesize questionModel=_questionModel;
@synthesize answersTableView=_answersTableView;
@synthesize questionLabel=_questionLabel;
@synthesize prefixLabel=_prefixLabel;
@synthesize questionsLeftLabel=_questionsLeftLabel;
@synthesize tagQuestionButton=_tagQuestionButton;
@synthesize imageView=_imageView;
@synthesize questionOverlay=_questionOverlay;
@synthesize containerView=_containerView;
@synthesize numberOverlay=_numberOverlay;
@synthesize numberLabel=_numberLabel;
@synthesize numberTextFields=_numberTextFields;
@synthesize numberTextFieldLabels=_numberTextFieldLabels;
@synthesize numberTextFieldPrefixLabel=_numberTextFieldPrefixLabel;
@synthesize numberImageView=_numberImageView;
@synthesize handInExamButton=_handInExamButton;
@synthesize nextQuestionButton=_nextQuestionButton;
@synthesize questionLeftImageView=_questionLeftImageView;
@synthesize deletedQuestionSeal=_deletedQuestionSeal;


- (Settings *)userSettings
{
    return [Settings sharedSettings];
}

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context withModel:(QuestionModel *)model isOfficialLayout:(BOOL)isOfficialLayout
{
    self.isOfficialLayout = isOfficialLayout;
    NSString *nibName = isOfficialLayout ? @"OfficialQuestionView" : @"QuestionViewController";
    self = [super initWithNibName:nibName inManagedObjectContext:context];
    if (self) {
        self.questionModel = model;
    }
    
    return self;
}

#pragma mark - View lifecycle


/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.questionModel.question.number isEqualToString:@"11.11.1"]) { // The one single special case where a question needs two numbers.
        [[self.numberTextFields objectAtIndex:1] setHidden:NO];
        [[self.numberTextFieldLabels objectAtIndex:1] setHidden:NO];
    }

    if (self.isOfficialLayout) {
        
        // Setzt die Frage beim iPhone 5 mittig 
        if ([[UIScreen mainScreen] bounds].size.height == 568 ) {
            CGRect offsetFrame = CGRectOffset([_containerView frame], 40, 0);
            _containerView.frame = offsetFrame;
        }
        
        self.questionLabel.text = self.questionModel.question.text;
        
        // Make the question text font size smaller if the number of letter excede 240 and is running on an iPhone. Otherwise it won't fit in the UILabel.
        if ([self.questionModel.question.text length] > 240 && !self.iPad) {
            [self.questionLabel setFont:[UIFont systemFontOfSize:12.0]];
        }
        
        if (![self.questionModel.question.prefix isEqualToString:@""]) {
            self.prefixLabel.text = self.questionModel.question.prefix;
        }
        else {
            self.prefixLabel.hidden = YES;
            CGRect rect = self.answersTableView.frame;
            rect.size.height += rect.origin.y - self.prefixLabel.frame.origin.y;
            rect.origin.y = self.prefixLabel.frame.origin.y;
            self.answersTableView.frame = rect;
        }
        
        [self.answersTableView setBackgroundColor:[UIColor clearColor]];
        
        self.tagQuestionButton.selected = self.questionModel.isTagged;
    }
    else {
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_mitGitter"]];
        
        NSString *questionText = [NSString stringWithString:self.questionModel.question.text];
        if (![self.questionModel.question.prefix isEqualToString:@""]) {
            questionText = [NSString stringWithFormat:@"%@\n%@", questionText, self.questionModel.question.prefix];
        }
        self.questionLabel.text = questionText;
        
        // Adapt the question text and/or the box containing the text if the question description is very long
        CGRect drawingBounds = CGRectZero;
        CGFloat labelWidth = self.questionLabel.frame.size.width;
        CGFloat overlayOffset = self.questionOverlay.frame.origin.x;
        drawingBounds = [self.questionLabel textRectForBounds:CGRectMake(overlayOffset + 8.0, 8.0, labelWidth, 480.0) limitedToNumberOfLines:5];
        if (!self.iPad && drawingBounds.size.height > 54.0) {
            [self.questionLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
            drawingBounds = [self.questionLabel textRectForBounds:CGRectMake(overlayOffset + 5.0, 5.0, labelWidth, 480.0) limitedToNumberOfLines:5];
            if (drawingBounds.size.height > 64.0) {
                [self.questionLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
                drawingBounds = [self.questionLabel textRectForBounds:CGRectMake(overlayOffset + 5.0, 1.0, labelWidth + 5.0, 480.0) limitedToNumberOfLines:10];
                if (drawingBounds.size.height == 60.0) {
                    drawingBounds.origin.y = 8.0;
                }
                else if (drawingBounds.size.height >= 90.0) {
                    self.questionOverlay.frame = CGRectMake(overlayOffset, 0.0, 320.0, drawingBounds.size.height + 50);
                }
            }
        }
        self.questionLabel.frame = drawingBounds;
        
        // Set the tag question button
        self.tagQuestionButton.selected = [self.questionModel.question isQuestionTagged];
    }
    
    // Adapt question image to fit betweed question label and choices
    if ([self.questionModel.question.image length] > 0) {
        self.imageView.image = [UIImage imageNamed:self.questionModel.question.image];
        
        // Only show the on click message when the device is not an iPad.
        if (!self.iPad) {
            self.imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImage:)];
            [self.imageView addGestureRecognizer:recognizer];

        }
    }
    else if (!self.isOfficialLayout) {
        if (!self.iPad) {
            self.questionOverlay.image = [UIImage imageNamed:@"bg_frage_ohnePfeil.png"];
        }
        
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_mascot.png"]];
        iv.frame = self.iPad ? CGRectMake(208.0, 124.0, 495.0, 260.0) : CGRectMake(128.0, 158.0, 190.0, 90.0);
        iv.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin);
        [self.view addSubview:iv];
        [self.view bringSubviewToFront:self.deletedQuestionSeal];

    }
    
    // Fürs iPhone 5 etwas nach unten verschieben
    if ([[UIScreen mainScreen] bounds].size.height == 568 && !self.isOfficialLayout) {
        _answersTableView.frame = CGRectMake(_answersTableView.frame.origin.x, 343.0, _answersTableView.frame.size.width, _answersTableView.frame.size.height);
        _numberOverlay.frame = CGRectMake(_numberOverlay.frame.origin.x, 343.0, _numberOverlay.frame.size.width, _numberOverlay.frame.size.height);
        _imageView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _imageView.frame.size.width, 268);
    }
    
    // This question is a number question
    if ([self.questionModel.question whatType] == kNumberQuestion) {
        Answer *answer = (Answer *)[[self.questionModel.question.choices allObjects] objectAtIndex:0];
        UITextField *numberTextField = [self.numberTextFields objectAtIndex:0];
        
        self.numberLabel.text = answer.text;
        numberTextField.delegate = self;
        
        if (self.questionModel.hasSolutionBeenShown) {
            [self showSolution:nil];
        }
        else {
            if ([self.questionModel.givenAnswers count] > 0 && [[self.questionModel.givenAnswers objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
                NSNumber *value = [self.questionModel.givenAnswers objectAtIndex:0];
                numberTextField.text = [value intValue] == -1 ? @"" : [value stringValue];
            }
            
            if ([self.questionModel.givenAnswers count] > 1 && [[self.questionModel.givenAnswers objectAtIndex:1] isKindOfClass:[NSNumber class]]) {
                UITextField *secondNumberTextField = [self.numberTextFields objectAtIndex:1];
                NSNumber *value = [self.questionModel.givenAnswers objectAtIndex:1];
                secondNumberTextField.text = [value intValue] == -1 ? @"" : [value stringValue];
            }
        }
        
        self.numberOverlay.hidden = NO;
        
        CGRect drawingBounds = [self.numberLabel textRectForBounds:self.numberLabel.frame limitedToNumberOfLines:2];
        drawingBounds = CGRectInset(drawingBounds, -4.0, -4.0);
        drawingBounds.origin.y = self.numberLabel.frame.origin.y;
        self.numberLabel.frame = drawingBounds;
        
        if ([answer.text hasPrefix:@"X "]) {
            self.numberLabel.hidden = ![self.questionModel hasSolutionBeenShown];
            self.numberTextFieldPrefixLabel.text = [answer.text stringByReplacingOccurrencesOfString:@"X " withString:@""];
        }
        else {
            self.numberTextFieldPrefixLabel.hidden = YES;
        }
        
        [[self.numberTextFieldLabels objectAtIndex:0] setText:(self.isOfficialLayout ? NSLocalizedString(@"Antwort:", @"") : @"X =")];
    }
    else if ([self.questionModel.question.choices count] < 3 && !self.isOfficialLayout) { // Only two or fewer answer choices. Add clean table view cell background image.
        CGFloat cellHeight = self.iPad ? 46.0 : 39.0;
        CGRect frame = CGRectMake(self.answersTableView.frame.origin.x,
                                  self.answersTableView.frame.origin.y + 2 * cellHeight,
                                  self.answersTableView.frame.size.width,
                                  cellHeight - 1);
        UIImageView *cleanTableViewCell = [[UIImageView alloc] initWithFrame:frame];
        if (self.iPad) {
            cleanTableViewCell.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        }
        cleanTableViewCell.image = [UIImage imageNamed:@"bg_antwort.png"];
        [self.view addSubview:cleanTableViewCell];
        [self.view bringSubviewToFront:cleanTableViewCell];
        [self.view bringSubviewToFront:self.deletedQuestionSeal];
    }
    
    // Show seal if question was deleted
    if ([self.questionModel.question.deleted boolValue]) {
        self.deletedQuestionSeal.hidden = NO;
    }
    
}

- (void)viewDidUnload
{
    [self setContainerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return self.iPad || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.questionModel.question whatType] == kChoiceQuestion ? [self.questionModel.question.choices count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
    
//    static NSString *CellIdentifier = @"Cell";
//    
//    Answer *answer = (Answer *)[[self.questionModel.question.rearrangedChoices allObjects] objectAtIndex:indexPath.row];
//    if (self.isOfficialLayout) {
//        OfficialAnswerTableViewCell *cell = (OfficialAnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[OfficialAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        
//        cell.correct = [answer.correct boolValue];
//        cell.textLabel.text = answer.text;
//        
//        if ([self.questionModel.givenAnswers containsObject:answer]) {
//            [cell toggleAnswerSelected];
//            if (self.questionModel.hasSolutionBeenShown && ![answer.correct boolValue]) {
//                [cell setAnswerIndicator];
//            }
//        }
//        
//        if (self.questionModel.hasSolutionBeenShown && [answer.correct boolValue]) {
//            [cell setAnswerIndicator];
//        }
//        
//        return cell;
//    }
//    else {
//        AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[AnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        
//        cell.correct = [answer.correct boolValue];
//        cell.choiceLabel.text = answer.text;
//        cell.choiceNumber = indexPath.row;
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        
//        if ([self.questionModel.givenAnswers containsObject:answer]) {
//            [cell toggleAnswerSelected];
//            if (self.questionModel.hasSolutionBeenShown && ![answer.correct boolValue]) {
//                [cell setAnswerIndicator];
//            }
//        }
//        
//        if (self.questionModel.hasSolutionBeenShown && [answer.correct boolValue]) {
//            [cell setAnswerIndicator];
//        }
//        
//        return cell;
//    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Answer *answer = (Answer *)[[self.questionModel.question.rearrangedChoices allObjects] objectAtIndex:indexPath.row];
//    if (self.isOfficialLayout) {
//        OfficialAnswerTableViewCell *cell = (OfficialAnswerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        
//        if ([cell toggleAnswerSelected] == YES) {
//            [self.questionModel.givenAnswers addObject:answer];
//            self.questionModel.numGivenAnswers++;
//        }
//        else {
//            [self.questionModel.givenAnswers removeObject:answer];
//            self.questionModel.numGivenAnswers--;
//        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateQuestionsLeftLabel" object:nil];
//    }
//    else {
//        AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        
//        if ([cell toggleAnswerSelected] == YES) {
//            [self.questionModel.givenAnswers addObject:answer];
//            self.questionModel.numGivenAnswers++;
//        }
//        else {
//            [self.questionModel.givenAnswers removeObject:answer];
//            self.questionModel.numGivenAnswers--;
//        }
//        
//        if (self.iPad) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeAnswersGiven" object:nil];
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOfficialLayout) {
        return tableView.frame.size.height / [self tableView:tableView numberOfRowsInSection:indexPath.section];
    }
    else if (self.iPad) {
        return 46.0;
    }
    else {
        return 39.0;
    }
}

#pragma mark - Text Field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{   
    [textField resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] > 0) {
        NSString *testString = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
        NSNumber *value = [testString rangeOfString:@"."].location == NSNotFound ?
            [NSNumber numberWithInt:[testString intValue]] : [NSNumber numberWithFloat:[testString floatValue]];
        [self.questionModel.givenAnswers replaceObjectAtIndex:textField.tag withObject:value];
    }
    else {
        [self.questionModel.givenAnswers replaceObjectAtIndex:textField.tag withObject:[NSNumber numberWithInt:-1]];
    }
    
    if (self.isOfficialLayout) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateQuestionsLeftLabel" object:nil];
    }
    else if (self.iPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeAnswersGiven" object:nil];
    }
    
    self.questionModel.numGivenAnswers = 0;
    for (NSObject *obj in self.questionModel.givenAnswers) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            self.questionModel.numGivenAnswers++;
        }
    }
}

#pragma mark - Actions

- (void)closeModalView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showSolution:(id)sender
{
    if (sender && self.questionModel.isAnAnswerGiven) {
        [LearningStatistic addStatistics:self.questionModel.givenAnswers forQuestion:self.questionModel.question inManagedObjectContext:self.managedObjectContext];
    }
    
    [sender setEnabled:NO];
    [self.questionModel setHasSolutionBeenShown:YES];
    
    if (self.isOfficialLayout) {
        self.questionLeftImageView.hidden = YES;
        self.questionsLeftLabel.hidden = YES;
    }
    
    if ([self.questionModel.question whatType] == kChoiceQuestion) {
        NSArray *cells = [self.answersTableView visibleCells];
        for (int i = 0; i < [cells count]; i++) {
            AnswerTableViewCell *cell = (AnswerTableViewCell *)[cells objectAtIndex:i];
            
            if ([cell isCorrect] || cell.tag == 1) {
                [cell setAnswerIndicator];
            }
        }
        
        self.answersTableView.allowsSelection = NO;
    }
    else {
        Answer *answer = [[self.questionModel.question.choices allObjects] objectAtIndex:0];
        
        if ([self.questionModel.question answerState:self.questionModel.givenAnswers] == kFaultyAnswered) {
            self.numberImageView.image = [UIImage imageNamed:@"icon_falsch.png"];
        }
        else {
            self.numberImageView.image = [UIImage imageNamed:@"icon_richtig.png"];
        }
        
        UITextField *numberTextField = [self.numberTextFields objectAtIndex:0];
        self.numberLabel.hidden = NO;
        numberTextField.enabled = NO;
        
        if ([self.questionModel.givenAnswers count] > 0 && [[self.questionModel.givenAnswers objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
            NSNumber *value = [self.questionModel.givenAnswers objectAtIndex:0];
            numberTextField.text = [value intValue] == -1 ? @"" : [value stringValue];
        }
        
        if (![[self.numberTextFields objectAtIndex:1] isHidden]) {
            NSArray *correctNumbers = [[answer.correctNumber stringValue] componentsSeparatedByString:@"."];
            self.numberLabel.text = [[answer.text stringByReplacingOccurrencesOfString:@"X" withString:[correctNumbers objectAtIndex:0]]
                                     stringByReplacingOccurrencesOfString:@"Y" withString:[correctNumbers objectAtIndex:1]];
            
            if ([[self.questionModel.givenAnswers objectAtIndex:1] isKindOfClass:[NSNumber class]]) {
                UITextField *secondNumberTextField = [self.numberTextFields objectAtIndex:1];
                NSNumber *value = [self.questionModel.givenAnswers objectAtIndex:1];
                secondNumberTextField.text = [value intValue] == -1 ? @"" : [value stringValue];
                secondNumberTextField.enabled = NO;
            }
        }
        else {
            self.numberLabel.text = [answer.text stringByReplacingOccurrencesOfString:@"X" withString:[answer.correctNumber stringValue]];
        }
        
        CGRect drawingBounds = [self.numberLabel textRectForBounds:self.numberLabel.frame limitedToNumberOfLines:2];
        drawingBounds = CGRectInset(drawingBounds, -4.0, -4.0);
        drawingBounds.origin.y = self.numberLabel.frame.origin.y;
        self.numberLabel.frame = drawingBounds;
        
        self.numberLabel.layer.borderColor = [UIColor colorWithRGBHex:0x3fa108].CGColor;
        self.numberLabel.layer.borderWidth = 1.0;
        self.numberLabel.layer.cornerRadius = 4.0;
    }
}

- (void)didClickImage:(id)sender
{
    if (self.isOfficialLayout) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFullscreenImage" object:nil];
        return;
    }
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[HelpLabel class]]) {
            return;
        }
    }
    
    CGRect newFrame = self.imageView.frame;
    if (self.imageView.frame.size.width < 110.0) {
        newFrame.size.width = 220.0;
        newFrame.origin.x = 50.0;
    }
    else {
        newFrame.size.width -= 20.0;
        newFrame.origin.x += 10.0;
    }
    
    HelpLabel *label = [[HelpLabel alloc] initWithFrame:newFrame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 4;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:NSLocalizedString(@"Zur Vergrößerung bitte das Gerät drehen.", @"")];
    newFrame = [label textRectForBounds:newFrame limitedToNumberOfLines:4];
    newFrame.origin.y = self.imageView.center.y - newFrame.size.height / 2.0;
    label.frame = newFrame;
    [UIView animateWithDuration:0.25 delay:2.0 options:UIViewAnimationCurveEaseOut animations:^(void) {
        label.alpha = 0.0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
    [self.view addSubview:label];
}

- (IBAction)tagQuestion:(id)sender
{
    [self.tagQuestionButton setSelected:![self.tagQuestionButton isSelected]];
    if (self.isOfficialLayout) {
        self.questionModel.isTagged = [self.tagQuestionButton isSelected];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tagQuestionInOfficialLayout" object:nil];
    }
    else {
        [self.questionModel.question setTagged:[self.tagQuestionButton isSelected] inManagedObjectContext:self.managedObjectContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tagQuestion" object:nil];
    }
}

- (IBAction)handInExamAndShowResult:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handInExamAndShowResult" object:nil];
}

- (IBAction)nextQuestion:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextQuestion" object:nil];
}

- (IBAction)showQuestionOverview:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showQuestionOverview" object:nil];
}

- (void)updateQuestionsLeftLabel:(NSInteger)questionsLeft
{
    self.questionLeftImageView.hidden = questionsLeft == 0;
    self.questionsLeftLabel.hidden = questionsLeft == 0;
    self.questionsLeftLabel.text = [NSString stringWithFormat:NSLocalizedString(@"noch %d Aufgaben", @""), questionsLeft];
}

*/

@end
