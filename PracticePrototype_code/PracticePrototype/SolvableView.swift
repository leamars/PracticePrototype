//
//  SolvableView.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 26/11/2023.
//

import UIKit

class SolvableView: UIView {
    
    // Data
    var problem: Problem
    
    // UI
    var problemView: ProblemView
    var mcqAnswersView = MCQAnswersView()
    
    init(with problem: Problem) {
        self.problem = problem
        self.problemView = ProblemView(problem: problem)
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(problemView)
        
        // if this is an MCQ, then we need both problemView and MCQ view, otherwise, just problem view
        if problem.type == .mcq {
            problemView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
            }
            
            mcqAnswersView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
            }
        }
        
        else {
            problemView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        // if this is an MCQ, the check button will get enabled once we press an option, otherwise, once we tap on the problem (fake it)
    }
}
