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
    
    public var cellSelectionStyle : UITableViewCellSelectionStyle!
        = UITableViewCellSelectionStyle.default
    
    public var didSelectedRow : ((_ indexPath:IndexPath, _ model:BaseTableViewCellModel) -> Swift.Void)?
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
    
    public var baseTableView : BaseTableView?
    public convenience init(withDataSource: [BaseTableViewCellModel]) {
        self.init()
        self.varDs.value = withDataSource
        varDs.asObservable()
            .subscribe(onNext: { [unowned self] value in
                self.baseTableView?.tableView.reloadData()
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
        cell?.selectionStyle = model.cellSelectionStyle
        cell?.viewModel = model
        cell?.setupView()
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let model = dataSource[row]
        if(model.didSelectedRow != nil) {
            model.didSelectedRow!(indexPath,model)
        }
    }
}

public class BaseTableViewModel : ComponentViewModel {
    public var adapter : BaseTableAdapter!
    public private(set) var tableView : UITableView!
    
    public convenience init(_ name:String!){
        self.init(name, withAdapter: BaseTableAdapter())
    }
    
    public convenience init(_ name:String!, withAdapter adapter:BaseTableAdapter) {
        self.init(withName: name, nibName: "")
        self.adapter = adapter
        self.adapter.baseTableView = self.getBaseView()
        self.tableView = self.getBaseView().tableView
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
    public let tableView : UITableView = UITableView()
    public override func setupView() {
        super.setupView()
        self.tableView.removeFromSuperview()
        self.tableView.frame = self.bounds
        self.addSubview(tableView)
    }
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    public override func getModel() -> BaseTableViewModel{
        return self.viewModel as! BaseTableViewModel
    }
}
