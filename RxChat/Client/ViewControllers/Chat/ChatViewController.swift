//
//  ChatViewController.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/31.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxViewController

class ChatViewController: UIViewController,UITableViewDelegate {
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chatInputView: OYChatInputView!
    
    @IBOutlet weak var refreshView: UIView!

    @IBOutlet weak var voiceTipView: UIView!

    @IBOutlet weak var chatInputViewBottomConstraint: NSLayoutConstraint!
    
    let dataSource = RxTableViewSectionedReloadDataSource<ChatSectionModel>()
    
    var viewModel = ChatViewModel.init(provider: ServiceProvider())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.do {
            $0.backgroundColor = kLLBackgroundColor_lightGray
            $0.estimatedRowHeight = 45
            $0.rowHeight = UITableViewAutomaticDimension
        }
        observerViewModel()
        observerInputView()
    }
    
    private func observerViewModel() {
        
        let input = ChatViewModel.Input.init(sendText: chatInputView.rx.didSendTextMsg, sendGif: chatInputView.rx.didSendGifMsg)
        let output = viewModel.transform(input)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        dataSource.configureCell = { [weak self] (_, tv, indexPath, element) in
            let identifier = element.description
            var cell = tv.dequeueReusableCell(withIdentifier: identifier) as? ChatBaseCell
            
            if cell == nil {
                self?.tableView.register(NSClassFromString(identifier), forCellReuseIdentifier: identifier)
                cell = self?.tableView.dequeueReusableCell(withIdentifier: identifier) as? ChatBaseCell
            }
            cell?.viewModel = element
            return cell ?? UITableViewCell()
        }
        output.list.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    
        output.didSendMsg?.drive().disposed(by: disposeBag)
        output.scrollPosition.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] position in
            /** 调整界面滚动位置*/
            self?.scrollToPosition(position: position)
        }).disposed(by: disposeBag)
        
        
    }

    private func observerInputView() {

        chatInputView.rx.didUpdateKeyboardShowHideInfo
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                self?.updateKeyboard(keyboardShowHideInfo: info)
        }).addDisposableTo(disposeBag)
//        
////        chatInputView.rx.didSendTextMsg
////            .observeOn(MainScheduler.instance)
////            .subscribe(onNext: { [weak self] sendMsg in
////                print("dddd:", sendMsg)
////        }).addDisposableTo(disposeBag)
//        
//        chatInputView.rx.didSendGifMsg
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [weak self] gifItem in
//                print("gif:", gifItem)
//            }).addDisposableTo(disposeBag)
//        
//        chatInputView.rx.ShareTagTap
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [weak self] tag in
//                print("tag:", tag)
//            }).addDisposableTo(disposeBag)
//        
//        chatInputView.rx.addPackageButtonTap
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [weak self] _ in
//                print("add:")
//            }).addDisposableTo(disposeBag)
    }
}


// MARK: UITableViewDelegate
extension ChatViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModel = dataSource[indexPath]
        return viewModel.cellHeight
    }
}


extension ChatViewController {
   fileprivate  func updateKeyboard(keyboardShowHideInfo: KeyboardShowHideInfo) {
        let constant = keyboardShowHideInfo.keyboardHeight
        UIView.animate(withDuration: TimeInterval(keyboardShowHideInfo.duration), delay: 0, options: keyboardShowHideInfo.curve, animations: {
            self.chatInputViewBottomConstraint.constant = constant
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: true)
        }, completion: nil)
    }
    
    fileprivate func scrollToBottom(animated: Bool) {
        
        let row = tableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath.init(row: row, section: 0)
        let _ = dataSource.tableView(self.tableView, cellForRowAt: indexPath)
        let t = DispatchTime.now() + TimeInterval.init(0.001)
        
//FIXME: 首次进入滚动存在在闪动问题
        DispatchQueue.main.asyncAfter(deadline: t ) {
//            let offset = CGPoint.init(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
//            self.tableView.setContentOffset(offset, animated: false)
//            print("****:",offset)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    fileprivate func scrollToPosition(position: ScorllPosition) {
        switch position {
        case .top:
            let indexPath = IndexPath.init(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            break
        case let .middle(index: index):
            let indexPath = IndexPath.init(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            break
        case .bottom:
            scrollToBottom(animated: false)
            break
        }
    }
}


extension Reactive where Base: UITableView {
    var scrollToBottom: UIBindingObserver<Base, Bool> {
        return UIBindingObserver.init(UIElement: base, binding: {(tableView, animated) in
            let row = tableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath.init(row: row, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        })
    }
}



