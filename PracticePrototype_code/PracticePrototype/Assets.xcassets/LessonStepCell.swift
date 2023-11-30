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
    var shadowView = UIView()
    
    var problemView: ProblemView?
    var mcqAnswersView = MCQAnswersView()
        
    var lessonStep: LessonStep? = nil {
        didSet {
            guard let lessonStep = lessonStep else { return }
            switch lessonStep.type {
            case .content:
                guard let content = lessonStep.content else { return }
                let introImageStr = content.images.first!
                imageView.image = UIImage(named: introImageStr)
            case .solvable: break
            case .playable:
                guard let content = lessonStep.playable else { return }
                let introImageStr = content.images.first!
                imageView.image = UIImage(named: introImageStr)
            case .lwc:
                guard let content = lessonStep.lwc else { return }
                let introImageStr = content.images.first!
                imageView.image = UIImage(named: introImageStr)
            }
            
            setupViews()
        }
    }
    
    var solvableStepDidChange: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        setupViews()
    }
    
    //MARK: Private
    private func setupViews() {
        
//        contentView.addSubview(shadowView)
//        shadowView.backgroundColor = .white
//        shadowView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        guard let step = lessonStep else { return }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        switch step.type {
        case .content:
            setupContentView()
        case .solvable:
            setupSolvablesView()
        case .playable:
            setupPlayableView()
        case .lwc:
            setupLWCView()
        }
    }
    
    private func setupContentView() {
        contentView.addSubview(imageView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupSolvablesView() {
        guard let solvable = lessonStep?.solvable else { return }
        
        if !solvable.isSolved {
            
            problemView = ProblemView(problem: solvable)
            guard let problemView = problemView else { return }
            
            mcqAnswersView = MCQAnswersView(problem: solvable)
            mcqAnswersView.delegate = self
            
            contentView.addSubview(problemView)
            contentView.addSubview(mcqAnswersView)
            problemView.backgroundColor = .clear
            mcqAnswersView.backgroundColor = .clear
            
            if solvable.type == .mcq {
                problemView.snp.makeConstraints { make in
                    make.centerX.width.top.equalToSuperview()
                    make.bottom.equalTo(mcqAnswersView.snp.top)
                }
                
                mcqAnswersView.snp.makeConstraints { make in
                    make.centerX.width.bottom.equalToSuperview()
                }
            } else {
                problemView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.solvableOnTap(recognizer:)))
                problemView.addGestureRecognizer(tapGesture)
            }
            
            if let chosenIndex = lessonStep?.solvable?.chosenIndex, chosenIndex != -1,
               let altImages = lessonStep?.solvable?.diagrammar.altImages {
                problemView.diagrammarImageView.image = UIImage(named: altImages[chosenIndex])
            }
        } else {
            contentView.addSubview(imageView)
            
            imageView.image = UIImage(named: solvable.miniView.correct)
            
            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func setupLWCView() {
        
    }
    
    private func setupPlayableView() {
        contentView.addSubview(imageView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func solvableOnTap(recognizer: UITapGestureRecognizer) {
        // switch image on tap!
        
        guard lessonStep?.type == .solvable,
            let answerImages = lessonStep?.solvable?.diagrammar.altImages,
            let problemView = problemView,
            let randomImageStr = answerImages.randomElement() else { return }
        
        problemView.diagrammarImageView.image = UIImage(named: randomImageStr)
        
        let index = answerImages.firstIndex(of: randomImageStr)
        lessonStep?.solvable?.chosenIndex = index
        
        solvableStepDidChange?()
    }
}

extension LessonStepCell: MCQAnswersViewDelegate {
    func answerSubmittedDelegate(_ answersView: MCQAnswersView) {
        print("sth")
    }
    
    func answerSelectedDelegate(_ answersView: MCQAnswersView) {
        solvableStepDidChange?()
    }
    
    
}
