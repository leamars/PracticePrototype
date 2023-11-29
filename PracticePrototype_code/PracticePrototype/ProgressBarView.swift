//
//  ProgressBarView.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 26/11/2023.
//

import UIKit
import SnapKit

class ProgressBarView: UIView {

    var closeButton = UIImageView()
    var progressViewBackground = UIView()
    var progressView = UIView()
    var streakView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        closeButton.image = UIImage(named: "closeButton")
        closeButton.contentMode = .scaleAspectFit
        addSubview(closeButton)
        
        progressViewBackground.backgroundColor = .gray200
        addSubview(progressViewBackground)
        progressViewBackground.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(10)
            make.width.equalTo(250)
        }
        progressViewBackground.layer.cornerRadius = 5
        
        closeButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(progressViewBackground.snp.left)
        }
        
        streakView.image = UIImage(named: "streakNo")
        streakView.contentMode = .scaleAspectFit
        addSubview(streakView)
        streakView.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(progressViewBackground.snp.right)
        }
        
        progressView.backgroundColor = .green500
        addSubview(progressView)
        
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(progressViewBackground)
            make.height.equalTo(10)
            make.width.equalTo(10)
        }
        
        progressView.layer.cornerRadius = 5
    }
    
    func updateProgressBar(with step: CGFloat, from steps: CGFloat) {
        let width = progressViewBackground.frame.width
        let increment = step/steps * width == 0.0 ? 10.0 : step/steps * width
        progressView.snp.remakeConstraints { make in
            make.left.top.bottom.equalTo(progressViewBackground)
            make.height.equalTo(10)
            make.width.equalTo(increment)
        }
        
        UIView.animate(withDuration: 0.25) {
            // nothing
            self.layoutIfNeeded()
        } completion: { completed in
            // This does not animate
        }
    }
}
