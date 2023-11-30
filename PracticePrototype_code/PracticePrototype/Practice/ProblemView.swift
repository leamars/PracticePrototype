//
//  ProblemView.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 03/08/2023.
//

import UIKit
import SnapKit

struct QuestionLayout {
    static let topMargin: CGFloat = 68.0
    static let height: CGFloat = 60.0
}

private struct CaptionLayout {
    static let height: CGFloat = 60.0
}

private struct DiagrammarLayout {
    static let topBigMargin: CGFloat = 60.0
    static let topLittleMargin: CGFloat = 20.0
    static let height: CGFloat = 60.0
}

class ProblemView: UIView {
    
    // Data
    var problem: Problem
    
    // UI
    var questionLabel = UILabel()
    var captionLabel = UILabel()
    var diagrammarImageView = UIImageView()
    
    init(problem: Problem) {
        self.problem = problem
        super.init(frame: .zero)
        
        setupViewsPromptFirst()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewsCaptionFirst() {
        
        // Question
        questionLabel.text = problem.question
        questionLabel.font = .bold(19)
        questionLabel.numberOfLines = 0
        addSubview(questionLabel)
        
        captionLabel.text = problem.diagrammar.caption
        captionLabel.font = .regular(16)
        captionLabel.numberOfLines = 3
        addSubview(captionLabel)
        
        // Diagrammar
        diagrammarImageView.image = UIImage(named: problem.diagrammar.image)
        diagrammarImageView.contentMode = .scaleAspectFit
        addSubview(diagrammarImageView)
        
        // If there's a caption, include it
        if !problem.diagrammar.caption.isEmpty {
            
            captionLabel.snp.makeConstraints { make in
                make.width.top.centerX.equalToSuperview()
                make.height.equalTo(60)
            }
            
            diagrammarImageView.snp.makeConstraints { make in
                make.top.equalTo(captionLabel.snp_bottomMargin).offset(30)
                make.width.centerX.equalToSuperview()
            }
            
            questionLabel.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.height.equalTo(QuestionLayout.height)
                make.top.equalTo(diagrammarImageView.snp.bottom).offset(30)
            }
            
        } else {

            questionLabel.snp.makeConstraints { make in
                make.width.centerX.top.equalToSuperview()
                make.height.equalTo(QuestionLayout.height)
            }
            
            diagrammarImageView.snp.makeConstraints { make in
                make.top.equalTo(questionLabel.snp_bottomMargin).offset(DiagrammarLayout.topBigMargin)
                make.width.centerX.bottom.equalToSuperview()
            }
        }
    }
    
    func setupViewsPromptFirst() {
        
        // Question
        questionLabel.text = problem.question
        questionLabel.font = .bold(19)
        questionLabel.numberOfLines = 0
        addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.width.centerX.top.equalToSuperview()
            make.height.equalTo(QuestionLayout.height)
        }
        
        captionLabel.text = problem.diagrammar.caption
        captionLabel.font = .regular(16)
        captionLabel.numberOfLines = 3
        addSubview(captionLabel)
        
        // Diagrammar
        diagrammarImageView.image = UIImage(named: problem.diagrammar.image)
        diagrammarImageView.contentMode = .scaleAspectFit
        addSubview(diagrammarImageView)
        
        // If there's a caption, include it
        if !problem.diagrammar.caption.isEmpty {
            
            captionLabel.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.top.equalTo(questionLabel.snp.bottom)
                make.height.equalTo(60)
            }
            
            diagrammarImageView.snp.makeConstraints { make in
                make.top.equalTo(captionLabel.snp_bottomMargin).offset(DiagrammarLayout.topLittleMargin)
                make.width.centerX.bottom.equalToSuperview()
            }
        } else {
            diagrammarImageView.snp.makeConstraints { make in
                make.top.equalTo(questionLabel.snp_bottomMargin).offset(DiagrammarLayout.topBigMargin)
                make.width.centerX.bottom.equalToSuperview()
            }
        }
        
    }

}
