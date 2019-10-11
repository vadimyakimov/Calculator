//
//  Calculator.swift
//  Organizer
//
//  Created by Вадим on 17/09/2019.
//  Copyright © 2019 Вадим. All rights reserved.
//

import UIKit
import SafariServices

class CalculatorViewController: UIViewController {
    
    //MARK: Переменные
    
    var operation = 0            //Номер операции
    var newNumber = true         //Проверка на ввод нового числа
    var equalWasPressed = true   /* Проверка на нажатие знака равно (при запуске поведение
                                    калькулятора эквивалентно поведению после нажатия равно) */
    var preResult:Double = 0     /* Переменная для предварительного сохранения результата
                                    на случай, если пользователь изменит операцию */
    var result:Double = 0        /* Главная переменная для сохранения результата */
    var isError = false          // Для проверки на ошибку
    var allClear = true          /* Если false - кнопка очищения удалит только введённое число на экран,
                                    true - очистит все предыдущие результаты и операции */
    var floatDot = false         // Наличие плавающей запятой, чтоб нельзя было поставить вторую
    var isPercent = false        // Наличие знака процента, чтоб нельзя было поставить второй
    
    
    @IBOutlet weak var buttonPlus: UIButton!                        // Кнопка операции "плюс"
    @IBOutlet weak var buttonMinus: UIButton!                       // Кнопка операции "минус"
    @IBOutlet weak var buttonMultiply: UIButton!                    // Кнопка операции "умножить"
    @IBOutlet weak var buttonDevision: UIButton!                    // Кнопка операции "поделить"
    lazy var operationButtons:[UIButton] =                          // Массив всех кнопок операций
        [buttonPlus, buttonMinus, buttonMultiply, buttonDevision]   // для снятия выделения со всех сразу
                                                                        
    
    @IBOutlet weak var clean: UIButton! // Кнопка "очистить"
    
    @IBOutlet weak var screen: UILabel!              // Главный экран
    @IBOutlet weak var screenHistory: UILabel!       // Экран истории
    @IBOutlet weak var scrollHistory: UIScrollView!  // UIScrollView для прокрутки экрана истории
    
    @IBOutlet weak var placeholderHeight: NSLayoutConstraint!  /* Высота placeholder'а для того, чтоб последние действия
                                                                  в истории всегда была над главным экраном */
    
    
    //MARK: Состояние
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.statusBarBackgroundColor = .clear
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        adjustPlaceholder()
    }
    
    //MARK: светлый статус бар
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        let myCV = SFSafariViewController(url: URL(string: "https://telegra.ph/Junior-iOS-razrabotchik-10-09")!)
        present(myCV, animated: true, completion: nil)
    }
    
    //MARK: Нажатие цифр
    
    @IBAction func onClickDigits(_ sender: UIButton) {
        let pressedDigit = String(sender.title(for: .normal)!)
        //-------------
        if (pressedDigit == "," && (screen.text == "" || screen.text!.count > 8)) // Запрет на ввод запятой на пустом или переполненном экране
            || screen.text!.count > 8 && !newNumber                               /* Запрет на ввод любых ццифр, если экран переполнен,
                                                                                     если это не новое число (старое остаётся на экране,
                                                                                     пока не начнут вводить новое */
            || (pressedDigit == "0" && screen.text == "") {                       // Запрет на нажатие нуля на пустом экране
            shakeAnimation(viewToShake: screen)
            errorScreen(view: self.view)
            return;
        }
        //-------------
        if operation != 0 && newNumber {
            if equalWasPressed {                            /* Вводится второе число, т.к. пользователь уже выбрал операцию,
                                                               но до этого было нажато "равно" */
                screenHistory.text = screen.text
                result = (screen.text! as NSString).doubleValue
                equalWasPressed = false
            } else {                                        // Вводится третье или больше число
                screenHistory.text! += screen.text!
                result = preResult
            }
            switch operation {                              /* Если число новое, то после нажатия на кнопку операции
                                                               знак операции также переходит в историю */
            case 1:
                screenHistory.text! += "+"
            case 2:
                screenHistory.text! += "-"
            case 3:
                screenHistory.text! += "×"
            case 4:
                screenHistory.text! += "÷"
            default:
                return
            }
            adjustPlaceholder()
            unselectAllOperationButtons(otherButtons: operationButtons)
        }
        //-------------
        if pressedDigit == "," {     // Проверка на наличие плавающей точки
            if !floatDot {
                screen.text! += "."
                floatDot = true
            } else {
                shakeAnimation(viewToShake: screen)
                errorScreen(view: self.view)
            }
            return
        }
        //-------------
        if newNumber {
            if equalWasPressed {
                screenHistory.text = screen.text
                adjustPlaceholder()
            }
            screen.text = pressedDigit
            newNumber = false            
            floatDot = false
        } else {
            screen.text! += pressedDigit
        }
        //-------------
        if allClear {
            allClearOff()
        }
    }
    
    //MARK: Нажатие кнопок вычисления
    
    @IBAction func onClickOperations(_ sender: UIButton) {
        if !newNumber || (equalWasPressed && !screen.text!.isEmpty) {     /* Запрет на нажатие клавииш операции, если экран пустой.
                                                                             Исключение - было нажато "равно". Во избежание возможности
                                                                             нажатия после запуска (т.к. equalWasPressed = true),
                                                                             экран не должен быть пустой */
            allClearOn()
            let pressedButton = sender.tag
            unselectAllOperationButtons(otherButtons: operationButtons)
            selectOperationButton(pressedButton: sender)
            if isError {
                errorZero()
            }
            if !equalWasPressed {                                         /* Случай с нажатием "равно" определён в IBAction для "равно".
                                                                             Эта проверка нужна для предварительного вычесления. Там же
                                                                             вычисление происходит сразу */
                preResult = calc(leftNumber: result, rightNumber: (screen.text! as NSString).doubleValue)
            }
            switch pressedButton {
            case 1: // плюс
                operation = 1
            case 2: // минус
                operation = 2
            case 3: // умножить
                operation = 3
            case 4: // делить
                operation = 4
            default:
                operation = 0
            }
            newNumber = true
        }
    }
    
    //MARK: Нажатие процента
    
    @IBAction func percent(_ sender: Any) {
        if !isPercent && !equalWasPressed && !newNumber {
            isPercent = true
            screen.text! += "%"
        } else {
            shakeAnimation(viewToShake: screen)
            errorScreen(view: self.view)
        }
    }
    
    //MARK: Нажатие равно
    
    @IBAction func calculation(_ sender: Any) {
        if !equalWasPressed {
            screenHistory.text! += screen.text! + "="
            adjustPlaceholder()
            result = calc(leftNumber: result, rightNumber: (screen.text! as NSString).doubleValue)
            if isError {
                errorZero()
                return
            }
            outputOnMainScreen(number: result)
        }
        equalWasPressed = true
        allClearOn()
    }
    
    //MARK: Вычисление
    
    func calc (leftNumber: Double, rightNumber: Double) -> Double {
        newNumber = true
        let caseOperation = operation
        operation = 0
        var calcResult: Double
        if isPercent {                 // Отдельный вычислитель для операций с процентами...
            isPercent = false
            let percent = rightNumber / 100
            switch caseOperation {
            case 1:
                calcResult = leftNumber + (leftNumber * percent)
            case 2:
                calcResult = leftNumber - (leftNumber * percent)
            case 3:
                calcResult = leftNumber * percent
            case 4:
                if (percent != 0) {
                    calcResult = leftNumber / percent
                } else {
                    isError = true
                    calcResult = 0
                }
            default:
                calcResult = 0
            }
        } else {                       // ...и операций без процентов
            switch caseOperation {
            case 1:
                calcResult = leftNumber + rightNumber
            case 2:
                calcResult = leftNumber - rightNumber
            case 3:
                calcResult = leftNumber * rightNumber
            case 4:
                if (rightNumber != 0) {
                    calcResult = leftNumber / rightNumber
                } else {
                    isError = true
                    calcResult = 0
                }
            default:
                calcResult = 0
            }
        }
        if calcResult < Double(Int.max) {  // Результат не должен превышать максимально допустимого значения в Double
            return calcResult
        } else {
            isError = true
            return 0
        }
    }
    
    //MARK: Error / 0
    
    func errorZero() {                            // Обработчик ошибки. Сброс к начальным параметрам
        shakeAnimation(viewToShake: screen)
        errorScreen(view: self.view)
        isError = false
        allClear = true
        clean(clean)
        screen.text = "Error"
    }
    
    //MARK: Нажание очистки
    
    @IBAction func clean(_ sender: UIButton) {  // Если allClear = true, сброс к начальным параметрам
        if allClear  {
            operation = 0
            newNumber = true
            equalWasPressed = true
            preResult = 0
            result = 0
            isError = false
            screenHistory.text = ""
            adjustPlaceholder()
        }
        screen.text = ""
        allClear = true
        sender.setTitle("AC", for: .normal)
        floatDot = false
    }
    
    func allClearOff () {                       // Выключатель allClear
        allClear = false
        clean.setTitle("C", for: .normal)
    }
    
    func allClearOn () {                        // Выключатель allClear
        allClear = true
        clean.setTitle("AC", for: .normal)
    }
    
    //MARK: Плюс-минус
    
    @IBAction func plusMinus(_ sender: Any) {
        let toggle = (screen.text! as NSString).doubleValue * -1
        outputOnMainScreen(number: toggle)
    }
    
    //MARK: Проверка на необходимость плавающей запятой
    
    func outputOnMainScreen (number: Double) {  /* Если результатом является целое число, выводит на экран
                                                  число без запятой, т.к. в ней нет необходимости */
        let intNumber = Int(number)
        if number - Double(intNumber) == 0 {
            screen.text = String(intNumber)
        } else {
            screen.text = String(number)
        }
    }
    
    //MARK: Подстраивание размера placeholder
    
    func adjustPlaceholder () {
        screenHistory.sizeToFit()
        let height = scrollHistory.bounds.size.height - screenHistory.bounds.size.height
        if height >= 0 {
            placeholderHeight.constant = height
        } else {
            placeholderHeight.constant = 0
            let bottomOffset = CGPoint(x: 0, y: -height)
            scrollHistory.layoutIfNeeded()
            scrollHistory.setContentOffset(bottomOffset, animated: false)
        }
        
    }
    
}

