//
//  BottomBarView.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 05/08/2023.
//

import UIKit
import SnapKit

enum BottomBarStyle {
    case correct
    case incorrect
    case tryAgain
    
    var bgColor: UIColor {
        switch self {
        case .correct:
            return .green200
        case .incorrect:
            return .gray100
//            return .red200
        case .tryAgain:
            return .gray200
        }
    }
    
    var image: UIImage {
        switch self {
        case .correct:
            return UIImage(named: "partyPopper")!
        case .incorrect:
            return UIImage(named: "thinking")!
        case .tryAgain:
            return UIImage(named: "magnifyingGlass")!
        }
    }
    
    var title: String {
        switch self {
        case .correct:
            return "Correct!"
        case .incorrect:
            return "Incorrect!"
        case .tryAgain:
            return "Try Again!"
        }
    }
    
    var height: CGFloat{
        return 156.0
    }
}

enum BottomBarMode {
    // Just showing the "result", so "correct, incorrect, try again"
    case result
    // Showing the full explanation
    case explanation
}

protocol BottomBarDelegate: AnyObject {
    func didChangeBottomBarMode(_ bottomBar: BottomBarDrawerView)
    func didSwipeDown(_ bottomBar: BottomBarDrawerView)
    func didSwipeUp(_ bottomBar: BottomBarDrawerView)
}

class BottomBarDrawerView: UIView {

    // Data
    var style: BottomBarStyle {
        didSet {
            backgroundColor = style.bgColor
            contentView.backgroundColor = style.bgColor
            emojiImageView.image = style.image
            label.text = style.title
        }
    }
    
    var mode: BottomBarMode = .result {
        didSet {
            switch mode {
            case .explanation:
                showExplanation()
            case .result:
                showResult()
            }
        }
    }
    
    var delegate: BottomBarDelegate?
    var problem: Problem? {
        didSet {
            setupViews()
        }
    }
    
    // UI
    private let contentView = UIView()
    private let label = UILabel()
    private let emojiImageView = UIImageView()
    var titleStackView = UIStackView()
    
    let solutionImageView = UIImageView()
    private let pageControl = UIPageControl()
    let descriptionLabel = UILabel()
    
    private var answerIndex = 0
    
    init(with style: BottomBarStyle) {
        self.style = style
        super.init(frame: .zero)
    }
    
    init(with style: BottomBarStyle, problem: Problem) {
        self.style = style
        self.problem = problem
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = style.bgColor
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.gray300.cgColor
        
        contentView.backgroundColor = style.bgColor
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(24)
            make.bottom.trailing.equalToSuperview().inset(24)
        }
        
        emojiImageView.image = style.image
        label.text = style.title
        label.font = .bold(20)
        
        titleStackView = UIStackView(arrangedSubviews: [emojiImageView, label])
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fillProportionally
        titleStackView.spacing = 8
        contentView.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        emojiImageView.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        guard let problem = problem else { return }
        
        let solutionImage = UIImage(named: problem.explanation.first!.image)!
        solutionImageView.image = solutionImage
        solutionImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(solutionImageView)
        
        solutionImageView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp_bottomMargin).offset(16)
            make.width.centerX.equalToSuperview()
        }
        
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = answerIndex
        pageControl.numberOfPages = problem.explanation.count
        pageControl.pageIndicatorTintColor = .gray300
        pageControl.currentPageIndicatorTintColor = .black

        contentView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(solutionImageView.snp_bottomMargin).offset(24)
            make.height.equalTo(8)
            make.centerX.width.equalToSuperview()
        }

        descriptionLabel.numberOfLines = 5
        
        let longestDescription = problem.explanation.max(by: {$1.description.count > $0.description.count} )?.description
        
        descriptionLabel.text = longestDescription ?? ""
        descriptionLabel.font = .regular(17)
        descriptionLabel.textColor = .black

        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp_bottomMargin).offset(24)
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview().inset(100)
        }
        
        pageControl.alpha = 0
        solutionImageView.alpha = 0
        descriptionLabel.alpha = 0
        
        setupTouchGestures()
    }
    
    func updateImageSize() {
        let imageWidth = solutionImageView.image!.size.width
        let imageHeight = solutionImageView.image!.size.height
        let actualWidth = frame.width - 2*24 // the inset + offset for contentView
        let actualHeight = (actualWidth/imageWidth) * imageHeight
        
        solutionImageView.snp.remakeConstraints { make in
            make.top.equalTo(titleStackView.snp_bottomMargin).offset(16)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(actualHeight)
        }
    }
    
    func setupTouchGestures() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
        swipeDownGesture.direction = .down
        contentView.addGestureRecognizer(swipeDownGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp))
        swipeUpGesture.direction = .up
        contentView.addGestureRecognizer(swipeUpGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeftGesture.direction = .left
        contentView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRightGesture.direction = .right
        contentView.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc func didSwipeDown(sender: UISwipeGestureRecognizer) {
        delegate?.didSwipeDown(self)
    }
    
    @objc func didSwipeUp(sender: UISwipeGestureRecognizer) {
        delegate?.didSwipeUp(self)
    }
    
    @objc func didSwipeLeft(sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            if answerIndex >= 0 && answerIndex < 2 {
                answerIndex = answerIndex + 1
            } else {
                answerIndex = 2
            }
            
        default: break
        }
        
        updatePageControl()
    }
    
    @objc func didSwipeRight(sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            if answerIndex > 0 {
                answerIndex = answerIndex - 1
            } else {
                answerIndex = 0
            }
            
        default: break
        }
        
        updatePageControl()
    }
    
    func updatePageControl() {
        guard let problem = problem else { return }
        
        pageControl.currentPage = answerIndex
        let image = UIImage(named: problem.explanation[answerIndex].image)
        
        UIView.transition(with: solutionImageView, duration: 0.2, options: .transitionCrossDissolve) {
            self.solutionImageView.image = image
        }
        
        UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.descriptionLabel.text = problem.explanation[self.answerIndex].description
        }
    }
    
    func showExplanation() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        animateCornerRadius(from: layer.cornerRadius, to: 16, duration: 0.2)
        
        label.text = "Explanation!"
        emojiImageView.image = UIImage(named: "magnifyingGlass")!
        
        // Ensure that the height of the description stays the same, based off of the longest description
        let descriptionLabelHeight = descriptionLabel.frame.height
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(descriptionLabelHeight)
        }
        
        descriptionLabel.text = problem?.explanation.first?.description ?? ""
                
        pageControl.alpha = 1
        solutionImageView.alpha = 1
        descriptionLabel.alpha = 1
        
    }
    
    func showResult() {
        backgroundColor = style.bgColor
        contentView.backgroundColor = style.bgColor
        animateCornerRadius(from: layer.cornerRadius, to: 0, duration: 0.2)
        
        label.text = style.title
        emojiImageView.image = style.image
        
        // Hide all the other views
        pageControl.alpha = 0
        solutionImageView.alpha = 0
        descriptionLabel.alpha = 0
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
    
}
