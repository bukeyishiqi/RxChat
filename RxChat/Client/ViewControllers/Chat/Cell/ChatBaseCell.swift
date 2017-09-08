//
//  ChatBaseCell.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/28.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa


class ChatBaseCell: UITableViewCell {
    
    lazy var avatarImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = UIColor.red
    }
    
    lazy var bubbleView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    var disposeBag: DisposeBag?

    var viewModel: ChatBaseCellViewModel? {
        didSet {
            let disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }
            /** 设置头像*/
            viewModel.headUrl.distinctUntilChanged()
                .subscribe(onNext: {[weak self] urlStr in
                    self?.avatarImage.image = UIImage.init(named: urlStr)
                }).disposed(by: disposeBag)
            self.disposeBag = disposeBag
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = kLLBackgroundColor_lightGray
        self.addSubview(avatarImage)
        self.addSubview(bubbleView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(bubbleView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
        viewModel = nil
    }
}

extension ChatBaseCell {
    
    // MARK:- 获取cell的高度
    func getCellHeight() -> CGFloat {
        self.layoutSubviews()
        
        if avatarImage.height > bubbleView.height {
            return avatarImage.height + 10.0
        } else {
            return bubbleView.height
        }
    }
}




