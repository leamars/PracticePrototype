//
//  LessonStep.swift
//  PracticePrototype
//
//  Created by Lea Marolt Sonnenschein on 26/11/2023.
//

import Foundation

struct LessonStep: Codable {
    // the FIRST image is always the one to show FIRST, and the rest of them are variable "answers"
    var type: StepType
    var content: Content?
    var solvable: Problem?
    var playable: Playable?
    var lwc: LWC?
}

struct Content: Codable {
    var images: [String]
    var height: CGFloat
}

struct Playable: Codable {
    var images: [String]
    var height: CGFloat
}

struct LWC: Codable {
    var images: [String]
    var height: CGFloat
}

enum StepType: String, Codable {
    case content = "content"
    case solvable = "solvable"
    case playable = "playable"
    case lwc = "lwc"
}

