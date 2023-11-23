//
//  LessonStepLayout.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 05/11/2023.
//

import UIKit

class LessonStepLayout: UICollectionViewFlowLayout {
    var previousOffset: CGFloat = 0.0
    var currentPage = 0
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        return verticalTargetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        
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
        let offset = updateOffsetVertical(cv)

        previousOffset = offset

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
            
        let offset = updateOffsetHorizontal(cv)

        previousOffset = offset
        
        return CGPoint(x: offset, y: proposedContentOffset.y)
    }

    func updateOffsetVertical(_ cv: UICollectionView) -> CGFloat {
        let h = cv.frame.height
        let itemH = itemSize.height
        let sp = minimumLineSpacing
        let edge = (h - itemH - sp*2) / 2
        let offset = (itemH + sp) * CGFloat(currentPage) - (edge + sp)
        
        return offset
    }
    
    func updateOffsetHorizontal(_ cv: UICollectionView) -> CGFloat {
        let w = cv.frame.width
        let itemW = itemSize.width
        let sp = minimumLineSpacing
        let edge = (w - itemW - sp*2) / 2
        let offset = (itemW + sp) * CGFloat(currentPage) - (edge + sp)
        
        return offset
    }
}
