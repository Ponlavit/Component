//
//  BaseView.swift
//  Base
//
//  Created by Ponlavit Larpeampaisarl on 4/26/18.
//

import Foundation
import Base
import RxSwift

open class ComponentViewModel : BaseViewModel {
    open var percentWidth = Variable<CGFloat>(100)
    open var height = Variable<CGFloat>(30)
    
    override open func getNib() -> UINib {
        let bundle = Bundle(for: ComponentViewModel.self)
        return UINib(nibName: self.getNibName()!, bundle: bundle)
    }
}

