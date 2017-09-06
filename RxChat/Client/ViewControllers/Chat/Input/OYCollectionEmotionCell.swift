//
//  OYCollectionEmotionCell.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/7.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import UIKit


let  EMOJI_IMAGE_SIZE: CGFloat = 30

final class OYCollectionEmojiCell: UICollectionViewCell {

    var emotionItem: EmotionItem? {
        didSet {
            guard let image = EmotionService.default.imageForEmotionModel(item: emotionItem!) else {
                self.imageView.image = nil
                return
            }
            self.imageView.image = image
        }
    }
    
    var isDelete: Bool {
        get {
          return  emotionItem?.imagePNG == "emotion_delete"
        }
    }
    
    var imageView: UIImageView

    override init(frame: CGRect) {
        
        self.imageView = UIImageView.init(frame: CGRect.init(x: (frame.width - EMOJI_IMAGE_SIZE) / 2, y: (frame.height - EMOJI_IMAGE_SIZE) / 2, width: EMOJI_IMAGE_SIZE, height: EMOJI_IMAGE_SIZE))
        self.imageView.contentMode = .scaleAspectFit
        
        super.init(frame: frame)
        
        self.contentView.addSubview(self.imageView)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class OYCollectionGifCell: UICollectionViewCell {
    
    var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    var heighlightimageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage.init(named: "EmoticonFocus")
    }

    var label: UILabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textAlignment = .center
        $0.textColor = UIColor.darkText
    }

    var emotionItem: EmotionItem? {
        didSet {
            guard let image = EmotionService.default.imageForEmotionModel(item: emotionItem!) else {
                self.imageView.image = nil
                self.label.text = ""
                return
            }
            self.imageView.image = image
            self.label.text = emotionItem?.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
        
        self.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.width)
        self.heighlightimageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.width)
        self.label.frame = CGRect.init(x: 0, y: frame.width, width: frame.width, height: frame.height - frame.width)
        
        self.contentView.addSubview(self.imageView)
//        self.contentView.addSubview(self.heighlightimageView)
        self.contentView.addSubview(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}









