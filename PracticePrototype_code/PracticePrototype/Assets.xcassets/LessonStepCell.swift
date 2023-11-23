//
//  LessonStepCell.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 04/11/2023.
//

import UIKit
import SnapKit

class LessonStepCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private
    private func setupViews() {
        contentView.addSubview(imageView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
