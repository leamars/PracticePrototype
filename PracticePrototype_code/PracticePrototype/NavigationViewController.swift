//
//  NavigationViewController.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 05/08/2023.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

//    private func problemVC(with problem: Problem) -> ProblemViewController {
//        return ProblemViewController(with: problems.first!)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("hello?")
    }

}
