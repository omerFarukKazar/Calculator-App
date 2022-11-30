//
//  ViewController.swift
//  Calculator
//
//  Created by Ömer Faruk Kazar on 18.11.2022.
//

import UIKit

enum BasicOperator: Int { // Enum to cover all operators for basic calculator mode ( portrait mode )
    case clear = 1, plusMinus, percentage, division, multiplication, subtraction, addition, equal, dot
    // enum conforms the Int protocol in order to match each case to it's button tag.
}

/* Butonlardan gelen sender.tag'lere göre switch case yazıp belirlemem ya da iç içe enum kullanmam gerekiyordu? Raw Value ile ilerlemek daha mantıklı geldi.
 enum NewOperators {
 case multiplication(String)
 case addition(String)
 }

enum CalculatorError: Error {
    case missingOperationComponents
}
*/

final class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var currentOperationLabel: UILabel!
    @IBOutlet weak var previousOperationLabel: UILabel!
    
    // MARK: - Properties
    private var result: Double = .zero
    private let operators = ["", "", "-", "%", "/", "*", "-", "+"] // Idk if this is okay.
    private let operatorSet = CharacterSet(["%", "*", "/", "+", "-"])
    
    /*
     private var displayValue: String? {  get set ile yapmayı denedim ancak displayLabel'in text'ini herhangi bir şey append etmeden değiştirmek ya da farklı durumlarda farklı aksiyonlar almak için set içerisine farklı case'ler tanımlamak gerekiyordu. O yüzden computed property değil de direkt olarak variable kullandım.
    
            get {
                displayLabel.text
            }
            set {
                if displayLabel.text == "0" {
                    displayLabel.text = newValue
                } else {
                    displayLabel.text?.append(newValue ?? "")
                }
            }
        }
    
        private var display: String = "0" {
            didSet {
                currentNumberLabel.text = display
            }
        }
    */
    
    //MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func digitButtonTapped(_ sender: UIButton) { // Rakam butonlarında tüm rakamlar için aynı fonksiyonalite gerçekleştirileceği ve hepsinde değişen parametre ortak olduğu için ( number ) Tek bir IBAction üzerinden yönetmek sorun olmadı.
        guard let number = sender.titleLabel?.text else { return }
        if currentOperationLabel.text != "0" {
            currentOperationLabel.text?.append(number)
        } else {
            currentOperationLabel.text = number
        }
    }
    
    @IBAction func operatorButtonTapped(_ sender: UIButton) {
        // Her ayrı fonksiyonu tek bir Interface Builder Action fonksiyonu içerisinde tanımlayıp, button tag'ini belirlediğim operator tag'lerine eşitleyerek daha kısa kod ve daha az fonksiyon ile efektif bir yapı kurabileceğimi düşündüm. Ancak switch case yapıları içerisinde hem tekrara düştüm hem de fonksiyon kullanmanın okunabilirliğini arttıracağını düşündüm.
        
        // Bu sefer dört işlem hariç her bir case'ye ayrı fonksiyon yazmak ve bir çok kontrol mekanizması kullanmak zorunda kaldım. Sonuç olarak her butona ayrı ayrı IBAction atamaktansa, hepsini tek bir IBAction'a bağlayıp oradan yönetmenin eğer fonksiyonda değişen parametreler ortak değilse mantıksız olduğunu düşünüyorum çünkü case'lere yazdığım birden farklı fonksiyonlarla zaten her butona ayrı IBAction tanımlamak gibi bi şey oldu :D.
        
        guard var currentOperation = currentOperationLabel.text else { return }
        
        let operatorTapped = BasicOperator(rawValue: sender.tag)
        currentOperationLabel.text = "0"
        
        switch operatorTapped { // Switch the corresponding enum to tappedButton.
        case .clear:
            clear(&currentOperation)
        case .plusMinus:
            plusMinus(&currentOperation)
        case .percentage:
            print("percentage tapped")
            extraOperator(&currentOperation, tapped: operators[BasicOperator.percentage.rawValue])
        case .division:
            extraOperator(&currentOperation, tapped: operators[BasicOperator.division.rawValue])
            print("division tapped")
        case .multiplication:
            print("mul tapped")
            extraOperator(&currentOperation, tapped: operators[BasicOperator.multiplication.rawValue])
        case .subtraction:
            print("sub tapped")
            extraOperator(&currentOperation, tapped: operators[BasicOperator.subtraction.rawValue])
        case .addition:
            print("add tapped")
            extraOperator(&currentOperation, tapped: operators[BasicOperator.addition.rawValue])
        case .equal:
            previousOperationLabel.text = currentOperation
            currentOperation = calculate(currentOperation)
        case .dot:
            dot(&currentOperation)
        case .none:
            currentOperation = "Error. Please press C"
            print("Error.")
        }
        currentOperationLabel.text = currentOperation
    }
    
    // MARK: - Methods
    
    /**
     When called, this method takes String input, seperates each element inside of it into an array, does necessary actions and returns result as String
     
     - parameter operation: is a String that represents a mathematical operation.
     - returns: The result of mathematical operation as String
     */
    
    private func calculate(_ operation: String) -> String {
        let operationComponents = operation.components(separatedBy: " ") //operationComponents array
        guard operationComponents.count == 3,
              let firstNumber = Double(operationComponents[0]),
              let secondNumber = Double(operationComponents[2]) else { return "Error, please press C"}
        
        // Switch to do operation corresponds to the current operator
        switch operationComponents[1] {
        case "%":
            result = firstNumber * secondNumber / 100
        case "+":
            result = firstNumber + secondNumber
        case "*":
            result = firstNumber * secondNumber
        case "-":
            result = firstNumber - secondNumber
        case "/":
            result = firstNumber / secondNumber
        default:
            result = 0
        }
        return (String(result))
    }
    
    /**
     Handles if user pressed operator button more than once in a single operation.
     
     checks if currentOperation contains one of the elements from operatorSet. And checks for the last character of currentOperation parameter.
     
     - parameters:
        - currentOperation: is a String that represents a mathematical operation.
        - tapped: Operator sign of the tapped button.
     */
    
    private func extraOperator(_ currentOperation: inout String, tapped: String) {
        if let lastChar = currentOperation.last{
            if currentOperation.rangeOfCharacter(from: operatorSet) != nil && lastChar.isNumber {
                previousOperationLabel.text = currentOperation
                currentOperation = calculate(currentOperation) + " \(tapped) "
            } else if currentOperation.rangeOfCharacter(from: operatorSet) != nil && !lastChar.isNumber {
                currentOperation.removeLast(3)
                currentOperation.append(" \(tapped) ")
            }
            else {
                currentOperation.append(" \(tapped) ")
            }
        }
    }
    
    /**
     Handles the plus / minus sign at the beginning of input parameter.
     */
    
    private func plusMinus(_ currentOperation: inout String) {
        if currentOperation.first != "-" {
            currentOperation = operators[BasicOperator.plusMinus.rawValue] + currentOperation
        } else {
            currentOperation.removeFirst()
        }
    }
    
    /**
    Clears All
     */
    
    private func clear(_ currentOperation: inout String) {
        currentOperation = "0"
        previousOperationLabel.text = "0"
        result = .zero
    }
    
    /**
    Appends dot at the given String.
     */
    
    private func dot(_ currentOperation: inout String) {
        if currentOperation.last == "."{
            currentOperation.removeLast()
        } else {
            currentOperation.append(".")
        }
    }
}
