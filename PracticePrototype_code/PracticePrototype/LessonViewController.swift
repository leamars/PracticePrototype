//
//  LessonViewController.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 04/11/2023.
//

import UIKit
import SnapKit


class LessonViewController: UIViewController {
    // DATA!
    var lessonSteps: [LessonStep]
    
    // UI STUFF
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var safeAreaInsets: UIEdgeInsets {
        guard let window = UIApplication.shared.windows.first else { return UIEdgeInsets.zero }
        return window.safeAreaInsets
    }
    
    private var introImage = UIImageView()
    private var startLessonBtn = BitsButton.create(withStyle: .primary, title: "Start Lesson")
    private var solvableModeImg = UIImageView()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var layout = LessonStepLayout()
    private let containerView = UIView()
    private var whiteOutView = UIView()
        
    let progressView = ProgressBarView(frame: .zero)
    let progressViewBg = UIView()
    
    // All of these are essential to the bottom bar!
    var bottomBarView = BottomBarDrawerView(with: .correct)
    var bottomButtonsView = UIView()
    var checkButton = BitsButton.create(withStyle: .primary, title: "Check")
    var continueStepButton = BitsButton.create(withStyle: .primary, title: "Continue")
    var continueButton = BitsButton.create(withStyle: .primary, title: "Continue")
    var whyButton = BitsButton.create(withStyle: .primaryDeemphasized, title: "Why?")
    
    var itemW: CGFloat {
        return screenWidth * 0.92
    }
    
    var itemH: CGFloat {
        return 595.0
    }
    
    init(with lessonSteps: [LessonStep]) {
        self.lessonSteps = lessonSteps
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        layout.pageDidChangeClosure = { [weak self]  in
            guard let self = self else { return }
            pageDidChange()
        }
    }
    
    // THIS DOESN'T WORK AS EXPECTED :(
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    

    func setupViews() {
        view.backgroundColor = .white
        
        solvableModeImg.image = UIImage(named: "dotted")
        containerView.addSubview(solvableModeImg)
        solvableModeImg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        solvableModeImg.layer.opacity = 0.0
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressViewBg.backgroundColor = .white
        containerView.addSubview(progressViewBg)
        
        containerView.addSubview(progressView)
        
        progressView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaInsets.top)
            make.width.centerX.equalToSuperview()
        }
        
        progressViewBg.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
            make.bottom.equalTo(progressView)
        }
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        // 50.0 is equal to the "minimumLineSpacing", so that the first and last item have the same offset as all the rest
        collectionView.decelerationRate = .fast
        
        collectionView.registerCell(LessonStepCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        containerView.addSubview(collectionView)
        
        collectionView.backgroundColor = .clear

        setupBottomBar()
        checkButton.isEnabled = false
        checkButton.isHidden = true
        continueStepButton.isEnabled = true
        continueStepButton.isHidden = false
        
        setupVerticalNavigation()
        
        containerView.bringSubviewToFront(progressView)
        
        whiteOutView.backgroundColor = .white
        view.addSubview(whiteOutView)
        whiteOutView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introImage = UIImageView(image: UIImage(named: "dataIntro"))
        view.addSubview(introImage)
        introImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introImage.addSubview(startLessonBtn)
        startLessonBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-40)
            make.width.equalTo(view).multipliedBy(0.9)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
        }
        introImage.isUserInteractionEnabled = true
        
        startLessonBtn.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        startLessonBtn.isEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateOnTap(recognizer:)))
        progressView.addGestureRecognizer(tapGesture)
    }
    
    @objc func startPressed(sender: UIButton) {
        print("Animate this out...")
        
        let translationTransform = CGAffineTransform(translationX: 0, y: -screenHeight)
        //containerView.transform = CGAffineTransform(translationX: 0, y: 2*screenHeight)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.introImage.transform = translationTransform
            self.introImage.alpha = 0
            self.whiteOutView.alpha = 0
            //self.containerView.transform = .identity
        }) { (finished) in
            // Animation completion code
            self.whiteOutView.removeFromSuperview()
        }
    }
    
    func showContinueOrCheck() {
        for subview in bottomButtonsView.subviews {
            subview.removeFromSuperview()
        }
        
        bottomButtonsView.addSubview(continueStepButton)
        continueStepButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        continueStepButton.addTarget(self, action: #selector(continueStepPressed), for: .touchUpInside)
        
        bottomButtonsView.addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkButton.addTarget(self, action: #selector(checkPressed), for: .touchUpInside)
        bottomBarView.isHidden = true
    }
    
    func showWhyAndContinue() {
        let lessonStep = lessonSteps[layout.currentPage]
        guard lessonStep.type == .solvable else { return }
        
        for subview in bottomButtonsView.subviews {
            subview.removeFromSuperview()
        }
        
        let bottomButtonsStackView = UIStackView(arrangedSubviews: [whyButton, continueButton])
        bottomButtonsStackView.axis = .horizontal
        bottomButtonsStackView.spacing = 10
        bottomButtonsStackView.distribution = .fillProportionally
        
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
        
        guard let cell = collectionView.cellForItem(at: IndexPath(item: layout.currentPage, section: 0)) as? LessonStepCell,
            let solvable = lessonStep.solvable else { return }
        
        // if it's an mcq
        
        if solvable.type == .mcq {
            guard let selectedAnswer = cell.mcqAnswersView.selectedAnswer else { return }
            if selectedAnswer.isCorrectAnswer {
                whyButton.buttonStyle = .primaryDeemphasized
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
            cell.mcqAnswersView.updateAnswersForSubmitted()
        } else {
            guard let correctIndex = solvable.correctIndex, let chosenIndex = solvable.chosenIndex else { return }
            if correctIndex == chosenIndex {
                whyButton.buttonStyle = .primaryDeemphasized
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
        }
        
        lessonSteps[layout.currentPage].solvable?.isSolved = true
        
        // Update bottom bar view
        
        bottomBarView.snp.remakeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp_bottomMargin).inset(-safeAreaInsets.bottom)
            make.height.equalTo(bottomBarView.style.height)
        }
        
        bottomBarView.isHidden = false
    }
    
    func setupBottomBar() {
        containerView.addSubview(bottomButtonsView)
        
        bottomButtonsView.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-40)
            make.width.equalTo(view).multipliedBy(0.9)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
        }
        
        showContinueOrCheck()
        
        containerView.addSubview(bottomBarView)
        
        bottomBarView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_bottomMargin).offset(safeAreaInsets.bottom)
            make.width.centerX.equalToSuperview()
        }
        
        bottomBarView.setupViews()
        
        containerView.bringSubviewToFront(bottomButtonsView)
    }
    
    func pageDidChange() {
        let lessonStep = lessonSteps[layout.currentPage]
        let isSolvable = lessonStep.type == .solvable
        // If it's a solvable, we want to make the Check button visible, else Continue
        
        let indexPath = IndexPath(item: layout.currentPage, section: 0)
        
        // if success/failure bar is still there, we should dismiss it!
        
        UIView.animate(withDuration: 0.2) {
            self.checkButton.alpha = isSolvable ? 1.0 : 0.0
            self.continueStepButton.alpha = isSolvable ? 0.0 : 1.0
            //self.view.backgroundColor = isSolvable ? UIColor.purple100 : .white
            self.solvableModeImg.layer.opacity = isSolvable ? 0.5 : 0.0
            
//            if isSolvable {
//                cell?.contentView.backgroundColor = .blue100
//                cell?.backgroundColor = .blue100
//            } else {
//                cell?.contentView.backgroundColor = .white
//                cell?.backgroundColor = .white
//            }
            
        } completion: { completed in
            // Actually HIDE the current one
            self.showContinueOrCheck()
            self.checkButton.isHidden = lessonStep.type != .solvable
            self.checkButton.isEnabled = false
            self.continueStepButton.isHidden = lessonStep.type == .solvable
        }
        
        progressView.updateProgressBar(with: CGFloat(layout.currentPage), from: CGFloat(lessonSteps.count-1))
        
        if layout.currentPage == lessonSteps.count - 1 {
            continueStepButton.setTitle("Finish Lesson", for: .normal)
        } else {
            continueStepButton.setTitle("Continue", for: .normal)
        }
    }
    
    @objc func continueStepPressed(sender: UIButton) {
        continueToNextStep()
    }
    
    func continueToNextStep() {
        let currentPage = layout.currentPage
        let nextPage = currentPage + 1
        
        let indexPath = IndexPath(item: nextPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        layout.currentPage = nextPage
        
        layout.previousOffset = layout.updateOffset(collectionView)
    }
    
    @objc func checkPressed(sender: UIButton) {
        showWhyAndContinue()
    }
    
    @objc func whyPressed(sender: UIButton) {
        print("Why pressed!")
    }
    
    @objc func continuePressed(sender: UIButton) {
        showContinueOrCheck()
        continueToNextStep()
    }
    
    @objc func animateOnTap(recognizer: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupVerticalNavigation() {
        
        collectionView.collectionViewLayout = layout
        layout.delegate = self
        
        // Change based on layout type
        switch layout.layoutType {
        case .horizontal:
            layout.scrollDirection = .horizontal
            layout.itemSize.height = itemH
        case .vertical:
            layout.scrollDirection = .vertical
            layout.itemSize.height = itemH
        case .verticalHug:
            layout.scrollDirection = .vertical
            // TODO: Need to resolve how we parse the JSON for this
            //layout.itemSize.height = lessonSteps[0].height
        }

        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        layout.minimumLineSpacing = 15.0
        layout.minimumInteritemSpacing = 15.0
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom)
            make.bottom.equalTo(bottomButtonsView.snp.top).offset(-10)
        }
    }

}

extension LessonViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            //setupCells()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let lessonStep = lessonSteps[layout.currentPage]
        let isSolvable = lessonStep.type == .solvable
        // If it's a solvable, we want to make the Check button visible, else Continue
        
        // if success/failure bar is still there, we should dismiss it!
        
        if !isSolvable {
            self.solvableModeImg.layer.opacity = 0.0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.solvableModeImg.layer.opacity = isSolvable ? 0.5 : 0.0
        } completion: { completed in
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == layout.currentPage {
            print("didSelectItemAt: \(indexPath)")
//            // let's make it big!
//            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
//            if cell.transform == .identity {
//                cell.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//            } else {
//                cell.transform = .identity
//            }
            
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            layout.currentPage = indexPath.item
            
            layout.previousOffset = layout.updateOffset(collectionView)
            setupCells()
        }
    }
    
    private func setupCells() {
        let currentPage = layout.currentPage
        let previousPage = currentPage - 1
        let nextPage = currentPage + 1
        
        let currentIndex = IndexPath(item: currentPage, section: 0)
        let previousIndex = IndexPath(item: previousPage, section: 0)
        let nextIndex = IndexPath(item: nextPage, section: 0)
        
        guard let currentCell = collectionView.cellForItem(at: currentIndex) else { return }
        
        let previousCell = collectionView.cellForItem(at: previousIndex)
        let nextCell = collectionView.cellForItem(at: nextIndex)
        
        UIView.animate(withDuration: 0.2) {
            currentCell.layer.opacity = 1.0
            previousCell?.layer.opacity = 0.0
            nextCell?.layer.opacity = 0.0
        }

    }
}

extension LessonViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonSteps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as LessonStepCell
                
        let lessonStep = lessonSteps[indexPath.item]
        cell.lessonStep = lessonStep
        //addShadow(to: cell)
        
        cell.solvableStepDidChange = { [weak self] in
            guard let self = self else { return }
            solvableStepDidChange()
        }
        
        return cell
    }
    
    func solvableStepDidChange() {
        checkButton.isEnabled = true
    }
    
}

extension LessonViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                        
        switch layout.layoutType {
        case .vertical, .horizontal:
            return CGSize(width: itemW, height: itemH)
        case .verticalHug:
            // TODO: Need to resolve how we parse the JSON for this
            // return CGSize(width: itemW, height: lessonSteps[indexPath.item].height)
            return CGSize(width: itemW, height: itemH)
        }
    }
}

extension LessonViewController: LessonStepLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        switch layout.layoutType {
        case .vertical, .horizontal:
            return itemH
        case .verticalHug:
            // TODO: Need to resolve how we parse the JSON for this
            // return lessonSteps[indexPath.item].height
            return itemH
        }
    }
}

// Extra functionality I don't care about right now
extension LessonViewController {
    private func addShadow(to cell: LessonStepCell) {
//        cell.contentView.layer.cornerRadius = 20
//        cell.contentView.layer.shadowColor = UIColor.black.cgColor
//        cell.contentView.layer.shadowOpacity = 1
//        cell.contentView.layer.shadowRadius = 20
//        cell.contentView.layer.shadowOffset = CGSize(width: -1, height: 2)

//        cell.shadowView.layer.cornerRadius = 20
//        cell.shadowView.layer.shadowColor = UIColor.black.cgColor
//        cell.shadowView.layer.shadowOpacity = 0.2
//        cell.shadowView.layer.shadowRadius = 10
//        cell.shadowView.layer.shadowOffset = CGSize(width: -1, height: 2)
        
//        cell.layer.cornerRadius = 2.0
//        cell.layer.borderWidth = 1.0
//        cell.layer.borderColor = UIColor.clear.cgColor
//        cell.layer.masksToBounds = true

//        cell.layer.cornerRadius = 20
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOpacity = 1
//        cell.layer.shadowRadius = 20
//        cell.layer.shadowOffset = CGSize(width: -1, height: 2)
//        cell.layer.masksToBounds = false
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

    }
    
    private func removeShadow(from cell: UICollectionViewCell) {
        cell.contentView.layer.shadowColor = UIColor.clear.cgColor
    }
    
//    private func updateVerticalProgressBar(for indexPath: IndexPath) {
//        let height = view.frame.height
//        let increment = height / 12
//        let currentHeight = CGFloat(indexPath.row) * increment
//        progressBarView.snp.remakeConstraints { make in
//            make.bottom.left.right.equalToSuperview()
//            make.top.equalTo(view.snp.bottom).offset(-currentHeight)
//        }
//        
//        UIView.animate(withDuration: 0.25) {
//            // nothing
//            self.view.layoutIfNeeded()
//        } completion: { completed in
//            // This does not animate
//        }
//    }
}
