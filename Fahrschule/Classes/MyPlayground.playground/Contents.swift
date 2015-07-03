//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let numberFormmater = NSNumberFormatter()
numberFormmater.numberStyle = .DecimalStyle
numberFormmater.locale = NSLocale(localeIdentifier: "de")
numberFormmater.roundingMode = .RoundHalfUp
numberFormmater.minimumFractionDigits = 0
numberFormmater.roundingIncrement = 0
numberFormmater.generatesDecimalNumbers = false

let num = NSNumber(float: 12345.4)

print(numberFormmater.stringFromNumber(num))

let lengthFormatter = NSLengthFormatter()
//println(@"Kilometer: %@", lengthFormatter.stringFromValue(1000, unit: .Kilometer))   //Kilometer: 1,000 km
//println(" \(lengthFormatter.stringFromValue(1000, unit: .Millimeter)") //Millimeter: 1,000 mm

print(lengthFormatter.stringFromValue(1000.501, unit: .Meter))


print(lengthFormatter.stringFromMeters(100.51))

lengthFormatter.numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
lengthFormatter.numberFormatter.maximumFractionDigits = 0

print(lengthFormatter.stringFromMeters(10.6))

print(lengthFormatter.stringFromMeters(50.51))
