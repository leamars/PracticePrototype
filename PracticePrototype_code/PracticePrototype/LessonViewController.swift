//
//  LessonViewController.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 04/11/2023.
//

import UIKit
import SnapKit


class LessonViewController: UIViewController {
    
    // Lesson Data
    var lessonSteps: [LessonStep]
    var currentStep: LessonStep {
        get {
            return lessonSteps[layout.currentPage]
        }
        set {
            lessonSteps[layout.currentPage] = newValue
        }
    }
    
    // UI
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
    var bottomBarView: BottomBarView
    
    var itemW: CGFloat {
        return 352.0
    }
    
    var itemH: CGFloat {
        return 595.0
    }
    
    init(with lessonSteps: [LessonStep], layoutType: LayoutType) {
        self.lessonSteps = lessonSteps
        self.bottomBarView = BottomBarView(with: lessonSteps[0])
        self.layout.layoutType = layoutType
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
        
        bottomBarView.checkPressedWithCompletion = { [weak self]  in
            guard let self = self else { return }
            updateBottomBarForCheckPressed()
        }
        
        bottomBarView.continuePressedWithCompletion = { [weak self]  in
            guard let self = self else { return }
            minimizeBottomBar()
            continueToNextStep()
        }
        
        bottomBarView.whyPressedWithCompletion = { [weak self]  in
            guard let self = self else { return }

            bottomBarView.snp.remakeConstraints { make in
                make.width.centerX.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(150)
            }
            
            progressView.layer.opacity = 0
            
            if layout.layoutType == .horizontal {
                self.collectionView.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            
            self.view.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25) {
                // nothing
                self.bottomBarView.showExplanation()
                
                if self.layout.layoutType == .vertical {
                    self.collectionView.snp.remakeConstraints { make in
                        make.left.right.equalToSuperview()
                        make.top.equalTo(self.progressView.snp.bottom).offset(-QuestionLayout.height/3)
                        make.bottom.equalToSuperview()
                    }
                } else {
                    self.collectionView.transform = CGAffineTransform(translationX: 0, y: -QuestionLayout.height/3)
                }
                
            } completion: { completed in
                // This does not animate
            }
        }
        
        bottomBarView.didCloseExplanationWithCompletion = { [weak self]  in
            guard let self = self else { return }
            minimizeBottomBar()
        }
        
        bottomBarView.contStepPressedWithCompletion = { [weak self]  in
            guard let self = self else { return }
            continueToNextStep()
        }
    }
    
    func updateBottomBarForCheckPressed() {
        guard let solvable = currentStep.solvable else { return }
        
        var isCorrect = false
        
        switch solvable.type {
        case .diagrammar:
            guard let correctIndex = solvable.correctIndex, let chosenIndex = solvable.chosenIndex else { return }
            isCorrect = correctIndex == chosenIndex
        case .mcq:
            let indexPath = IndexPath(item: layout.currentPage, section: 0)
            guard let cell = collectionView.cellForItem(at: indexPath) as? LessonStepCell,
                  let selectedAnswer = cell.mcqAnswersView.selectedAnswer else { return }
            isCorrect = selectedAnswer.isCorrectAnswer
        case .envelope, .simson: break
        }
        
        bottomBarView.showWhyAndContinue(withAnswer: isCorrect, problem: solvable)
    }
    
    func minimizeBottomBar() {
        bottomBarView.snp.remakeConstraints { make in
            make.bottom.width.centerX.equalToSuperview()
            make.height.equalTo(92)
        }
        
        collectionView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom)
            make.bottom.equalTo(bottomBarView.snp.top)
        }
        
        progressView.layer.opacity = 1
        
        UIView.animate(withDuration: 0.25) {
            // nothing
            self.collectionView.transform = .identity
            self.updateBottomBarForCheckPressed()
            self.view.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
        } completion: { completed in
            // This does not animate
        }
    }
    

    func setupViews() {
        view.backgroundColor = .white
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
        collectionView.decelerationRate = .fast
        
        collectionView.registerCell(LessonStepCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        containerView.addSubview(collectionView)
        collectionView.backgroundColor = .clear

        setupBottomBar()
        
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
        animteIntroBookendOut()
    }
    
    private func animteIntroBookendOut() {
        var translationTransform: CGAffineTransform
        switch layout.layoutType {
        case .horizontal:
            translationTransform = CGAffineTransform(translationX: -screenWidth, y: 0)
        case .vertical, .verticalHug:
            translationTransform = CGAffineTransform(translationX: 0, y: -screenHeight)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.introImage.transform = translationTransform
            self.introImage.alpha = 0
            self.whiteOutView.alpha = 0
        }) { (finished) in
            // Animation completion code
            self.whiteOutView.removeFromSuperview()
        }
    }
    
    func setupBottomBar() {
        containerView.addSubview(bottomBarView)
        bottomBarView.snp.makeConstraints { make in
            make.bottom.width.centerX.equalTo(view)
            make.height.equalTo(92)
        }
        
        bottomBarView.showContinueOrCheck()
    }
    
    func pageDidChange() {

        bottomBarView.lessonStep = currentStep
        
        // if success/failure bar is still there, we should dismiss it!
        
        // Update progress bar
        progressView.updateProgressBar(with: CGFloat(layout.currentPage), from: CGFloat(lessonSteps.count-1))
        
        // Update CTA names
        if layout.currentPage == lessonSteps.count - 1 {
            bottomBarView.updateContinueStepTitle(with: "Finish Lesson")
        } else {
            bottomBarView.updateContinueStepTitle(with: "Continue")
        }
    }
    
    @objc func continueStepPressed(sender: UIButton) {
        continueToNextStep()
    }
    
    func continueToNextStep() {
        let currentPage = layout.currentPage
        let nextPage = currentPage + 1
        
        guard nextPage < lessonSteps.count else { return }
        
        let indexPath = IndexPath(item: nextPage, section: 0)
        switch layout.layoutType {
        case .vertical, .verticalHug:
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        case .horizontal:
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        layout.currentPage = nextPage
        layout.previousOffset = layout.updateOffset(collectionView)
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
            layout.minimumLineSpacing = 50.0
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        case .vertical:
            layout.scrollDirection = .vertical
            layout.itemSize.height = itemH
            layout.minimumLineSpacing = 50.0
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        case .verticalHug:
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 50.0
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
            // TODO: Need to resolve how we parse the JSON for this
            //layout.itemSize.height = lessonSteps[0].height
        }
                
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom)
            make.bottom.equalTo(bottomBarView.snp.top)
        }
    }

}

// MARK: UICollectionViewDelegate
extension LessonViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isSolvable = currentStep.type == .solvable
        
        if !isSolvable {
            self.solvableModeImg.layer.opacity = 0.0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.solvableModeImg.layer.opacity = isSolvable ? 0.5 : 0.0
        } completion: { completed in
        }
    }
    
    // Especially for verticalHugging, this allows you to tap on the next item and smoothly scroll to it
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == layout.currentPage {
            
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

// MARK: UICollectionViewDataSource
extension LessonViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonSteps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as LessonStepCell
                
        let lessonStep = lessonSteps[indexPath.item]
        cell.lessonStep = lessonStep
        
        cell.solvableStepDidChange = { [weak self] in
            guard let self = self else { return }
            solvableStepDidChange()
        }
        
        return cell
    }
    
    func solvableStepDidChange() {
        bottomBarView.checkButton.isEnabled = true
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
