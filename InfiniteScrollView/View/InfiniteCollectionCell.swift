//
//  InfiniteCollectionCell.swift
//  InfiniteScrollView
//
//  Created by Tejas Dubal on 21/05/18.
//  Copyright © 2018 Builtio. All rights reserved.
//

import UIKit

class InfiniteCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    fileprivate let animationDuration = 0.0
    var isCellSelected: Bool = false
    fileprivate var cellStyle = CellStyle()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        setCellPropertiesForUnSelectedIndex()
    }

    func initInfiniteScrollCellProperties(cellStyle: CellStyle) {
        self.cellStyle = cellStyle
        self.indicatorView.backgroundColor = cellStyle.indicatorColor
        self.lblMenuName.font = cellStyle.titleFont
    }

    func setCellPropertiesForSelectedIndex() {
        self.isCellSelected = true
        self.lblMenuName.textColor = self.cellStyle.selectedTitleColor
        self.indicatorView.isHidden = false
        self.setIndicatorViewPosition(xPosition: 0)
    }

    func setCellPropertiesForUnSelectedIndex() {
        self.isCellSelected = false
        self.lblMenuName.textColor = self.cellStyle.normalTitleColor
        self.indicatorView.isHidden = true
        self.setIndicatorViewPosition(xPosition: 0 - self.indicatorView.frame.size.width)
    }

    func setCellSelected() {
        self.isCellSelected = true
        self.lblMenuName.textColor = self.cellStyle.selectedTitleColor
        self.indicatorView.isHidden = false
        self.setIndicatorViewPosition(xPosition: -self.indicatorView.frame.size.width)

        UIView.animate(withDuration: animationDuration, animations: {
            self.setIndicatorViewPosition(xPosition: 0)
        }) { (success: Bool) in
        }
    }

    func removeCellSelection() {
        self.isCellSelected = false
        self.lblMenuName.textColor = self.cellStyle.normalTitleColor
        UIView.animate(withDuration: animationDuration, animations: {
            self.setIndicatorViewPosition(xPosition: self.indicatorView.frame.size.width)
        }) { (success: Bool) in
            self.indicatorView.isHidden = true
            self.setIndicatorViewPosition(xPosition: 0 - self.indicatorView.frame.size.width)
        }
    }

    fileprivate func setIndicatorViewPosition(xPosition: CGFloat) {
        let point = CGPoint(x: xPosition, y: self.indicatorView.frame.origin.y)
        self.indicatorView.frame = CGRect(origin: point, size: self.indicatorView.frame.size)
    }
}
