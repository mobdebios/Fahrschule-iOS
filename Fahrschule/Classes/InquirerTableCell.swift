//
//  InquirerTableCell.swift
//  Fahrschule
//
//  Created on 16.06.15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class InquirerTableCell: UITableViewCell {

    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var corretImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    - (NSString *)letterIndicatorForInteger:(NSInteger)number {
//    char c[32];
//    sprintf(c, "%c", (65 + number));
//    
//    return [NSString stringWithCString:c encoding:NSISOLatin1StringEncoding];
//    }
    
//    func letterIndicatorForInteger(number : Int)->String {
////        char c[32]
////        sprintf(c, "%c", (65 + number));
//        
//        sprintf(
        
//    }
    
}
