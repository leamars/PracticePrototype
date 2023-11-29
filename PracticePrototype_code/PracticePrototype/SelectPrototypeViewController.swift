//
//  PracticeIntroViewController.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 05/08/2023.
//

import UIKit

class SelectPrototypeViewController: UIViewController {
    
    var problems: [Problem] = []
    var dataLessonSteps: [LessonStep] = []
    var viewControllers: [UIViewController] = []
    private var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let decorder = JSONDecoder()
        do {
              if let bundlePath = Bundle.main.path(forResource: "practice", ofType: "json"),
              let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                  
                  problems = try decorder.decode([Problem].self, from: jsonData)
              }
           } catch {
              print(error)
           }
        
        do {
              if let bundlePath = Bundle.main.path(forResource: "dataLesson", ofType: "json"),
              let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                  
                  dataLessonSteps = try decorder.decode([LessonStep].self, from: jsonData)
              }
           } catch {
              print(error)
           }
    }
    
    @IBAction func startLesson(_ sender: Any) {
        
        // clear out practice VCs basically
        viewControllers = []
//        let lessonVC = LessonViewController()
//        show(lessonVC, sender: self)
//        let lessonIntroVC = LessonIntroViewController(with: dataLessonSteps)
//        show(lessonIntroVC, sender: self)
        
        let lessonVC = LessonViewController(with: dataLessonSteps)
        show(lessonVC, sender: self)
    }
    
    @IBAction func startPractice(_ sender: Any) {
        index = 0
        viewControllers = []
        
        for i in 0..<problems.count {
            let problem = problems[i]
            viewControllers.append(ProblemViewController(with: problem, index: i))
        }
        
        guard let problemVC = viewControllers[index] as? ProblemViewController else { return }
        problemVC.delegate = self
        
        show(problemVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("hello?")
    }

}

extension SelectPrototypeViewController: ProblemViewControllerDelegate {
    func didPressContinue(_ sender: ProblemViewController) {
        index = index + 1
        
        if index > viewControllers.count - 1 {
            for i in 0..<problems.count {
                let problem = problems[i]
                viewControllers.append(ProblemViewController(with: problem, index: i))
            }
        }
        
        guard let problemVC = viewControllers[index] as? ProblemViewController else { return }
        problemVC.delegate = self
        
        show(problemVC, sender: self)
    }
}