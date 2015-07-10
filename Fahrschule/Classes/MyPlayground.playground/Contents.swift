//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


struct QuestionSheetType : RawOptionSetType, BooleanType {
    private var value: UInt
    init(_ rawValue: UInt) { self.value = rawValue }
    
    // _RawOptionSetType
    init(rawValue: UInt) { self.value = rawValue }
    
    // NilLiteralConvertible
    init(nilLiteral: ()) { self.value = 0}
    
    // RawRepresentable
    var rawValue: UInt { return self.value }
    
    // BooleanType
    var boolValue: Bool { return self.value != 0 }
    
    // BitwiseOperationsType
    static var allZeros: QuestionSheetType { return self(0) }
    
    // User defined bit values
    static var Learning: QuestionSheetType   { return self(0) }
    static var Exam: QuestionSheetType  { return self(1 << 0) }
    static var History: QuestionSheetType   { return self(1 << 1) }
}


println("Learning \(QuestionSheetType.Learning.rawValue)")
println("Exam \(QuestionSheetType.Exam.rawValue)")
println("History \(QuestionSheetType.History.rawValue)")

func printType(type: QuestionSheetType)->String {
    switch type {
    case QuestionSheetType.Learning:
        return "Learning"
    case QuestionSheetType.Exam:
        return "Exam"
    case QuestionSheetType.History:
        return "History"
    default:
        return "EMPTY"
    }
}

var val: QuestionSheetType = .Exam | .History
val = QuestionSheetType( val.rawValue - QuestionSheetType.History.rawValue)
printType(val)
printType(.History & val)

val = .Exam
printType(val)

val = QuestionSheetType( val.rawValue + QuestionSheetType.History.rawValue)
printType(val)




val = .Exam | .History
printType(val & .History)

val = .Exam | .History
printType(val | .History)



