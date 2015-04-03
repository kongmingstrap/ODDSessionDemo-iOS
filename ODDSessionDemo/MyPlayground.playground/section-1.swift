// Playground - noun: a place where people can play

import Foundation
import UIKit

var str = "Hello, playground"

let name1: String = "takaaki tanaka"
let name2 = "takaaki tanaka"

let borderLine = 30
var score = 65

switch score {
case borderLine..<75:
    println("追試験")
case 90...100:
    println("A")
case 80..<90:
    println("B")
case 70..<80:
    println("C")
case 60..<70:
    println("D")
default:
    println("out")
}

let firstName = "takaaki"
let lastName = "tanaka"
let fullname = firstName + " " + lastName

let n = 8
let result = "\(n)の2乗は\(n*n)です"

func mySwap(inout x: String, inout y: String) {
    let myX = y
    let myY = x
    x = myX
    y = myY
}

var x1 = "x"
var y1 = "y"

mySwap(&x1, &y1)

println(x1 + y1)

func calcValueX(x: Int, andValueY y: Int = 200) -> Int {
    
    func subCalc() {
        println("subCalc")
    }
    subCalc()
    return x + y
}

var x = 100
let num = calcValueX(x)



struct Date {
    var year = 2015
    var month = 4
    var day = 4
    func description() -> String {
        return "\(year)\(month)\(day)"
    }
}

var date = Date()
println(date.description())

let domain = "i3-systems"
let d = NSString(string: domain)
let len = d.length

let gu: Character = "グ"
let kud: Character = "ク\u{3099}"

let gu_kud = "\(gu)-\(kud)"

println(gu_kud.utf16Count)
println(countElements(gu_kud))
println(gu == kud)

let arr1: Array<Int> = [1, 2, 3, 4, 5]
let arr2: [Int] = [1, 2, 3, 4, 5]

var num1 = arr2[2]
num1 = num1 + 1
arr2[2]

let dic1: Dictionary<String, Int> = ["key1": 100, "key2": 200, "key3": 300]
let dic2: [String : Int] = ["key1": 100, "key2": 200, "key3": 300]

let key2 = dic2["key2"]

dic2
