//
//  MainSearchControllerCell.swift
//  VerintTask
//
//  Created by astafeev on 2/12/19.
//  Copyright © 2019 astafeev. All rights reserved.
//

import UIKit

class MainSearchControllerCell: UITableViewCell, NibInstantiatable {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet private weak var favouriteIcon: UIImageView!
    
    private var isFavourite: Bool = false {
        didSet {
            favouriteIcon.isHidden = !isFavourite
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setFavourite(_ isFavourite: Bool) {
        self.isFavourite = isFavourite
    }
    
    func configureCell(withTitle title: String? = nil,
                       subtitle: String? = nil,
                       image: UIImage?, isFavourite: Bool = false) {
        titleLabel.text = title ?? ""
        subtitleLabel.text = subtitle ?? ""
        detailImageView.image = image ?? UIImage()
        self.isFavourite = isFavourite
        // UIViews could be tuned here with some basic appearance structure for example
    }
}
