//
//  UICollectionView+Helpers.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 04/11/2023.
//

import Foundation
import UIKit

extension UICollectionView {
    public func registerCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(forIndexPath indexPath: IndexPath,
                                    file: StaticString = #file,
                                    line: UInt = #line) -> Cell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as? Cell else {
            fatalError("File: \(file), line: \(line)\nUnable to dequeue cell of class \(String(describing: Cell.self)) for indexPath \(indexPath)")
        }
        return cell
    }
}
