//
//  ProblemView.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 03/08/2023.
//

import UIKit
import SnapKit

private struct QuestionLayout {
    static let topMargin: CGFloat = 68.0
    static let height: CGFloat = 60.0
}

private struct DiagrammarLayout {
    static let topMargin: CGFloat = 60.0
    static let height: CGFloat = 60.0
}

class ProblemView: UIView {
    
    // Data
    var problem: Problem
    
    // UI
    var questionLabel = UILabel()
    var diagrammarImageView = UIImageView()
    
    init(problem: Problem) {
        self.problem = problem
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        // Question
        questionLabel.text = problem.question
        questionLabel.font = .bold(19)
        questionLabel.numberOfLines = 0
        addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.width.centerX.top.equalToSuperview()
            make.height.equalTo(QuestionLayout.height)
        }
        
        // Diagrammar
        diagrammarImageView.image = UIImage(named: problem.diagrammar.image)
        diagrammarImageView.contentMode = .scaleAspectFit
        addSubview(diagrammarImageView)
        diagrammarImageView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp_bottomMargin).offset(DiagrammarLayout.topMargin)
            make.width.centerX.bottom.equalToSuperview()
        }
    }

}
