//
//  PracticeIntroViewController.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 05/08/2023.
//

import UIKit

class PracticeIntroViewController: UIViewController {
    
    var problems: [Problem] = []
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Reset index back to the beginning, so we can restart practice
        index = 0
        viewControllers = []
        
        for i in 0..<problems.count {
            let problem = problems[i]
            viewControllers.append(ProblemViewController(with: problem, index: i))
        }
    }
    
    @IBAction func startPractice(_ sender: Any) {
        guard let problemVC = viewControllers[index] as? ProblemViewController else { return }
        problemVC.delegate = self
        
        show(problemVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("hello?")
    }

}

extension PracticeIntroViewController: ProblemViewControllerDelegate {
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
