//
//  TableViewCell.swift
//  AlamofireTest
//
//  Created by 深瀬貴将 on 2019/11/18.
//  Copyright © 2019 fukase. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindData(text: String) {
        label.text = text
    }
    
    
}
