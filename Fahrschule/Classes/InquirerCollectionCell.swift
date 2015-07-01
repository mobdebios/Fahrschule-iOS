//
//  InquirerCollectionCell.swift
//  Fahrschule
//
//  Created on 15.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit


class InquirerCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
//    var solutionIsShown: Bool = false;
    
    let letters = ["A", "B", "C"]
    var answers: [Answer]!
    
    
    
    var questionModel: QuestionModel! {
        didSet { self.configureView() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//         Register cell classes
        let nameSpaceClassName = NSStringFromClass(InquirerTableCell.self)
        let className = nameSpaceClassName.componentsSeparatedByString(".").last! as String
        self.tableView.registerNib(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: "Cell")
        
    }
    
    private func configureView() {
        self.questionLabel.text = self.questionModel.question.text
        let imageName: String = self.questionModel.question.image
        if  count(imageName) > 0 {
            self.imageView.image = UIImage(named: imageName)
        } else {
            self.imageView.image = nil
        }
        let choices = self.questionModel.question.rearrangedChoices as NSSet
        self.answers = choices.allObjects as! [Answer]
        self.tableView.reloadData()
        
//        Select answered questions
        var indexPathes: NSMutableArray = NSMutableArray()
        self.tableView.allowsMultipleSelection = true
        
        for (idx, element) in enumerate(answers) {
            if self.questionModel.givenAnswers.containsObject(element) {
                let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.highlighted = true
            }
        }
        
        if self.questionModel.hasSolutionBeenShown {
            self.showSolutions()
        }
        
        self.tableView.allowsMultipleSelection = !self.questionModel.hasSolutionBeenShown
        if self.questionModel.hasSolutionBeenShown {
            self.tableView.allowsSelection = false
        }
        
    }
    
    func showSolutions() {
        if self.questionModel.question.whatType() == QuestionType.ChoiceQuestion {
            for (idx, answer) in enumerate(self.answers) {
                let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! InquirerTableCell
                cell.corretImageView.image = nil
                if cell.selected == true {
                    let imageName = answer.correct.boolValue ? "richtig" : "falsch"
                    cell.corretImageView.image = UIImage(named: imageName)
                } else {
                    if answer.correct.boolValue {
                        cell.corretImageView.image = UIImage(named: "richtig")
                    } else {
                        cell.corretImageView.image = nil
                    }
                }
                
            }
        }
        
    }
    
//     MARK: - Table View Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionModel.question.whatType() == .ChoiceQuestion ? self.questionModel.question.choices.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! InquirerTableCell
        let answer = self.answers[indexPath.row] as Answer
        cell.questionLabel.text = answer.text
        cell.letterLabel.text = letters[indexPath.row]
        cell.corretImageView.image = nil

        return cell
        
        
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
    }
    
//    MARK: - Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let answer = self.answers[indexPath.row] as Answer
        self.questionModel.givenAnswers.addObject(answer)
        self.questionModel.numGivenAnswers++
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            NSNotificationCenter.defaultCenter().postNotificationName(SettingsNotificationDidChangeAnswersGiven, object: self.questionModel)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let answer = self.answers[indexPath.row] as Answer
        self.questionModel.givenAnswers.removeObject(answer)
        if self.questionModel.numGivenAnswers > 0 {
            self.questionModel.numGivenAnswers--
        }
    }
    
    

}





















