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

open class BaseTableViewCellModel : ComponentViewModel {
    public var cellView : BaseTableViewCell?
    
    open func getCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.default
    }
    
    public var didSelectedRow : ((_ model:BaseTableViewCellModel) -> Swift.Void)?
    public func getCellView() -> BaseTableViewCell {
        var cell: BaseTableViewCell?
        if(self.cellView == nil) {
            cell = (self.getNibView() as! BaseTableViewCell)
            self.cellView = cell
        }
        else {
            return self.cellView!
        }

        cell?.viewModel = self
        return cell!
    }
}


public class BaseTableAdapter : NSObject, UITableViewDelegate, UITableViewDataSource{
    let bag = DisposeBag()
    public let varDs :Variable<[BaseTableViewCellModel]> = Variable([])
    public var dataSource : [BaseTableViewCellModel] {
        return varDs.value
    }
    
    public func reload(){
        self.baseTableView?.tableView?.reloadData()
    }
    
    public var baseTableView : BaseTableView?
    public convenience init(withDataSource: [BaseTableViewCellModel]) {
        self.init()
        self.varDs.value = withDataSource
        varDs.asObservable()
            .subscribe(onNext: { [unowned self] value in
                self.baseTableView?.tableView?.reloadData()
            }).disposed(by: self.bag)
    }
    
    public func replaceSource(withNewSource newSource:[BaseTableViewCellModel]){
        self.varDs.value.removeAll()
        self.varDs.value = newSource
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("rendering \(self.dataSource.count) row")
        return self.dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let model = dataSource[row]
        let width = tableView.frame.size.width
        return model.getCellView().getHeighByRatio(width)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let model = dataSource[row]
        print("will render cell at \(row) with model \(model)")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let model = dataSource[row]
        print("rendering cell at \(row) with model \(model)")
        var cell : BaseTableViewCell? = tableView.dequeueReusableCell(withIdentifier: model.getNibName()!) as! BaseTableViewCell?
        if(cell == nil){
            cell = model.getCellView()
            cell?.bind()
        }
        cell?.selectionStyle = model.getCellSelectionStyle()
        cell?.viewModel = model
        cell?.setupView()
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let model = dataSource[row]
        if(model.didSelectedRow != nil) {
            model.didSelectedRow!(model)
        }
    }
}

public class BaseTableViewModel : ComponentViewModel {
    public var adapter : BaseTableAdapter!
    public private(set) var tableView : UITableView!
    
    public convenience init(_ name:String!, style:UITableViewStyle? = UITableViewStyle.plain,
                            onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil){
        self.init(name, withAdapter: BaseTableAdapter(),style:style)
    }
    
    public convenience init(_ name:String!,
                            withAdapter adapter:BaseTableAdapter,
                            style:UITableViewStyle? = UITableViewStyle.plain,
                            onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil){
        self.init(withName: name, nibName: "")
        self.adapter = adapter
        self.adapter.baseTableView = self.getBaseView()
        self.tableView = self.getBaseView().initTable(style: style!,onRefresh:onRefresh)
        self.tableView.delegate = adapter
        self.tableView.dataSource = adapter
        self.registerCellBundle()
        self.tableView.reloadData()
    }
    
    private func getBaseView() -> BaseTableView{
        let vi:BaseTableView = self.getView()
        return vi
    }
    
    override public func getView<T>() -> T where T : BaseTableView {
        let vi:BaseTableView = super.getView()
        return vi as! T
    }
    
    func registerCellBundle(){
        for model:BaseTableViewCellModel in self.adapter.dataSource {
            model.getCellView().registerOn(table: self.tableView)
        }
    }
}

public class BaseTableView : BaseView {
    public private(set) var tableView : UITableView?
    public var onRefresh : ((_ sender:UIRefreshControl) -> Swift.Void)?
    public override func setupView() {
        super.setupView()
        guard let tv = self.tableView else { return }
        tv.removeFromSuperview()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.frame = self.bounds
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.addSubview(tv)
    }
    
    @objc func onTriggerRefresh(sender:UIRefreshControl){
        if(self.onRefresh != nil) {
            self.onRefresh!(sender)
            defer {
                if #available(iOS 10.0, *) {
                    self.tableView?.refreshControl?.beginRefreshing()
                }
            }
        }
        
    }
    
    public func initTable(style:UITableViewStyle,
                          onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil) -> UITableView!{
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.onRefresh = onRefresh
        if #available(iOS 10.0, *) {
            if(onRefresh != nil){
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self,
                                         action: #selector(self.onTriggerRefresh(sender:)),
                                         for: UIControlEvents.valueChanged)
                
                self.tableView?.refreshControl = refreshControl
            }
        }
        return self.tableView
    }
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    public override func getModel() -> BaseTableViewModel{
        return self.viewModel as! BaseTableViewModel
    }
}


open class BaseTableViewCell : UITableViewCell, BaseViewLC {
    public var viewModel : BaseViewModel!
    public var tabGesture : UITapGestureRecognizer?

    open func setupView() {
        if(self.getModel().onSetupView != nil) {
            self.getModel().onSetupView!(self)
        }
        tabGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(self.tabGesture!)
    }
    
    open func bind() {
        // do some rx to change sepecific value
    }
    
    @objc func didTap(){
        print("🎯 did tap on cell \(self.getModel().name)")
        if let action = self.getModel().didSelectedRow {
            action(self.getModel())
        }
    }
    
    public func registerOn(table:UITableView){
        guard let name = self.getModel().getNibName() else {
            fatalError("Nibname should not be nil")
        }
        guard name == self.reuseIdentifier else {
            fatalError("Nibname and reuse id should be the same")
        }
        print("Register Cell \(name)")
        table.register(self.getModel().getNib(),
                       forCellReuseIdentifier: name)
    }
    
    open func getWHRatio() -> CGFloat {
        return 1
    }
    
    public func getHeighByRatio(_ width:CGFloat) -> CGFloat {
        return self.getWHRatio() * width
    }
    
    open func setupAccessibilityId() {
        self.accessibilityIdentifier = getModel().name
    }
    open func getModel() -> BaseTableViewCellModel {
        return self.viewModel as! BaseTableViewCellModel
    }
}
