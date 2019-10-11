//
//  Animations.swift
//  Organizer
//
//  Created by Вадим on 17/09/2019.
//  Copyright © 2019 Вадим. All rights reserved.
//

import UIKit

//MARK: Анимация трясущегося UILabel

func shakeAnimation (viewToShake: UILabel) {
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
    
    viewToShake.layer.add(animation, forKey: "position")
}

//MARK: Визуальный эффект при ошибке

func errorScreen(view: UIView) {
    UIView.animate(withDuration: 0.6, delay: 0.0, animations: {
        view.backgroundColor = UIColor(red:0.65, green:0.00, blue:0.00, alpha:0.5)
        view.backgroundColor = UIColor.black
    })
}

//MARK: Выделение при выборе операций в калькуляторе

func selectOperationButton(pressedButton: UIButton){
    pressedButton.titleLabel?.font = .systemFont(ofSize: 36, weight: .light)
    pressedButton.setTitleColor(.white, for: .normal)
}

//MARK: Убрать выделение с клавиш операций в калькуляторе

func unselectAllOperationButtons(otherButtons: Array<UIButton>) {
    for button in otherButtons {
        button.titleLabel?.font = .systemFont(ofSize: 36, weight: .ultraLight)
        button.setTitleColor(.black, for: .normal)
    }
}

//MARK: Плавное изменение ограничений

func animateConstraint (constraint: NSLayoutConstraint, to value: CGFloat, layout: UIViewController) {
    UIView.animate(withDuration: 0.2) {
        constraint.constant = value
        layout.view.layoutIfNeeded()
    }
}
