//
//  MCQView.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 03/08/2023.
//

import UIKit


protocol MCQAnswersViewDelegate: AnyObject {
    func answerSubmittedDelegate(_ answersView: MCQAnswersView)
    func answerSelectedDelegate(_ answersView: MCQAnswersView)
}

enum MCQLayoutStyle {
    case column
    case grid
    case row
    
    var height: CGFloat {
        switch self {
        case .column:
            return 50
        case .grid, .row:
            return 72
        }
    }
    
    var spacing: CGFloat {
        return 12.0
    }
}

class MCQAnswersView: UIView {
    
    // Comms
    var delegate: MCQAnswersViewDelegate?
    
    // Data
    var problem: Problem? {
        didSet {
            setupViews()
        }
    }
    
    var style: MCQLayoutStyle {
        guard let problem = problem,
        let longestAnswer = problem.answers.max(by: {$1.title.count > $0.title.count} )
            else { return .column }
        
        let numCharactersInLongestAnswer = longestAnswer.title.count
        let numAnswers = problem.answers.count
        
        switch (numAnswers, numCharactersInLongestAnswer) {
        case (2...4, 7...16):
            return .column
        case (4, 3...6):
            return .grid
        case (2, 1...6), (3, 1...3), (4, 1...2):
            return .row
        default:
            return .column
        }
    }
    
    // UI
    var answerButtons: [MCQButton] =  []
    var selectedAnswer: MCQButton? = nil
    
    // Stack views
    var gridVerticalStackView = UIStackView()
    var firstRowHorizontalStackView = UIStackView()
    var secondRowHorizontalStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
    }
    
    init(problem: Problem) {
        self.problem = problem
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        switch style {
        case .column:
            setupColumnLayout()
        case .grid:
            setupGridLayout()
        case .row:
            setupRowLayout()
        }
    }
    
    private func setupGridLayout() {
        gridVerticalStackView.axis = .vertical
        gridVerticalStackView.spacing = style.spacing
        gridVerticalStackView.distribution = .fillEqually
        
        addSubview(gridVerticalStackView)
        
        gridVerticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        firstRowHorizontalStackView.axis = .horizontal
        firstRowHorizontalStackView.spacing = style.spacing
        firstRowHorizontalStackView.distribution = .fillEqually
        
        secondRowHorizontalStackView.axis = .horizontal
        secondRowHorizontalStackView.spacing = style.spacing
        secondRowHorizontalStackView.distribution = .fillEqually
        
        gridVerticalStackView.addArrangedSubview(firstRowHorizontalStackView)
        gridVerticalStackView.addArrangedSubview(secondRowHorizontalStackView)
        
        for i in 0...3 {
            
            guard let answer = problem?.answers[i] else { return }
            
            let mcqButton = MCQButton(title: answer.title, isCorrectAnswer: answer.correct)
            mcqButton.delegate = self
            
            if i < 2 {
                firstRowHorizontalStackView.addArrangedSubview(mcqButton)
            } else {
                secondRowHorizontalStackView.addArrangedSubview(mcqButton)
            }
            mcqButton.snp.makeConstraints { make in
                make.height.equalTo(style.height)
            }
            
            answerButtons.append(mcqButton)
        }
        
    }
    
    private func setupRowLayout() {
        setupSimpleLayout(with: .horizontal)
    }
    
    private func setupColumnLayout() {
        setupSimpleLayout(with: .vertical)
    }
    
    private func setupSimpleLayout(with axis: NSLayoutConstraint.Axis) {
        let answersStackView = UIStackView()
        addSubview(answersStackView)
        
        answersStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        answersStackView.axis = axis
        answersStackView.spacing = style.spacing
        answersStackView.distribution = .fillEqually
        
        guard let problem = problem else { return }
        
        for answer in problem.answers {
            let mcqButton = MCQButton(title: answer.title, isCorrectAnswer: answer.correct)
            mcqButton.delegate = self
            
            answersStackView.addArrangedSubview(mcqButton)
            mcqButton.snp.makeConstraints { make in
                make.height.equalTo(style.height)
            }
            
            answerButtons.append(mcqButton)
        }
    }
    
    func updateAnswersForSubmitted() {
        for answer in answerButtons {
            answerSubmittedDelegate(answer)
        }
    }
}

extension MCQAnswersView: MCQButtonDelegate {
    func answerSelectedDelegate(_ sender: MCQButton) {
        
        selectedAnswer = sender
        
        // Update buttons to selected color
        for answer in answerButtons {
            answer.isPressed = answer == sender
        }
        
        delegate?.answerSelectedDelegate(self)
    }
    
    func answerSubmittedDelegate(_ sender: MCQButton) {
//        sender.updateViewForSubmitted()
        
    // HACK REJIG STACKVIEWS
        sender.updateViewForSubmittedAlternate()
        updateStackViews(with: sender)
    }
    
    func updateStackViews(with sender: MCQButton) {
        switch style {
        case .column, .row:
            // if we're in a column, we're good, yay!
            return
        case .grid:
            // if we're in a grid we're a bit fucked, we first remove all the subviews
            firstRowHorizontalStackView.arrangedSubviews.forEach { subview in
                subview.removeFromSuperview()
            }
            // if user pressed on correct we add the correct one back in
            if sender.isCorrectAnswer {
                firstRowHorizontalStackView.addArrangedSubview(sender)
            }
            
            // if user pressed on incorrect, we add in correct AND incorrect
            else {
                for answerButton in answerButtons {
                    if answerButton.isPressed && !answerButton.isCorrectAnswer {
                        firstRowHorizontalStackView.addArrangedSubview(answerButton)
                    }
                    
                    if answerButton.isCorrectAnswer {
                        firstRowHorizontalStackView.addArrangedSubview(answerButton)
                    }
                }
            }
            
            // and we get rid of the second stack view
            secondRowHorizontalStackView.removeFromSuperview()
            return
        }
    }
}

protocol MCQButtonDelegate: AnyObject {
    func answerSelectedDelegate(_ sender: MCQButton)
    func answerSubmittedDelegate(_ sender: MCQButton)
}

class MCQButton: UIButton {
    
    // Comms
    var delegate: MCQButtonDelegate?
    
    // Data
    var title: String
    var isCorrectAnswer: Bool
    
    var isPressed: Bool = false {
        didSet {
            updateButtonFor(isPressed: isPressed)
        }
    }

    
    init(title: String, isCorrectAnswer: Bool) {
        self.title = title
        self.isCorrectAnswer = isCorrectAnswer
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateButtonFor(isPressed: Bool) {
        if isPressed {
            animateButtonChange(bgColor: UIColor.blue100,
                                fromBorderColor: layer.borderColor ?? UIColor.clear.cgColor,
                                toBorderColor: UIColor.blue400.cgColor,
                                cgAnimationDuration: 0.15,
                                titleColor: .blue500,
                                font: .bold(17))
        } else {
            animateButtonChange(bgColor: .white,
                                fromBorderColor: layer.borderColor ?? UIColor.clear.cgColor,
                                toBorderColor: UIColor.gray200.cgColor,
                                cgAnimationDuration: 0.15,
                                titleColor: .black1000,
                                font: .regular(17))
        }
    }
    
    func animateButtonChange(bgColor: UIColor, fromBorderColor: CGColor, toBorderColor: CGColor, cgAnimationDuration: CFTimeInterval, titleColor: UIColor, font: UIFont) {
        
        UIView.animate(withDuration: 0.05) {
            self.backgroundColor = bgColor
            self.layer.borderColor = toBorderColor
            self.setTitleColor(titleColor, for: .normal)
            self.titleLabel?.font = font
        }
    }
    
    func animateBorderColor(from: CGColor, to: CGColor, duration: CFTimeInterval) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        CATransaction.setCompletionBlock {
            self.layer.borderColor = to
        }
        layer.add(animation, forKey: "borderColor")
        CATransaction.commit()
    }
    
    func setupViews() {
        backgroundColor = .white1000
        layer.cornerRadius = 12
        layer.borderColor = UIColor.gray200.cgColor
        layer.borderWidth = 2
        setTitleColor(.black1000, for: .normal)
        setTitle(title, for: .normal)
        titleLabel?.font = .regular(17)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    func updateViewForSubmittedAlternate() {
        var bgColor: UIColor = backgroundColor ?? .clear
        var cgBorderColor: CGColor = layer.borderColor ?? UIColor.clear.cgColor
        var titleColor: UIColor = currentTitleColor
        var font: UIFont = titleLabel?.font ?? .regular(17)
        
        switch (isCorrectAnswer, isPressed) {
        case (true, true):
            bgColor = .green100
            cgBorderColor = UIColor.green400.cgColor
            titleColor = .green400
            font = .bold(17)
        case (true, false):
            bgColor = .green100
            cgBorderColor = UIColor.green400.cgColor
            titleColor = .green400
            font = .bold(17)
        case (false, false):
            removeFromSuperview()
        case (false, true):
            bgColor = .red100
            cgBorderColor = UIColor.red400.cgColor
            titleColor = .red400
            font = .bold(17)
        }
                
        animateButtonChange(bgColor: bgColor,
                            fromBorderColor: layer.borderColor ?? UIColor.clear.cgColor,
                            toBorderColor: cgBorderColor,
                            cgAnimationDuration: 0.15,
                            titleColor: titleColor,
                            font: font)
        
        isUserInteractionEnabled = false
    }
    
    func updateViewForSubmitted() {
        var bgColor: UIColor = backgroundColor ?? .clear
        var cgBorderColor: CGColor = layer.borderColor ?? UIColor.clear.cgColor
        var titleColor: UIColor = currentTitleColor
        var font: UIFont = titleLabel?.font ?? .regular(17)
        
        switch (isCorrectAnswer, isPressed) {
        case (true, true):
            bgColor = .green100
            cgBorderColor = UIColor.green400.cgColor
            titleColor = .green400
            font = .bold(17)
        case (true, false):
            // Show the correct answer
            bgColor = .green100
            cgBorderColor = UIColor.green400.cgColor
            titleColor = .green400
            font = .bold(17)
            
        case (false, false):
            bgColor = .white
            cgBorderColor = UIColor.clear.cgColor
            titleColor = .gray500
        case (false, true):
            bgColor = .red100
            cgBorderColor = UIColor.red400.cgColor
            titleColor = .red400
            font = .bold(17)
        }
        
        animateButtonChange(bgColor: bgColor,
                            fromBorderColor: layer.borderColor ?? UIColor.clear.cgColor,
                            toBorderColor: cgBorderColor,
                            cgAnimationDuration: 0.15,
                            titleColor: titleColor,
                            font: font)
        
        isUserInteractionEnabled = false
    }
    
    @objc func touchUpInside(_ sender: MCQButton) {
        delegate?.answerSelectedDelegate(sender)
    }

}
