//
//  LessonViewController.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 04/11/2023.
//

import UIKit
import SnapKit

class LessonViewController: UIViewController {
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var safeAreaInsets: UIEdgeInsets {
        guard let window = UIApplication.shared.windows.first else { return UIEdgeInsets.zero }
        return window.safeAreaInsets
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let layout = LessonStepLayout()
    
    var navBarView = UIImageView()
    
    // VERTICAL
    var itemW: CGFloat {
        return screenWidth * 0.9
    }

    var itemH: CGFloat {
        return screenHeight * 0.9
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    

    private func setupViews() {
        view.backgroundColor = .white
        
        navBarView = UIImageView(image: UIImage(named: "navBarImage")!)
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaInsets.top)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // add tap event
        navBarView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.animateOnTap(recognizer:)))
        navBarView.addGestureRecognizer(tapGesture)
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        // 50.0 is equal to the "minimumLineSpacing", so that the first and last item have the same offset as all the rest
        collectionView.decelerationRate = .fast
        
        collectionView.registerCell(LessonStepCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        //collectionView.backgroundColor = .purple300
        collectionView.backgroundColor = .white
    
        setupVerticalNavigation()
    }
    
    @objc func animateOnTap(recognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    func setupVerticalNavigation() {
        // VERTICAL
        
//        collectionView.contentInset = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 50.0, right: 0.0)
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        
        collectionView.collectionViewLayout = layout
        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 50.0
//        layout.minimumInteritemSpacing = 50.0
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0

        layout.itemSize.height = itemH
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navBarView.snp.bottom)
        }
    }
    
    func setupHorizontalNavigation() {
        // HORIZONTAL
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        collectionView.collectionViewLayout = layout
        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 50.0
//        layout.minimumInteritemSpacing = 50.0
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        
        layout.itemSize.width = itemW
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navBarView.snp.bottom)
        }
    }

}

extension LessonViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            setupCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == layout.currentPage {
            print("didSelectItemAt: \(indexPath)")
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            layout.currentPage = indexPath.item
            
            // VERTICAL
            layout.previousOffset = layout.updateOffsetVertical(collectionView)
            
            // HORIZONTAL
//            layout.previousOffset = layout.updateOffsetHorizontal(collectionView)
//            setupCell()
        }
    }
    
    private func setupCell() {
        let indexPath = IndexPath(item: layout.currentPage, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        transformCell(cell)

    }
    
    private func transformCell(_ cell: UICollectionViewCell, isEffect: Bool = true) {
        if !isEffect {
            cell.transform = .identity
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
            cell.layer.opacity = 1.0
        }
        
        for otherCell in collectionView.visibleCells {
            if otherCell != cell {
                UIView.animate(withDuration: 0.2) {
                    otherCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    otherCell.layer.opacity = 0.5
                }
            }
        }
        
    }
    
}

extension LessonViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as LessonStepCell
        //cell.contentView.backgroundColor = .blue300
        
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        cell.layer.opacity = 0.5
        
        cell.contentView.layer.cornerRadius = 10
        
        cell.imageView.image = UIImage(named: "cs-alt-\(indexPath.row)")
        
        
        return cell
    }
    
}

extension LessonViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: itemW, height: itemH)
    }
}
