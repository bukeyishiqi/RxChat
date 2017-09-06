//
//  OYChatEmotionInputView.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/4.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources


protocol OYChatEmotionViewDelegate: NSObjectProtocol {
    /** 选择了表情Cell*/
    func emojiCellDidSelected(emotionItem: EmotionItem)
    /** 选择了gif图片Cell*/
    func emojiGifCellDidSelected(emotionItem: EmotionItem)
    /** 发送按钮点击*/
    func sendButtonDidSelected()
    /** 删除按钮点击*/
    func deleteCellDidSelected()
    /** 表情包添加按钮点击*/
    func emotionBagAddButtonDidSelected()
    
}


final class OYChatEmotionInputView: UIView {

    let disposeBag: DisposeBag = DisposeBag()
    let dataSource = RxCollectionViewSectionedReloadDataSource<EmotionSectionModel>()
    let viewModel: OYChatEmotionInputViewModel = OYChatEmotionInputViewModel()

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var bottomScrollView: UIScrollView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    weak var delegate: OYChatEmotionViewDelegate?
    
    static let share: OYChatEmotionInputView = {
        return initViewFromNib()
    }()

    class func initViewFromNib() -> OYChatEmotionInputView{

        let nib = UINib(nibName: "OYChatEmotionInputView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view as! OYChatEmotionInputView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(OYCollectionEmojiCell.self, forCellWithReuseIdentifier: "OYCollectionEmojiCell")
        collectionView.register(OYCollectionGifCell.self, forCellWithReuseIdentifier: "OYCollectionGifCell")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 1)) {
            self.observerView()
        }
        
        setBottomViews()
        registerGesture()
    }
    
    private func setBottomViews() {
        let groups = viewModel.group.value
        for i in 0..<groups.count {
            let button = createButton(imageName: groups[i].groupIconName, index: i).then({
                $0.tag = i
                $0.frame = CGRect.init(x: CGFloat(i)*BOTTOM_BUTTON_WIDTH, y: 0, width: BOTTOM_BUTTON_WIDTH, height: BOTTOM_AREA_HEIGHT)
            })
            bottomScrollView.addSubview(button)

            button.rx.tap.subscribe(onNext: {[weak self] _ in
                self?.gotoSection(section: button.tag)
            }).addDisposableTo(disposeBag)
            
        }
        bottomScrollView.contentSize = CGSize.init(width: BOTTOM_BUTTON_WIDTH*CGFloat(groups.count), height: BOTTOM_AREA_HEIGHT)
        
    }
    
    private func registerGesture() {
        let tap = UITapGestureRecognizer().then {
            $0.numberOfTapsRequired = 1
            $0.numberOfTouchesRequired = 1
        }
        let longPress = UILongPressGestureRecognizer().then {
            $0.minimumPressDuration = 0.5
            $0.allowableMovement = 1000
        }
        collectionView.addGestureRecognizer(tap)
        collectionView.addGestureRecognizer(longPress)
        
        tap.rx.event
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {
            let point = $0.location(in: $0.view)
            let touchView = self.subViewAtPoint(point: point)
            guard let view = touchView else { return }
            
            let cell = view as? OYCollectionEmojiCell
            if let cell = cell {
                if cell.isDelete {
                    self.delegate?.deleteCellDidSelected()
                } else {
                    self.delegate?.emojiCellDidSelected(emotionItem: cell.emotionItem!)
                }
            } else {
                self.delegate?.emojiGifCellDidSelected(emotionItem: ((view as! OYCollectionGifCell).emotionItem)!)
            }
        }).disposed(by: disposeBag)
        
        longPress.rx.event.subscribe(onNext: { _ in
            
        }).disposed(by: disposeBag)
    }
    
    
    private func observerView() {
        plusButton.rx.tap
            .subscribe(onNext:{
            self.delegate?.emotionBagAddButtonDidSelected()
            }).disposed(by: disposeBag)
    
        sendButton.rx.tap
            .subscribe(onNext:{
            self.delegate?.sendButtonDidSelected()
            }).disposed(by: disposeBag)
        
        dataSource.configureCell = {_ , collectionView, indexPath, model in
            let sectionData = self.viewModel.getSectionData(section: indexPath.section)
            if sectionData?.group.type == .emoji {
                let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OYCollectionEmojiCell", for: indexPath) as! OYCollectionEmojiCell
                cell.emotionItem = model
                return cell
            } else if (sectionData?.group.type == .facialGif) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OYCollectionGifCell", for: indexPath) as! OYCollectionGifCell
                cell.emotionItem = model
                return cell
            }
            return UICollectionViewCell()
        }
        
        viewModel.sectionModels?.asDriver().drive(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
        
        collectionView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        collectionView.rx.didEndDecelerating.map{[weak self] in
            Int((self?.collectionView.contentOffset.x)! / SCREEN_WIDTH)
            }
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)

    }
    
    override func updateConstraints() {
        let views = ["selfView": self]
        let metrics = ["height": CHAT_KEYBOARD_PANEL_HEIGHT]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[selfView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[selfView(==height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        super.updateConstraints()
    }
}

extension OYChatEmotionInputView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return viewModel.sectitonSizeForSection(section: indexPath.section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.sectionEdgInsets(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.sectionMinimumLineSpacing(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.sectionMinimumInteritemSpacing(section: section)
    }
}

extension OYChatEmotionInputView {
    fileprivate func createButton(imageName: String, index: Int) -> UIButton {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: imageName), for: .normal)
        button.backgroundColor = UIColor.white
        
        let layer = CALayer().then {
            $0.backgroundColor = UIColor.lightGray.cgColor
            $0.frame = CGRect.init(x: BOTTOM_BUTTON_WIDTH - 1, y: (BOTTOM_AREA_HEIGHT - 25) / 2, width: 1, height: 25)
        }
        button.layer.addSublayer(layer)
        
        return button
    }
    
    fileprivate func gotoSection(section: Int) {
        let sectionData = viewModel.groupData[section]
        collectionView.scrollRectToVisible(CGRect.init(x: SCREEN_WIDTH*CGFloat(sectionData.startSection!), y: 0, width: SCREEN_WIDTH, height: TOP_AREA_HEIGHT), animated: false)
        
    }
    
    fileprivate func subViewAtPoint(point: CGPoint) -> UIView? {
        guard point.y >= 0 else {
            return nil
        }
        for subView in collectionView.subviews {
            let locPoint = subView.convert(point, from: collectionView)
            if subView.point(inside: locPoint, with: nil) {
                return subView
            }
        }
        return nil
    }
}




