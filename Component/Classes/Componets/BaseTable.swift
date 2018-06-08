//
//  Table.swift
//  Base
//
//  Created by poniavit on 5/6/2561 BE.
//

import Foundation
import Base
import RxSwift

open class BaseTableViewCellModel : ComponentViewModel {
    public weak var cellView : BaseTableViewCell?
    
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
    
    public private(set) var varDs :Variable<[BaseTableViewCellModel]>?
    public var baseTableView : BaseTableView?
    public var dataSource : [BaseTableViewCellModel] {
        return varDs?.value ?? []
    }
    
    public func reload(){
        self.baseTableView?.tableView?.reloadData()
    }
    
    public convenience init(withDataSource: [BaseTableViewCellModel], disposeBag:DisposeBag) {
        self.init()
        self.varDs = Variable([])
        self.varDs?.value = withDataSource
        self.varDs?.asObservable()
            .subscribe(onNext: { [unowned self] value in
                self.reload()
            })
        .disposed(by:disposeBag)
    }
    
    public func replaceSource(withNewSource newSource:[BaseTableViewCellModel]){
        self.varDs?.value.removeAll()
        self.varDs?.value = newSource
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let model = dataSource[row]
        let width = tableView.frame.size.width
        return model.getCellView().getHeighByRatio(width)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let model = dataSource[row]
        var cell : BaseTableViewCell? = tableView.dequeueReusableCell(withIdentifier: model.getNibName()!) as! BaseTableViewCell?
        if(cell == nil){
            cell = model.getCellView()
            cell?.bind()
        }
        cell?.selectionStyle = model.getCellSelectionStyle()
        cell?.viewModel = model
        cell?.setupAccessibilityId()
        cell?.accessibilityIdentifier?.append(":\(row)")
        cell?.frame.size.width = tableView.frame.size.width
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
    public weak var adapter : BaseTableAdapter!
    public convenience init(_ name:String!, style:UITableViewStyle? = UITableViewStyle.plain,
                            onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil){
        self.init(name, withAdapter: BaseTableAdapter(),style:style)
    }
    
    public func getTableView() -> UITableView? {
        return self.adapter.baseTableView?.tableView
    }
    
    public convenience init(_ name:String!,
                            withAdapter adapter:BaseTableAdapter,
                            style:UITableViewStyle? = UITableViewStyle.plain,
                            onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil){
        self.init(withName: name, nibName: "")
        self.adapter = adapter
        self.adapter.baseTableView = self.getBaseView()
        self.getBaseView().initTable(withAdapter:adapter, style: style!,onRefresh:onRefresh)
        self.adapter.baseTableView?.reloadData()
    }
    
    private func getBaseView() -> BaseTableView{
        let vi:BaseTableView = self.getView()
        return vi
    }
    
    override public func getView<T>() -> T where T : BaseTableView {
        let vi:BaseTableView = super.getView()
        return vi as! T
    }
    
}

public class BaseTableView : BaseView {
    public weak private(set) var tableView : UITableView?
    public var onRefresh : ((_ sender:UIRefreshControl) -> Swift.Void)?
    public override func setupView() {
        super.setupView()
    }
    
    public func reloadData(){
        self.tableView?.reloadData()
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
    
    @discardableResult
    public func initTable(withAdapter:BaseTableAdapter, style:UITableViewStyle,
                          onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil) -> UITableView!{
        let tableView = UITableView(frame: CGRect.zero, style: style)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = self.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = withAdapter
        tableView.dataSource = withAdapter
        withAdapter.baseTableView = self
        for model:BaseTableViewCellModel in withAdapter.dataSource {
            model.getCellView().registerOn(table: tableView)
        }
        self.onRefresh = onRefresh
        if #available(iOS 10.0, *) {
            if(onRefresh != nil){
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self,
                                         action: #selector(self.onTriggerRefresh(sender:)),
                                         for: UIControlEvents.valueChanged)
                
                tableView.refreshControl = refreshControl
            }
        }
        self.addSubview(tableView)
        self.tableView = tableView
        return tableView
    }
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    public override func getModel() -> BaseTableViewModel{
        return self.viewModel as! BaseTableViewModel
    }
}


open class BaseTableViewCell : UITableViewCell, BaseViewLC {
    public weak var viewModel : BaseViewModel!
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
        print("🎯 did tap table on cell \(self.getModel().name)")
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
        self.accessibilityIdentifier = "\(self.getModel().name)"
    }
    
    open func getModel() -> BaseTableViewCellModel {
        return self.viewModel as! BaseTableViewCellModel
    }
}
