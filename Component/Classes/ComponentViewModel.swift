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
    public var percentWidth = Variable<CGFloat>(100)
    override open func getNib() -> BaseView {
        let bundle = Bundle(for: ComponentViewModel.self)
        return UINib(nibName: self.getNibName()!, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! BaseView
    }
}

