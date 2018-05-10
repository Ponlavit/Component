
import Foundation
import Base
import RxCocoa
import RxSwift


public class QRViewViewModel: ComponentViewModel {
    public var code = Variable<String>("www.google.com")
    public var isHideWhenChange : Bool = false
    public convenience init(_ name: String!) {
        self.init(withName: name,nibName: "QRView")
    }
}

public class QRView : BaseView {
    @IBOutlet weak var qrView : UIImageView?
    
    let bag = DisposeBag()
    
    public override func setupView() {
        super.setupView()
    }

    public override func getModel() -> QRViewViewModel{
        return self.viewModel as! QRViewViewModel
    }
    
    public override func getPercentWidth() -> CGFloat {
        return self.getModel().percentWidth.value
    }
    
    public override func setupAccessibilityId() {
        self.qrView?.accessibilityIdentifier =
        "\(getModel().name!).\(self.qrView?.accessibilityIdentifier ?? "button")"
        super.setupAccessibilityId()
    }
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func generateQRCode(from string:String) -> UIImage? {
        guard let imgView = self.qrView else { return nil }
        let data =  string.data(using: String.Encoding.isoLatin1)
        if let filter = CIFilter(name:"CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let size = max(imgView.frame.width, imgView.frame.height)
            let transform = CGAffineTransform(scaleX: size, y: size)
            if let output = filter.outputImage?.transformed(by: transform) {
                return self.convert(cmage: output)
            }
        }
        return nil
    }
    
    public override func bind() {
        
        self.getModel().code.asObservable()
            .subscribe(onNext: { [unowned self] value in
                self.qrView?.isHidden = self.getModel().isHideWhenChange
                let qr = self.generateQRCode(from: value)
                DispatchQueue.main.async {
                    self.qrView?.image = qr
                    self.qrView?.isHidden = false
                }
            })
        .disposed(by: bag)
        
        super.bind()
    }
}
