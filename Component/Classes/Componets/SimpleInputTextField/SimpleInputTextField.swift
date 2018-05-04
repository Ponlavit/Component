
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
    @IBOutlet weak var textField : UITextField?
    @IBOutlet weak var titleField : UILabel?
    
    var bag = DisposeBag()
    
    public override func setupView() {
        super.setupView()
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
        
        super.bind()
    }

}
