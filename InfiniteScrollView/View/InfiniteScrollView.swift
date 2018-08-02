//
//  InfiniteScrollView.swift
//  InfiniteScrollView
//
//  Created by Tejas Dubal on 21/05/18.
//  Copyright © 2018 Builtio. All rights reserved.
//

import UIKit

protocol InfiniteScrollDelegate {
    func actionClickOn(index: Int)
}

struct CellStyle {
    var selectedTitleColor = UIColor.orange
    var normalTitleColor = UIColor.white
    var titleFont = UIFont.systemFont(ofSize: 14.0)
    var indicatorColor = UIColor.orange
    var isCellWidthDynamic = true
    var isListCircular = true
}

class InfiniteScrollView: UICollectionView {
    fileprivate var initialIndexPath: IndexPath!
    fileprivate var multiplicationFactor = 500
    fileprivate var scrollLimit = 3
    fileprivate let cellIdentifier = "infiniteCollectionCell"
    fileprivate let nibName = "InfiniteCollectionCell"
    fileprivate var cellStyle = CellStyle()
    fileprivate var isAnimationBidirectional = false
    var menuArray = [String]()
    var infiniteScrollDelegate: InfiniteScrollDelegate?
    var lastClickedIndex: IndexPath!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    // MARK: - Initialization
    
    func setupCollection(menuArray: [String], cellStyle: CellStyle) {
        self.menuArray = menuArray
        self.cellStyle = cellStyle
        if !cellStyle.isListCircular {
            scrollLimit = menuArray.count
        }
        if self.menuArray.count > 0 {
            self.registerCollectionView()
            self.delegate = self
            self.dataSource = self
            self.showsHorizontalScrollIndicator = false
            self.setCollectionViewInitialPosition()
            self.bounces = false
        }
    }
    
    fileprivate func setCollectionViewInitialPosition() {
        initialIndexPath = IndexPath(row: 0, section: 0)
        if menuArray.count > scrollLimit {
            var firstVisibleIndex = menuArray.count * (multiplicationFactor / 2)
            firstVisibleIndex += initialIndexPath.row
            lastClickedIndex = IndexPath(row: firstVisibleIndex, section: 0)
        } else {
            lastClickedIndex = initialIndexPath
        }
        self.scrollToItem(at: lastClickedIndex, at: .centeredHorizontally, animated: false)
    }
    
    fileprivate func registerCollectionView() {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
}

// MARK: - CollectionView Delegate & DataSource

extension InfiniteScrollView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if menuArray.count > scrollLimit {
            return multiplicationFactor * menuArray.count
        } else {
            return menuArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! InfiniteCollectionCell
        cell.initInfiniteScrollCellProperties(cellStyle: self.cellStyle)
        if menuArray.count > scrollLimit {
            cell.lblMenuName.text = menuArray[indexPath.row % menuArray.count]
            if (indexPath.row % menuArray.count) == self.initialIndexPath.row {
                cell.setCellPropertiesForSelectedIndex()
            } else {
                cell.setCellPropertiesForUnSelectedIndex()
            }
        } else {
            cell.lblMenuName.text = menuArray[indexPath.row]
            if indexPath.row == self.initialIndexPath.row {
                cell.setCellPropertiesForSelectedIndex()
            } else {
                cell.setCellPropertiesForUnSelectedIndex()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = initialIndexPath.row
        if menuArray.count > scrollLimit {
            if (indexPath.row % menuArray.count) != initialIndexPath.row {
                let actualRow = indexPath.row % menuArray.count
                self.lastClickedIndex = indexPath
                initialIndexPath = IndexPath(row: actualRow, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.reloadData()
                index = actualRow
                infiniteScrollDelegate?.actionClickOn(index: index)
            }
        } else {
            if lastClickedIndex != indexPath {
                self.animateIndicatorView(indexPath: indexPath)
                index = indexPath.row
                lastClickedIndex = indexPath
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                infiniteScrollDelegate?.actionClickOn(index: index)
            }
        }
    }
    
    fileprivate func animateIndicatorView(indexPath: IndexPath) {
        for visibleCell in self.visibleCells as! [InfiniteCollectionCell] {
            if visibleCell.isCellSelected {
                visibleCell.lblMenuName.textColor = self.cellStyle.normalTitleColor
                visibleCell.removeCellSelection()
                break
            }
        }
        
        let currentCell = self.cellForItem(at: indexPath) as? InfiniteCollectionCell
        currentCell?.lblMenuName.textColor = self.cellStyle.selectedTitleColor
        currentCell?.setCellSelected()
        lastClickedIndex = indexPath
    }
    
    func scrollToIndexPath(indexPath: IndexPath) {
        if lastClickedIndex != indexPath {
            var row = lastClickedIndex.row % menuArray.count
            row = lastClickedIndex.row - row + indexPath.row
            self.collectionView(self, didSelectItemAt: IndexPath(row: row, section: 0))
        }
    }
    
    func scrollToDefaultIndex() {
        self.scrollToItem(at: lastClickedIndex, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - CollectionView FlowLayout Delegate

extension InfiniteScrollView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if menuArray.count > scrollLimit || cellStyle.isCellWidthDynamic {
            let value: NSString = self.menuArray[indexPath.row % menuArray.count] as NSString
            var width = Int(value.size(withAttributes: [kCTFontAttributeName as NSAttributedStringKey: self.cellStyle.titleFont]).width)
            width += 30
            return CGSize(width: CGFloat(width), height: self.frame.size.height)
        } else {
            return CGSize(width: self.frame.size.width/CGFloat(menuArray.count), height: self.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        //if menuArray.count > scrollLimit || cellStyle.isCellWidthDynamic {
            return UIEdgeInsets(top: 0.0, left: 20.0, bottom: 00.0, right: 20.0)
        //} else {
          //  return UIEdgeInsets.zero
        //}
    }
}

// MARK: - UIScrollView Delegate

extension InfiniteScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if menuArray.count > scrollLimit {
            if self.contentOffset.x > self.contentSize.width - (UIScreen.main.bounds.width * 2.0) || self.contentOffset.x == 0 {
                var firstVisibleIndex = menuArray.count * (multiplicationFactor / 2)
                firstVisibleIndex += initialIndexPath.row
                lastClickedIndex = IndexPath(row: firstVisibleIndex, section: 0)
                self.scrollToItem(at: lastClickedIndex, at: .centeredHorizontally, animated: false)
            }
        }
    }
}
