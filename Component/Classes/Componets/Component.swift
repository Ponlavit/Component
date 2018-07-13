//
//  BaseView.swift
//  Base
//
//  Created by Ponlavit Larpeampaisarl on 4/26/18.
//

import Foundation
import Base
import RxSwift
import RxCocoa

open class ComponentViewModel : BaseViewModel {
    open var percentWidth = Variable<CGFloat>(100)
    open var height = Variable<CGFloat>(30)
    
    override open func getNib() -> UINib {
        let bundle = Bundle(for: ComponentViewModel.self)
        return UINib(nibName: self.getNibName()!, bundle: bundle)
    }
    
    open override func getView<T>() -> T where T : BaseView {
        let view : T = super.getView()
        _ = self.height.asObservable()
            .subscribe(onNext: { value in
               view.frame = CGRect(origin: view.frame.origin,
                                   size: CGSize(width: view.frame.size.width , height: value))
            })
        _ = self.percentWidth.asObservable()
            .subscribe(onNext: { value in
                view.frame = CGRect(origin: view.frame.origin,
                                    size: CGSize(width: (value/100)*UIScreen.main.bounds.width ,
                                                 height: view.frame.size.height))
            })
        return view
    }
}

