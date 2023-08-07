//
//  ViewController.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 13/04/2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var contentImages: [UIImage] = []
    var contentImageViews: [UIImageView] = []
    var bottomView = UIView(frame: .zero)
    var topView = UIView(frame: .zero)
    var counter = 0
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        scrollToBottom()
        
        for i in 0...4 {
            contentImages.append(UIImage(named: "content\(5-i)")!)
            contentImageViews.append(UIImageView(image: contentImages[i]))
            let contentImageView = contentImageViews[i]
            contentImageView.translatesAutoresizingMaskIntoConstraints = false
            contentImageView.isUserInteractionEnabled = true
            
            view.addSubview(contentImageView)
            contentImageView.snp.makeConstraints { make in
                make.edges.equalTo(view)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.animateOnTap(recognizer:)))
            contentImageView.addGestureRecognizer(tapGesture)
            
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.animateOnSwipeUp(recognizer:)))
            swipeUp.direction = .up
            contentImageView.addGestureRecognizer(swipeUp)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.animateOnSwipeDown(recognizer:)))
            swipeDown.direction = .down
            contentImageView.addGestureRecognizer(swipeDown)
        }
        
        
//        let bottomImage = UIImage(named: "content2")
//        bottomView = UIImageView(image: bottomImage!)
//
//        topView.backgroundColor = .blue
//        topView.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(bottomView)
//        bottomView.snp.makeConstraints { make in
//            make.edges.equalTo(view)
//        }
//
//        bottomView.isUserInteractionEnabled = true
//
//        let topImage = UIImage(named: "content1")
//        topView = UIImageView(image: topImage!)
//        topView.backgroundColor = .green
//        topView.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(topView)
//        topView.snp.makeConstraints { make in
//            make.edges.equalTo(view)
//        }
//
//        topView.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.slideFromRight(recognizer:)))
//        topView.addGestureRecognizer(tapGesture)
    }

    @objc func animateOnTap(recognizer: UITapGestureRecognizer) {
        slideDown(recognizer: recognizer)
    }
    
    @objc func animateOnSwipeUp(recognizer: UITapGestureRecognizer) {
        slideDown(recognizer: recognizer)
    }
    
    @objc func animateOnSwipeDown(recognizer: UITapGestureRecognizer) {
        slideUp(recognizer: recognizer)
    }
    
    @objc func animateOnSwipeLeft(recognizer: UITapGestureRecognizer) {
        slideUp(recognizer: recognizer)
    }
    
    @objc func animateOnSwipeRight(recognizer: UITapGestureRecognizer) {
        slideUp(recognizer: recognizer)
    }
    
    @objc func crossDissolve(recognizer: UITapGestureRecognizer) {
        UIView.transition(from: topView, to: bottomView, duration: 0.1, options: .transitionCrossDissolve)
    }
    
    @objc func slideFromRight(recognizer: UITapGestureRecognizer) {
        
        let animatableView = contentImageViews[4-counter]
        
        UIView.animate(withDuration: 0.3) {
            let transform = CGAffineTransform(translationX: -animatableView.frame.width, y: 0)
            animatableView.transform = transform
            self.counter = self.counter+1
        }
    }
    
    @objc func slideUp(recognizer: UITapGestureRecognizer) {
        
        let animatableView = contentImageViews[4-counter]
        
        UIView.animate(withDuration: 0.3) {
            let transform = CGAffineTransform(translationX: 0, y: -animatableView.frame.height)
            animatableView.transform = transform
            self.counter = self.counter+1
        }
    }
    
    @objc func slideDown(recognizer: UITapGestureRecognizer) {
        
        let animatableView = contentImageViews[4-counter]
        
        UIView.animate(withDuration: 0.7) {
            let transform = CGAffineTransform(translationX: 0, y: animatableView.frame.height)
            animatableView.transform = transform
            self.counter = self.counter+1
        }
    }
    
    @objc func flip(recognizer: UITapGestureRecognizer) {
        
        //https://medium.com/@theoben.hassen/ios-animations-coreanimation-part-2-58bb4676710f
        let animation = CABasicAnimation(keyPath: "transform")

        var transform = CATransform3DIdentity
        transform.m34 = -0.002

        animation.toValue = CATransform3DRotate(transform, CGFloat(90 * Double.pi / 180.0), 1, 0, 0)
        animation.duration = 1.25

        topView.layer.add(animation, forKey: "transform")
    }

}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "identifier")
        cell.textLabel?.text = "lalala + \(indexPath.row)"
        return cell
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 49, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
