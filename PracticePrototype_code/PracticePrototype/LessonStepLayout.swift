//
//  LessonStepLayout.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 26/11/2023.
//

import UIKit

enum LayoutType {
    case vertical
    case horizontal
    case verticalHug
}

protocol LessonStepLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightAtIndexPath indexPath: IndexPath) -> CGFloat
}

class LessonStepLayout: UICollectionViewFlowLayout {
    weak var delegate: LessonStepLayoutDelegate?
    var previousOffset: CGFloat = 0.0
    var isScrollingForward: Bool = true
    
    var pageDidChangeClosure: (() -> Void)?
    var pageDidChangeClosureValues: ((_ oldValue: Int, _ newValue: Int) -> Void)?
    var currentPage = 0 {
        didSet {
            print("Changed current page to \(currentPage)!")
            pageDidChangeClosure?()
            
            isScrollingForward = oldValue < currentPage
            print("Moving \(isScrollingForward ? "forward" : "back")")
        }
    }
    
    var layoutType: LayoutType = .horizontal
        
    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    var itemHeights: [CGFloat] = []
    var itemVerticalOffsets: [CGFloat] = []
    
    override func prepare() {
        
        guard layoutType == .verticalHug,
              itemVerticalOffsets.isEmpty == true,
              let cv = collectionView else { return }
        
        var yOffset: CGFloat = 0
        
        for item in 0..<cv.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let itemH = delegate?.collectionView(cv, heightAtIndexPath: indexPath) ?? 0
            let cvHeight = cv.frame.height
            
            // if there's a previous item, include that half height in!
            var previousItemOffset: CGFloat = 0
            var newOffset: CGFloat = 0
            if item > 0 {
                let previousIndexPath = IndexPath(item: item - 1, section: 0)
                let previousItemHeight = delegate?.collectionView(cv, heightAtIndexPath: previousIndexPath) ?? 0
                previousItemOffset = previousItemHeight / 2
                newOffset = yOffset + (itemH / 2) + minimumLineSpacing + previousItemOffset
            } else {
                newOffset = (cvHeight / 2) - (itemH / 2) + minimumLineSpacing
            }
            
            yOffset = newOffset
            itemVerticalOffsets.append(yOffset)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        switch layoutType {
        case .vertical:
            return verticalTargetContentOffset(forProposedContentOffset: proposedContentOffset,
                                               withScrollingVelocity: velocity)
        case .horizontal:
            return horizontalTargetContentOffset(forProposedContentOffset: proposedContentOffset,
                                               withScrollingVelocity: velocity)
        case .verticalHug:
            return verticalTargetContentOffset(forProposedContentOffset: proposedContentOffset,
                                               withScrollingVelocity: velocity)
        }
        
    }
    
    func verticalTargetContentOffset (forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let itemCount = cv.numberOfItems(inSection: 0)

        if previousOffset > cv.contentOffset.y && velocity.y < 0.0 {
            // <-
            currentPage = max(currentPage-1, 0)
        } else if previousOffset < cv.contentOffset.y && velocity.y > 0.0 {
            // ->
            currentPage = min(currentPage+1, itemCount-1)
        }
        
        let offset = updateOffset(cv)

        previousOffset = offset
        
        print("Current page: \(currentPage)")

        return CGPoint(x: proposedContentOffset.x, y: offset)
    }
    
    func horizontalTargetContentOffset (forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let itemCount = cv.numberOfItems(inSection: 0)

        if previousOffset > cv.contentOffset.x && velocity.x < 0.0 {
            // <-
            currentPage = max(currentPage-1, 0)
        } else if previousOffset < cv.contentOffset.x && velocity.x > 0.0 {
            // ->
            currentPage = min(currentPage+1, itemCount-1)
        }
            
        let offset = updateOffset(cv)

        previousOffset = offset
        
        return CGPoint(x: offset, y: proposedContentOffset.y)
    }
    
    func updateOffset(_ cv: UICollectionView) -> CGFloat {
        switch layoutType {
        case .vertical:
            let h = cv.frame.height
            let itemH = 595.0
            let sp = minimumLineSpacing
            let edge = (h - itemH - sp*2) / 2
            let offset = (itemH + sp) * CGFloat(currentPage) - (edge + sp)
            
            return offset
        case .horizontal:
            let w = cv.frame.width
            let itemW = 352.0
            let sp = minimumLineSpacing
            let edge = (w - itemW - sp*2) / 2
            let offset = (itemW + sp) * CGFloat(currentPage) - (edge + sp)
            
            return offset
        case .verticalHug:
            return itemVerticalOffsets[currentPage]
        }
    }
}
