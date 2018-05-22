
import Foundation
import Base
import RxCocoa
import RxSwift

public class SimpleInputTextFieldModel : ComponentViewModel {
    public var placeHolder = Variable<String>("")
    public var input = Variable<String>("")
    public var isSecure = Variable<Bool>(false)
    public var title = Variable<String>("")
    public var isVisible = Variable<Bool>(true)
    public var keyboardType = Variable<UIKeyboardType>(UIKeyboardType.default)
    public var font = Variable<UIFont>(UIFont.systemFont(ofSize: UIFont.systemFontSize))
    public var maxLength = Variable<Int>(0)
    public var autoCorrection = Variable<Bool>(false)
    
    public convenience init(_ name: String!) {
        self.init(withName: name,nibName: "SimpleInputTextField")
    }
    
    public func setOnInputChangeListener(reciever: ((String)->Void)?, disposedBy: DisposeBag){
        self.input.asObservable()
            .subscribe(onNext: reciever)
            .disposed(by: disposedBy)
    }
}

public class SimpleInputTextField : BaseView {
    @IBOutlet public weak var textField : UITextField?
    @IBOutlet public weak var titleField : UILabel?
    
    var bag = DisposeBag()
    
    public override func setupView() {
        super.setupView()
    }
    
    public override func setupAccessibilityId() {
        self.textField?.accessibilityIdentifier =
        "\(getModel().name!).\(self.textField?.accessibilityIdentifier ?? "textField")"
        self.titleField?.accessibilityIdentifier =
        "\(getModel().name!).\(self.titleField?.accessibilityIdentifier ?? "titleField")"
        super.setupAccessibilityId()
    }
    
    public override func getPercentWidth() -> CGFloat {
        return getModel().percentWidth.value
    }
    
    public override func getModel() -> SimpleInputTextFieldModel{
        return self.viewModel as! SimpleInputTextFieldModel
    }
    
    public override func bind() {
        textField?.rx.text.asObservable()
            .subscribe(onNext: { [weak self] (value) in
                self?.getModel().input.value = value!
            })
        .disposed(by: bag)
        
        self.getModel().keyboardType.asObservable()
            .subscribe(onNext:{ [weak self] value in
                self?.textField?.keyboardType = value
            })
        .disposed(by: bag)
        
        self.getModel().isVisible.asObservable()
            .subscribe(onNext:{ [weak self] value in
                self?.isHidden = !value
            })
        .disposed(by: bag)

        self.getModel().title.asObservable()
            .subscribe(onNext:{ [weak self] (value) in
                self?.titleField?.text = value
            })
        .disposed(by: bag)
        
        self.getModel().autoCorrection.asObservable()
            .subscribe(onNext:{ [weak self] value in
                self?.textField?.autocorrectionType = value ? UITextAutocorrectionType.default:UITextAutocorrectionType.no
            })
        .disposed(by: bag)
        
        self.getModel().placeHolder.asObservable()
            .subscribe(onNext: { [weak self] (value) in
                self?.textField?.placeholder = value
            })
        .disposed(by: bag)
        
        self.getModel().isSecure.asObservable()
            .subscribe(onNext: { [weak self] (value) in
                self?.textField?.isSecureTextEntry = value
                
                // To fix the problem with white space trailing
                let tmpString = self?.textField?.text;
                self?.textField?.text = " ";
                self?.textField?.text = tmpString;
            })
        .disposed(by: bag)
        
        self.getModel().input.asObservable()
            .subscribe(onNext: {[weak self] value in
                if(self?.getModel().maxLength.value != 0) {
                    guard let max = self?.getModel().maxLength.value else { return }
                    let newValue = String(value.prefix(max))
                    self?.textField?.text = newValue
                    if(value != newValue) {
                        self?.getModel().input.value = String(value.prefix(max))
                    }
                }
                else {
                    self?.textField?.text = value
                }
            })
        .disposed(by: bag)
        
        self.getModel().font.asObservable()
            .subscribe(onNext: {[weak self] value in
                self?.titleField?.font = value
                self?.textField?.font = value
            })
        .disposed(by: bag)
        
        super.bind()
    }

}
