//
//  MachineTableViewCell.swift
//  ImageMachine
//
//  Created by Elang Putra Sartika on 04/08/21.
//

import UIKit

class MachineTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var tickerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tickerView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
 
    func setupView(item: MachineModel) {
        nameLabel.text = item.name
        typeLabel.text = item.type
        dateLabel.text = item.updatedAt?.yyyyMMdd
        
        tickerView.backgroundColor = UIColor.green
    }
}
