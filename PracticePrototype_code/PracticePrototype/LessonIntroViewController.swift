//
//  LessonIntroViewController.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 24/11/2023.
//

import UIKit
import SnapKit

class LessonIntroViewController: UIViewController {

    let lessonSteps: [LessonStep]
    private let imageView = UIImageView()
    private var startLessonBtn = BitsButton.create(withStyle: .primary, title: "Start Lesson")
    
    init(with lessonSteps: [LessonStep]) {
        self.lessonSteps = lessonSteps
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: "dataIntro")
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(startLessonBtn)
        startLessonBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-40)
            make.width.equalTo(view).multipliedBy(0.9)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
        }
        
        startLessonBtn.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        startLessonBtn.isEnabled = true
    }
    
    @objc func startPressed(sender: UIButton) {
        let lessonVC = LessonViewController(with: lessonSteps)
        show(lessonVC, sender: self)
    }

}
