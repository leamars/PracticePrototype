//
//  PracticeViewController.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 02/08/2023.
//

import UIKit
import SnapKit


protocol ProblemViewControllerDelegate: AnyObject {
    func didPressContinue(_ sender: ProblemViewController)
}

class ProblemViewController: UIViewController {
    
    // Data
    var problem: Problem
    var delegate: ProblemViewControllerDelegate?
    var index = 0
    
    // UI
    //var progressView = UIProgressView(progressViewStyle: .default)
    var navBarView = UIImageView()
    var solutionLabel = UILabel()
    var problemView: ProblemView
    var mcqAnswersView = MCQAnswersView()
    var bottomBarView = BottomBarDrawerView(with: .correct)
    
    var bottomButtonsView = UIView()
    var checkButton = BitsButton.create(withStyle: .primary, title: "Check")
    
    var continueButton = BitsButton.create(withStyle: .primary, title: "Continue")
    var whyButton = BitsButton.create(withStyle: .primaryDeemphasized, title: "Why?")
    
    let background = UIImageView()
    let overlayView = UIView()
    let whiteUnderlayView = UIView()
    
    var safeAreaInsets: UIEdgeInsets {
        guard let window = UIApplication.shared.windows.first else { return UIEdgeInsets.zero }
        return window.safeAreaInsets
    }
    
    init(with problem: Problem, index: Int) {
        self.problem = problem
        self.problemView = ProblemView(problem: problem)
        self.index = index
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        overlayView.backgroundColor = .clear
        
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnBackground))
        overlayView.addGestureRecognizer(backgroundTap)
        
        // Problem Solving Background
        view.addSubview(background)
        background.image = UIImage(named: "problemSolving")
        background.contentMode = .scaleAspectFill
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        background.alpha = 0
        
//        view.addSubview(progressView)
//        progressView.trackTintColor = .gray100
//        progressView.tintColor = .green500
//        let progress: Float = Float(index) / Float(3)
//        progressView.progress = progress
//        progressView.layer.cornerRadius = 4
//
//        progressView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(safeAreaInsets.top + 15 + 16)
//            make.width.equalToSuperview().multipliedBy(0.9)
//            make.centerX.equalToSuperview()
//            make.height.equalTo(8)
//        }
        
        navBarView = UIImageView(image: UIImage(named: "navBarImage")!)
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaInsets.top)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(problemView)
        problemView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalToSuperview().offset(100)
        }
        
        view.addSubview(bottomButtonsView)
        
        bottomButtonsView.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-40)
            make.width.equalTo(view).multipliedBy(0.9)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
        }
        
        bottomButtonsView.addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkButton.addTarget(self, action: #selector(checkPressed), for: .touchUpInside)
        checkButton.isEnabled = false
        
        mcqAnswersView.problem = problem
        mcqAnswersView.delegate = self
        view.addSubview(mcqAnswersView)
        mcqAnswersView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.bottom.equalTo(bottomButtonsView.snp_topMargin).offset(-30)
        }
        
        view.addSubview(bottomBarView)
        bottomBarView.problem = problem
        bottomBarView.delegate = self
        
        bottomBarView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_bottomMargin).offset(safeAreaInsets.bottom)
            make.width.centerX.equalToSuperview()
        }
        
        view.bringSubviewToFront(bottomButtonsView)
        
        whiteUnderlayView.backgroundColor = .white
        view.insertSubview(whiteUnderlayView, belowSubview: problemView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bottomBarView.updateImageSize()
    }
    
    @objc func mcqPressed(sender: UIButton) {
        sender.setTitleColor(.blue, for: .normal)
        sender.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        sender.layer.borderColor = UIColor.blue.cgColor
        print("button pressed")
    }
    
    @objc func checkPressed(sender: UIButton) {
        
        guard let selectedAnswer = mcqAnswersView.selectedAnswer else { return }
        
        let bottomButtonsStackView = UIStackView(arrangedSubviews: [whyButton, continueButton])
        bottomButtonsStackView.axis = .horizontal
        bottomButtonsStackView.spacing = 10
        bottomButtonsStackView.distribution = .fillProportionally
        
        checkButton.removeFromSuperview()
        bottomButtonsView.addSubview(bottomButtonsStackView)
        
        bottomButtonsStackView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
        }
        
        whyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-40)
            make.height.equalTo(52)
            make.width.greaterThanOrEqualTo(80).offset(-4)
        }
        
        whyButton.addTarget(self, action: #selector(whyPressed), for: .touchUpInside)
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-40)
            make.height.equalTo(52)
            make.width.greaterThanOrEqualTo(80).offset(-4)
        }
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        // Replace check button with why? + continue
        view.layoutIfNeeded()
        
        // Update style for bottom bar
        if selectedAnswer.isCorrectAnswer {
            bottomBarView.style = .correct
            continueButton.buttonStyle = .primaryCorrect
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        } else {
            bottomBarView.style = .incorrect
            whyButton.buttonStyle = .primaryIncorrect
            continueButton.buttonStyle = .primaryDeemphasized
        }
        
        // Update bottom bar view
        bottomBarView.snp.remakeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(view.snp_bottomMargin).inset(100 + safeAreaInsets.bottom)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0.7) {
            // Update Answes View
            self.answerSubmittedDelegate(self.mcqAnswersView)
            
            // HACK FOR FULL EXPLANATION
            //self.hackMoveMCQupAbsolute()
            // HACK FOR FULL EXPLANATION
            
            // Animate bottom bar constraints
            self.view.layoutIfNeeded()
        }
        
    }
    
    func hackMoveMCQupAbsolute() {
        mcqAnswersView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.bottom.equalTo(view).inset(100 + safeAreaInsets.bottom + 50)
        }
    }
    
    @objc func continuePressed(sender: UIButton) {
        delegate?.didPressContinue(self)
    }

    @objc func whyPressed(sender: UIButton) {
//        maximizeBottomBarDrawerView()
        
        // HACK
        maximizeBottomBarDrawerViewAlternate()
    }
    
    @objc func didTapOnBackground(sender: UITapGestureRecognizer) {
        minimizeBottomBarDrawerView()
    }
}

extension ProblemViewController: MCQAnswersViewDelegate {
    func answerSubmittedDelegate(_ answersView: MCQAnswersView) {
        guard let selectedAnswer = answersView.selectedAnswer else { return }
        answersView.updateAnswersForSubmitted()
        
        if selectedAnswer.isCorrectAnswer {
            print("You got it righ!!")
        } else {
            print("nope...")
        }
    }
    
    func answerSelectedDelegate(_ answersView: MCQAnswersView) {
        checkButton.isEnabled = true
    }
}

extension ProblemViewController: BottomBarDelegate {
    func didChangeBottomBarMode(_ bottomBar: BottomBarDrawerView) {
        //
    }
    
    func didSwipeDown(_ bottomBar: BottomBarDrawerView) {
        minimizeBottomBarDrawerView()
    }
    
    func didSwipeUp(_ bottomBar: BottomBarDrawerView) {
//        maximizeBottomBarDrawerView()
        
        // HACK
        maximizeBottomBarDrawerViewAlternate()
    }
    
    func maximizeBottomBarDrawerViewAlternate() {
        
        guard let selectedAnswer = mcqAnswersView.selectedAnswer else { return }
                
        //progressView.isHidden = true
        
        solutionLabel.text = "Explanation"
        solutionLabel.textAlignment = .center
        solutionLabel.font = .semiBold(16)
        solutionLabel.backgroundColor = .white
        solutionLabel.layer.masksToBounds = true
        solutionLabel.layer.cornerRadius = 8
        
        view.addSubview(solutionLabel)
        solutionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaInsets.top + 20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(36)
        }
        
        whiteUnderlayView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(solutionLabel.snp_bottomMargin)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(bottomBarView)
        view.bringSubviewToFront(bottomButtonsView)
        
        bottomBarView.titleStackView.isHidden = true
        bottomBarView.snp.remakeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.top.equalTo(problemView).offset(70)
        }
                
        continueButton.buttonStyle = .primary
        
        whyButton.setTitleColor(.clear, for: .normal)
        
        navBarView.layer.opacity = 0
        
        UIView.animate(withDuration: 0.25) {
            // nothing
            self.view.backgroundColor = .gray100
            
            self.whyButton.backgroundColor = .clear
            self.whyButton.isHidden = true
            self.whyButton.superview?.setNeedsLayout()
            self.whyButton.superview?.layoutIfNeeded()
        } completion: { completed in
            // This does not animate
        }
        
        UIView.animate(withDuration: 0.30, delay: 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0.7) {
            // Darken the background
            //self.overlayView.backgroundColor = .black200
            self.bottomBarView.mode = BottomBarMode.explanation
            
            // Animate bottom bar constraints
            self.view.layoutIfNeeded()
        } completion: { completion in
            // This does not animate
            self.bottomBarView.layer.cornerRadius = 0
            self.bottomBarView.layer.borderColor = UIColor.gray100.cgColor
            self.bottomBarView.layer.borderWidth = 1
        }
    }
    
    func maximizeBottomBarDrawerView() {
                
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(bottomBarView)
        view.bringSubviewToFront(bottomButtonsView)
                
        bottomBarView.snp.remakeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
        }
        
        continueButton.buttonStyle = .primary
        
        whyButton.setTitleColor(.clear, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            // nothing
            
            self.overlayView.backgroundColor = .black200
            self.whyButton.backgroundColor = .clear
            self.whyButton.isHidden = true
            self.whyButton.superview?.setNeedsLayout()
            self.whyButton.superview?.layoutIfNeeded()
        } completion: { completed in
            // This does not animate
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0.7) {
            // Darken the background
            //self.overlayView.backgroundColor = .black200
            self.bottomBarView.mode = BottomBarMode.explanation
            
            // Animate bottom bar constraints
            self.view.layoutIfNeeded()
        } completion: { completion in
            // This does not animate
        }
        
    }
    
    func minimizeBottomBarDrawerView() {
        // FOR HACK
        //progressView.isHidden = false
        solutionLabel.removeFromSuperview()
        // FOR HACK
        
        bottomBarView.snp.remakeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(view.snp_bottomMargin).inset(100 + safeAreaInsets.bottom)
        }
        
        // Whenever we call minimize that means that "maximize" has already been called, thus, WHY should no longer be the primery, but continue instead!
        continueButton.buttonStyle = .primary
        whyButton.buttonStyle = .primaryDeemphasized
        
        UIView.animate(withDuration: 0.25) {
            // nothing
            self.view.backgroundColor = .white
            self.navBarView.layer.opacity = 100
            
            self.overlayView.backgroundColor = .clear
            self.whyButton.isHidden = false
            self.whyButton.backgroundColor = self.whyButton.buttonStyle.bgColor
//            self.whyButton.setTitleColor(self.whyButton.buttonStyle.fontColor, for: .normal)
            self.whyButton.superview?.setNeedsLayout()
            self.whyButton.superview?.layoutIfNeeded()
            
        } completion: { completed in
            // Show Why button
            self.whyButton.setTitleColor(self.whyButton.buttonStyle.fontColor, for: .normal)
            self.bottomBarView.titleStackView.isHidden = false
        }

        bottomBarView.descriptionLabel.alpha = 0
        bottomBarView.solutionImageView.alpha = 0
        
        UIView.animate(withDuration: 0.30, delay: 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0.7) {
            // Clear the background
            //self.overlayView.backgroundColor = .clear
            self.bottomBarView.mode = BottomBarMode.result
            
            // Animate bottom bar constraints
            self.view.layoutIfNeeded()
        } completion: { completion in
            // This does not animate
        }
    
    }
    
}
