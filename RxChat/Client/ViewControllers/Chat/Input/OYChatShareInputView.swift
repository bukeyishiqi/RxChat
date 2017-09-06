//
//  OYChatShareInputView.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/4.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources




final class OYCollectionViewShareCell: UICollectionViewCell {

    var imageView = UIImageView().then {
    $0.frame = CGRect.init(x: 0, y: 0, width: CELL_SIZE, height: CELL_SIZE)
    $0.contentMode = .center
    }
    
    var titleLabel =  UILabel().then {
        $0.frame = CGRect.init(x: 0, y: CELL_SIZE + 6, width: CELL_SIZE, height: 20)
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor.lightGray
    }

    var shareItem: ShareInputItem? {
        didSet {
            guard let imageName = shareItem?.imageName else {
                    self.isHidden = true
                return
            }
            self.isHidden = false
            self.imageView.image = UIImage.init(named: imageName)
            self.titleLabel.text = shareItem?.title
            self.tag = (shareItem?.tag)!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundView = UIImageView.init(image: UIImage.init(named: "sharemore_other"))
        self.selectedBackgroundView = UIImageView.init(image: UIImage.init(named: "sharemore_other_HL"))
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


final class OYCollectionViewLayout: UICollectionViewFlowLayout {
   
    var itemWidth = CELL_SIZE
    var itemHeight = CELL_SIZE
    
    lazy var gap = (SCREEN_WIDTH - CELL_SIZE * CGFloat(NUM_COLS)) / CGFloat(NUM_COLS + 1)

    override init() {
        super.init()
        self.itemSize = CGSize().with {
            $0.width = CELL_SIZE
            $0.height = CELL_SIZE
        }
        self.scrollDirection = .horizontal
        
        self.minimumLineSpacing = gap
        self.minimumInteritemSpacing = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                self.itemSize = CGSize().with {
                    $0.width = CELL_SIZE
                    $0.height = CELL_SIZE
                }
                self.scrollDirection = .horizontal
        
                self.minimumLineSpacing = gap
                self.minimumInteritemSpacing = 0

    }
    
    override func prepare() {
        let rgap = SCREEN_WIDTH - CGFloat(NUM_COLS) * (gap + CELL_SIZE)
        self.sectionInset = UIEdgeInsetsMake(14, gap, 25, rgap)
    }
}


 class OYChatShareInputView: UIView {
    
    let disposeBag: DisposeBag = DisposeBag()
    let dataSource = RxCollectionViewSectionedReloadDataSource<ShareInputSectionData>()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    weak var delegate: OYChatShareInputViewDelegate?
    
    var sectionItems = Variable(buildSharepanelData())
    
    class func initViewFromNib() -> OYChatShareInputView{
        
        let nib = UINib(nibName: "OYChatShareInputView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view as! OYChatShareInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.do {
            $0.register(OYCollectionViewShareCell.self, forCellWithReuseIdentifier: "OYCollectionViewShareCell")
        }
        
        pageControl.do {
            $0.numberOfPages = sectionItems.value.count
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 1)) {
            self.observerView()
        }
    }
    
    
    private func observerView() {
        dataSource.configureCell = {_, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OYCollectionViewShareCell", for: indexPath) as! OYCollectionViewShareCell
            cell.shareItem = item
            return cell
        }
        sectionItems.asDriver().drive(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
        
        collectionView.rx.modelSelected(ShareInputItem.self).subscribe(onNext: { (item) in
            guard let tag = item.tag else { return }
            self.delegate?.shareInputViewDidSelectTag(tag: tag)
        }).disposed(by: disposeBag)
        
        collectionView.rx.didEndDecelerating.map{[weak self] in
            Int((self?.collectionView.contentOffset.x)! / SCREEN_WIDTH)
            }
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)
    }
    
    override func updateConstraints() {
        super.updateConstraints()

        let views = ["selfView": self]
        let metrics = ["height": CHAT_KEYBOARD_PANEL_HEIGHT]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[selfView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[selfView(==height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
    }
}



struct ShareInputItem {
    var imageName: String?
    var title: String?
    var tag: Int?
}

struct ShareInputSectionData {
    
    var data: [ShareInputItem]
}

extension ShareInputSectionData: SectionModelType {
    
    typealias Item = ShareInputItem
    
    var items: [Item] { return self.data}
    
    init(original: ShareInputSectionData, items: [Item]) {
        self = original
        self.data = items
    }
    
}

















