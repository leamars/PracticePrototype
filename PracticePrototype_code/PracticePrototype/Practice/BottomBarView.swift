//
//  BottomBarView.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 29/11/2023.
//

import UIKit

enum BottomBarViewMode {
    case solvable
    case stepForward
    case stepBackwards
}

class BottomBarView: UIView {

    // This needs to handle explanation, step, and solvable modes and adujst the size accordingly!
    
    var solvableResponseView = SolvableResponseView(with: .correct)
    var lessonStep: LessonStep {
        didSet {
            showContinueOrCheck()
        }
    }
    var checkButton = BitsButton.create(withStyle: .primary, title: "Check")
    var continueStepButton = BitsButton.create(withStyle: .primary, title: "Continue")
    var continueButton = BitsButton.create(withStyle: .primary, title: "Continue")
    var whyButton = BitsButton.create(withStyle: .primaryDeemphasized, title: "Why?")
    var solvableButtonsStackView = UIStackView()
    
    // Delegate actions
    var continuePressedWithCompletion: (() -> Void)?
    var whyPressedWithCompletion: (() -> Void)?
    var checkPressedWithCompletion: (() -> Void)?
    var contStepPressedWithCompletion: (() -> Void)?
    var didCloseExplanationWithCompletion: (() -> Void)?
    
    // This needs to be initialized with the LessonStep, and then the step changes with each "step"
    init(with lessonStep: LessonStep) {
        self.lessonStep = lessonStep
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .white
        
        checkButton.isEnabled = false
        checkButton.isHidden = true
        continueStepButton.isEnabled = true
        continueStepButton.isHidden = false
        
        solvableButtonsStackView = UIStackView(arrangedSubviews: [whyButton, continueButton])
        solvableButtonsStackView.axis = .horizontal
        solvableButtonsStackView.spacing = 10
        solvableButtonsStackView.distribution = .fillProportionally
                
        solvableResponseView.addSubview(solvableButtonsStackView)
        solvableResponseView.delegate = self
        addSubview(solvableResponseView)
        
        solvableResponseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        solvableButtonsStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        
        whyButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.greaterThanOrEqualTo(80).offset(-4)
        }
        
        whyButton.addTarget(self, action: #selector(whyPressed), for: .touchUpInside)
        
        continueButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.greaterThanOrEqualTo(80).offset(-4)
        }
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(52)
        }
        
        checkButton.addTarget(self, action: #selector(checkPressed), for: .touchUpInside)
        solvableResponseView.isHidden = true
        
        addSubview(continueStepButton)
        continueStepButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(52)
        }
        
        continueStepButton.addTarget(self, action: #selector(continueStepPressed), for: .touchUpInside)
    }
    
    func showContinueOrCheck() {
        solvableResponseView.isHidden = true
        let isSolvableStep = lessonStep.type == .solvable
        let isSolved = lessonStep.solvable?.isSolved ?? false
        
        layer.cornerRadius = 0
        solvableResponseView.layer.cornerRadius = 0
        layer.borderWidth = 0
        
        removeShadow()
        
        UIView.animate(withDuration: 0.2) {
            self.checkButton.alpha = isSolvableStep && !isSolved ? 1.0 : 0.0
            self.continueStepButton.alpha = !isSolvableStep || (isSolvableStep && isSolved) ? 1.0 : 0.0
            
        } completion: { completed in
            // Actually hide the current button that's not useful
            self.checkButton.isHidden = !isSolvableStep || (isSolvableStep && isSolved)
            self.checkButton.isEnabled = false
            self.continueStepButton.isHidden = isSolvableStep && !isSolved
        }
    }
    
    func updateContinueStepTitle(with title: String) {
        continueStepButton.setTitle(title, for: .normal)
    }
    
    @objc func continueStepPressed(sender: UIButton) {
        continuePressedWithCompletion?()
    }
    
    @objc func checkPressed(sender: UIButton) {
        checkPressedWithCompletion?()
    }
    
    func showWhyAndContinue(withAnswer isCorrect: Bool, problem: Problem) {
        guard lessonStep.type == .solvable else { return }
        
        checkButton.isHidden = true
        continueStepButton.isHidden = true
        solvableResponseView.problem = problem
        whyButton.isHidden = false
        layer.cornerRadius = 0
        solvableResponseView.layer.cornerRadius = 0
        layer.borderWidth = 0
        
        if isCorrect {
            whyButton.buttonStyle = .primaryDeemphasized
            solvableResponseView.style = .correct
            continueButton.buttonStyle = .primaryCorrect
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        } else {
            solvableResponseView.style = .incorrect
            whyButton.buttonStyle = .primaryIncorrect
            continueButton.buttonStyle = .primaryDeemphasized
        }
        
        // Make sure Why & Continue come out on top
        solvableResponseView.bringSubviewToFront(solvableButtonsStackView)

        // This needs to live somewhere else as well
//        currentStep.solvable?.isSolved = true
        
        // Update solvableResponseView
        solvableResponseView.snp.remakeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.height.equalTo(solvableResponseView.style.height)
        }
        
        solvableResponseView.isHidden = false
        
    }
    
    @objc func whyPressed(sender: UIButton) {
        whyPressedWithCompletion?()
    }
    
    @objc func continuePressed(sender: UIButton) {
        continuePressedWithCompletion?()
    }
    
    func showExplanation() {
        solvableResponseView.titleStackView.isHidden = true
        continueButton.buttonStyle = .primary
        whyButton.setTitleColor(.clear, for: .normal)
        animateCornerRadius(from: layer.cornerRadius, to: 16, duration: 0.2)
        
        solvableResponseView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.25) {
            // nothing
            self.whyButton.backgroundColor = .clear
            self.whyButton.isHidden = true
            self.whyButton.superview?.setNeedsLayout()
            self.whyButton.superview?.layoutIfNeeded()
        } completion: { completed in
            // This does not animate
        }
        
        UIView.animate(withDuration: 0.30, delay: 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0.7) {
            // Animate bottom bar constraints
            self.layoutIfNeeded()
        } completion: { completion in
            // This does not animate
            self.layer.borderColor = UIColor.gray100.cgColor
            self.layer.borderWidth = 1
        }
        solvableResponseView.mode = .explanation
        addShadow()
    }
    
    func showResult() {
        animateCornerRadius(from: layer.cornerRadius, to: 0, duration: 0.2)
        layer.borderWidth = 0
        solvableResponseView.mode = .result
        
        solvableResponseView.snp.remakeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.height.equalTo(solvableResponseView.style.height)
        }
        
        removeShadow()
    }
    
    func animateCornerRadius(from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        CATransaction.setCompletionBlock {
            self.layer.cornerRadius = to
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        layer.add(animation, forKey: "cornerRadius")
        CATransaction.commit()
    }
    
    func addShadow() {
      
      layer.cornerRadius = 20
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOpacity = 0.2
      layer.shadowRadius = 10
      layer.shadowOffset = CGSize(width: -1, height: 2)
    }
    
    func removeShadow() {
      
      layer.shadowColor = UIColor.clear.cgColor
      layer.shadowOpacity = 0
      layer.shadowRadius = 0
      layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

extension BottomBarView: SolvableResponseDelegate {
    func didChangeSolvableResponseMode(_ bottomBar: SolvableResponseView) {
        print("Did change response mode")
    }
    
    func didSwipeDown(_ bottomBar: SolvableResponseView) {
        didCloseExplanationWithCompletion?()
        showResult()
    }
    
    func didSwipeUp(_ bottomBar: SolvableResponseView) {
        print("Did swipe up")
    }
    
}
