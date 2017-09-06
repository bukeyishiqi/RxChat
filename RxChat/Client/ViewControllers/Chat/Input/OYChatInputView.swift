//
//  OYChatInputView.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/31.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift


@IBDesignable
class OYChatInputView: UIView {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var chatInputTextView: UITextView!
    
    @IBOutlet weak var chatEmotionBtn: UIButton!
    
    @IBOutlet weak var chatVoiceBtn: UIButton!
    
    @IBOutlet weak var chatShareBtn: UIButton!
    
    @IBOutlet weak var chatRecordBtn: UIButton!
    
    weak var delegate: ChatInputDelegate?
    
    var contentView:UIView!

    fileprivate var type: Variable<KeyboardType>  = Variable(.none)
    
    var shareEmotionView: OYChatEmotionInputView?
    var shareInputView :  OYChatShareInputView?
    
    var keyBoardIsActive: Bool  // 键盘是否在弹出状态
    
    override init(frame: CGRect) {
        keyBoardIsActive = false

        super.init(frame: frame)
        contentView = loadViewFromNib()
        addSubview(contentView)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        keyBoardIsActive = false

        super.init(coder: aDecoder)
        contentView = loadViewFromNib()
        addSubview(contentView)
        addConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setConnectionView()
    }
    
    func setConnectionView() {
        
        shareInputView = OYChatShareInputView.initViewFromNib()
        shareInputView?.delegate = self
        self.superview!.addSubview(shareInputView!)
        
        shareEmotionView = OYChatEmotionInputView.share
        shareEmotionView?.delegate = self
        self.superview!.addSubview(shareEmotionView!)
        

        shareEmotionView?.setNeedsUpdateConstraints()
        
        chatInputTextView.do {
            $0.layer.cornerRadius = 5
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.textContainer.lineFragmentPadding = 0
            $0.layoutManager.allowsNonContiguousLayout = false
            $0.textContainerInset = UIEdgeInsets.init(top: 9, left: 6, bottom: 0, right: 6)
            $0.dataDetectorTypes = UIDataDetectorTypes(rawValue: 0)
            $0.delegate = self as? UITextViewDelegate
        }
        
        
        setSubViewConstraints()
        
        self.observerView()
    }
    
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func observerView() {
        chatEmotionBtn.rx.tap
            .subscribe(onNext:{ [weak self] in
                self?.handleEmotionBtnAction()
            }).disposed(by: disposeBag)
    
        chatShareBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleShareBtnAction()
            }).disposed(by: disposeBag)
        
        chatVoiceBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleVoiceBtnAction()
            }).disposed(by: disposeBag)

        type.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
            
                self?.chatRecordBtn.alpha = type != .record ? 0 : 1;
                self?.chatInputTextView.alpha = self?.chatRecordBtn.alpha == 0 ? 1 : 0;
                
                if type == .emotion {
                    self?.setButton(button: self?.chatEmotionBtn, image: "tool_keyboard_1", heighLightImage: "tool_keyboard_2")
                } else {
                    self?.setButton(button: self?.chatEmotionBtn, image: "tool_emotion_1", heighLightImage: "tool_emotion_2")
                }
                if type == .record {
                    self?.setButton(button: self?.chatVoiceBtn, image: "tool_keyboard_1", heighLightImage: "tool_keyboard_2")
                } else {
                    self?.setButton(button: self?.chatVoiceBtn, image: "tool_voice_1", heighLightImage: "tool_voice_2")
                }
            
            }).addDisposableTo(disposeBag)
        
        /** 添加键盘通知订阅*/
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow).subscribe(onNext:{
            self.handleKeyBoard(notifiy: $0)
        }).addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardDidShow).subscribe(onNext:{
            self.handleKeyBoard(notifiy: $0)
        }).addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide).subscribe(onNext:{
            self.handleKeyBoard(notifiy: $0)
        }).addDisposableTo(disposeBag)
    
    }
    
}

// MARK: 代理
extension OYChatInputView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.delegate?.sendTextMessage(text: textView.text)
            return false
        }
        return true
    }
}

// MARK: 约束
extension OYChatInputView {

    fileprivate func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.snp.makeConstraints{[weak self] (make) -> Void in
            guard let strongSelf = self else { return }
            make.leading.equalTo(strongSelf.snp.leading)
            make.trailing.equalTo(strongSelf.snp.trailing)
            make.top.equalTo(strongSelf.snp.top)
            make.bottom.equalTo(strongSelf.snp.bottom)
        }
    }
    
    func setSubViewConstraints() {
        
        shareEmotionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snp.bottom)
        })
        
        self.shareInputView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snp.bottom)
        })
    }
}


// MARK: show
extension OYChatInputView {
    fileprivate func showEmotionKeyboard(animated: Bool) {
        shareInputView?.isHidden = true
        shareEmotionView?.isHidden = false
        if animated {
            shareEmotionView?.frame.origin.y = self.frame.maxY + CGFloat(CHAT_KEYBOARD_PANEL_HEIGHT)
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.shareEmotionView?.frame.origin.y = self.frame.maxY
            })
        } else {
            shareEmotionView?.frame.origin.y = self.frame.maxY
        }
    }
    
    fileprivate func showSharePanelKeyboard(animated: Bool) {
        shareEmotionView?.isHidden = true
        shareInputView?.isHidden = false
        if animated {
            shareInputView?.frame.origin.y = self.frame.maxY + CGFloat(CHAT_KEYBOARD_PANEL_HEIGHT)
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.shareInputView?.frame.origin.y = self.frame.maxY
            })
        } else {
            shareInputView?.frame.origin.y = self.frame.maxY
        }
    }
}


// MARK: -私有初始化方法
extension OYChatInputView {
    fileprivate func setButton(button: UIButton?, image: String, heighLightImage: String) {
        button?.setImage(UIImage.init(named: image), for: .normal)
        button?.setImage(UIImage.init(named: heighLightImage), for: .highlighted)
    }
}


// MARK: - actionBar按钮互斥事件
extension OYChatInputView {

    fileprivate func handleEmotionBtnAction() {
        switch type.value  {
            case .default:
                type.value = .emotion
                chatInputTextView.resignFirstResponder()
                self.showEmotionKeyboard(animated: true)
                break
            case .emotion:
                type.value = .default
                chatInputTextView.becomeFirstResponder()
                break
            case .panel:
                type.value = .emotion
                self.showEmotionKeyboard(animated: true)
                break
            case .record, .none:
                type.value = .emotion

               let info = KeyboardShowHideInfo(keyboardHeight: CGFloat(CHAT_KEYBOARD_PANEL_HEIGHT), toKeyboardType: type.value, curve: UIViewAnimationOptions(rawValue: 0), duration: 0.25)
                self.showEmotionKeyboard(animated: false)
                self.delegate?.updateKeyboard(keyboardShowHideInfo: info)
                break
        }
    }
    
    fileprivate func handleShareBtnAction() {
        switch type.value  {
        case .default:
            type.value = .panel
            chatInputTextView.resignFirstResponder()
            self.showSharePanelKeyboard(animated: true)
            break
        case .emotion:
            type.value = .panel
            self.showSharePanelKeyboard(animated: true)
            break
        case .panel:
            type.value = .default
            chatInputTextView.becomeFirstResponder()
            break
        case .record, .none:
            type.value = .panel
            
            let info = KeyboardShowHideInfo(keyboardHeight: CGFloat(CHAT_KEYBOARD_PANEL_HEIGHT), toKeyboardType: type.value, curve: UIViewAnimationOptions(rawValue: 0), duration: 0.25)
            self.showSharePanelKeyboard(animated: false)
            self.delegate?.updateKeyboard(keyboardShowHideInfo: info)
            break
        }

    }
    
    fileprivate func handleVoiceBtnAction() {
        switch type.value  {
        case .default:
            type.value = .record
            chatInputTextView.resignFirstResponder()
            chatRecordBtn.alpha = 1
            chatInputTextView.alpha = 0
            break
        case .record:
            type.value = .default
            chatInputTextView.becomeFirstResponder()
            chatRecordBtn.alpha = 0
            chatInputTextView.alpha = 1
            break
        case .emotion, .panel, .none:
            type.value = .record
            
            let info = KeyboardShowHideInfo(keyboardHeight: CGFloat(0), toKeyboardType: type.value, curve: UIViewAnimationOptions(rawValue: 0), duration: 0.25)
            self.delegate?.updateKeyboard(keyboardShowHideInfo: info)
            break
        }
    }
    
    fileprivate func handleKeyBoard(notifiy: Notification) {
        
        if keyBoardIsActive {
            handleKeyBoardFrameChange(notifiy: notifiy)
        } else {
            handleKeyBoardFrameChangeByNoAnimation(notifiy: notifiy)
        }
    }
    
    
    private func handleKeyBoardFrameChange(notifiy: Notification) {
        let frame = (notifiy.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let duration = (notifiy.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        let curve = (notifiy.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).uint32Value
        
        if notifiy.name == Notification.Name.UIKeyboardWillShow {
            type.value = .default
            let info = KeyboardShowHideInfo(keyboardHeight: (frame?.height)!, toKeyboardType: type.value, curve: UIViewAnimationOptions(rawValue: 0), duration: 0.25)
            
            UIView.animate(withDuration: duration!, animations: {
                self.chatInputTextView.alpha = 1
                self.chatRecordBtn.alpha = 0
            }, completion: nil)

            self.delegate?.updateKeyboard(keyboardShowHideInfo: info)
            
        } else if (notifiy.name == Notification.Name.UIKeyboardWillHide) {
            let info: KeyboardShowHideInfo
            if type.value == .emotion {
                self.showEmotionKeyboard(animated: true)
                info = KeyboardShowHideInfo(keyboardHeight: (frame?.height)!, toKeyboardType: .emotion, curve: UIViewAnimationOptions(rawValue: UInt(curve! << 16)), duration:CGFloat(duration!))
            } else if type.value == .panel {
                info = KeyboardShowHideInfo(keyboardHeight: CGFloat(CHAT_KEYBOARD_PANEL_HEIGHT), toKeyboardType: .panel, curve: UIViewAnimationOptions(rawValue: 0), duration: CGFloat(duration!))
            } else if type.value == .record {
                //如果文字输入框有内容，需要调整高度
                UIView.animate(withDuration: duration!, animations: { 
                    self.chatInputTextView.alpha = 0
                    self.chatRecordBtn.alpha = 1
                }, completion: nil)
                info = KeyboardShowHideInfo(keyboardHeight: CGFloat(0), toKeyboardType: .panel, curve: UIViewAnimationOptions(rawValue: 0), duration: CGFloat(duration!))
            } else if type.value == .none {
                info = KeyboardShowHideInfo(keyboardHeight: CGFloat(0), toKeyboardType: .panel, curve: UIViewAnimationOptions(rawValue: 0), duration: CGFloat(duration!))
            } else {
                self.type.value = .default
                info = KeyboardShowHideInfo(keyboardHeight: CGFloat(0), toKeyboardType: .panel, curve: UIViewAnimationOptions(rawValue: 0), duration: CGFloat(duration!))
            }
            self.delegate?.updateKeyboard(keyboardShowHideInfo: info)
        }
    }
    
    private func handleKeyBoardFrameChangeByNoAnimation(notifiy: Notification) {
        if notifiy.name == Notification.Name.UIKeyboardWillShow {
            type.value = .default

            let frame = (notifiy.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            
            let info = KeyboardShowHideInfo(keyboardHeight: (frame?.height)!, toKeyboardType: type.value, curve: UIViewAnimationOptions(rawValue: 0), duration: 0.25)
            self.delegate?.updateKeyboard(keyboardShowHideInfo: info)
            
        } else if (notifiy.name == Notification.Name.UIKeyboardDidShow) {
            //            let frame = (notifiy.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            keyBoardIsActive = true
            shareInputView?.isHidden = true
            shareEmotionView?.isHidden = true
        }
    }
    
}







