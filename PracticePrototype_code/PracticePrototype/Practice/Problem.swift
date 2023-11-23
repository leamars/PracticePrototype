//
//  PracticeSet.swift
//  ContentAnimationUIKit
//
//  Created by Lea Marolt Sonnenschein on 03/08/2023.
//

import Foundation

struct Problem: Codable {
    var question: String
    var type: ProblemType
    var diagrammar: Diagrammar
    var answers: [Answer]
    var explanation: [ExplanationStep]
}

struct Diagrammar: Codable {
    var image: String
    var caption: String
}

struct Answer: Codable {
    var title: String
    var correct: Bool
    var isSelected: Bool
}

struct ExplanationStep: Codable {
    var image: String
    var description: String
}

enum ProblemType: String, Codable {
    case mcq = "mcq"
    case diagrammar = "diagrammar"
    case envelope = "envelope"
    case simson = "simson"
}
