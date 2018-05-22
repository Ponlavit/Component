
import Foundation
import Base
import RxCocoa
import RxSwift

public class InputTextFieldWithButtonModel : SimpleInputTextFieldModel {

    public var buttonTitle = Variable<String>("")
    public var disbleTitle = Variable<String>("")
    public var isEnable = Variable<Bool>(true)
    public var disableColor = Variable<UIColor>(UIColor.lightGray)
    public var enableColor = Variable<UIColor>(UIColor.red)
    public var onPress: (() -> Void)?
    
    public convenience init(_ name: String!) {
        self.init(withName: name,nibName: "InputTextFieldWithButton")
    }
    
    public func listen(onPress:(()->(Void))!){
        self.onPress = onPress
    }
}

public class InputTextFieldWithButton : SimpleInputTextField {
    @IBOutlet public weak var inlineButton: UIButton?
    
    public override func setupView() {
        self.inlineButton?.setTitle(self.getModel().disbleTitle.value, for: .disabled)
        self.inlineButton?.layer.cornerRadius = 3.0
        super.setupView()
    }
    
    override public func setupAccessibilityId(){
        self.inlineButton?.accessibilityIdentifier =
        "\(getModel().name!).\(self.inlineButton?.accessibilityIdentifier ?? "inlineButton")"
        
        super.setupAccessibilityId()
    }
    
    public override func getModel() -> InputTextFieldWithButtonModel{
        return self.viewModel as! InputTextFieldWithButtonModel
    }
    
    public override func bind() {
        guard let btn = self.inlineButton else {
            super.bind()
            return
        }
        
        btn.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let onPress = self?.getModel().onPress else {
                    print("\(String(describing: type(of: self))) No button action bind")
                    return
                }
                onPress()
            }).disposed(by: bag)
        
        self.getModel().disableColor.asObservable()
            .subscribe(onNext: { [weak self] value in
                if(self?.inlineButton?.isEnabled)! {
                    self?.inlineButton?.backgroundColor = value
                }
            }).disposed(by: bag)
        
        self.getModel().enableColor.asObservable()
            .subscribe(onNext: { [weak self] value in
                if(self?.inlineButton?.isEnabled)! {
                    self?.inlineButton?.backgroundColor = value
                }
            }).disposed(by: bag)
        
        self.getModel().buttonTitle.asObservable()
            .subscribe(onNext: { [weak self] (value) in
                self?.inlineButton?.setTitle(value, for: .normal)
            }).disposed(by: bag)

        self.getModel().disbleTitle.asObservable()
            .subscribe(onNext: { [weak self]  (value) in
                self?.inlineButton?.setTitle(value, for: .disabled)
            }).disposed(by: bag)

        self.getModel().isEnable.asObservable()
            .subscribe(onNext: { [weak self]  (value) in
                self?.inlineButton?.isEnabled = value
                let color = value ?
                    self?.getModel().enableColor.value : self?.getModel().disableColor.value
                self?.inlineButton?.backgroundColor = color
            }).disposed(by: bag)
        
        super.bind()
    }

}
