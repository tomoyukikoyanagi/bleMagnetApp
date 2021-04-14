//
//  CustomCollectionViewCell.swift
//  BLEMultiConnectSample
//
//  Created by TomoyukiKoyanagi on 2019/08/10.
//  Copyright © 2019 hiro. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    static let setNotification = Notification.Name("setNotification")
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var image1: UIImage!
    @IBOutlet weak var image2: UIImage!
    @IBOutlet weak var image3: UIImage!
    var cP = CirculraProgressView(frame: CGRect(x: 10.0, y:10.0, width: 70.0, height: 70.0))
    var old_head_or_tail: Device.Head_or_Tail? = Device.Head_or_Tail.head
    
    var mod: Model? {
        didSet{
            self.image3 = nil
            self.nameLabel.text = mod?.name
            self.nameLabel.textAlignment = NSTextAlignment.center
            self.image3 = mod?.image2
            ImageView.image = image3
        }
    }
        
    var data: Device? {
        didSet {
            self.image1 = nil
            self.image2 = nil
            guard let data = data else { return }
            //名前の登録
            self.nameLabel.text = data.peripheral.name ?? "test"
            
            
            //print("**********peripheral name:***********")
            //print("print: \(data.peripheral)")
            self.nameLabel.textAlignment = NSTextAlignment.center
            //名前によって呼び出すModel(imageを保管している型)を特定
            let mod = getModel(str: self.nameLabel.text ?? "test")
            self.image1 = mod.image1
            self.image2 = mod.image2
            
            
            //アニメーション処理をする場合
                //表裏による表示画像の反転設定
            
                if data.head_or_tail != old_head_or_tail {
                    addCircularAnimation(iv: self.ImageView)
                    shrinkAnimation()
                        if data.head_or_tail == Device.Head_or_Tail.head {
                            cP.progressColor = UIColor.green
                            ImageView.image = image1
                            //setanimation
                            addPulse()
                            animateProgress(iv: self.ImageView)
                        }
                        else {
                            sleep(1)
                            cP.progressColor = UIColor.lightGray
                            ImageView.image = image2
                            //setanimation
                            addPulse()
                    }
                }
                old_head_or_tail = data.head_or_tail
                self.image1 = nil
                self.image2 = nil
            }
        }
    
    private func expandAnimation() {
        let expand = CASpringAnimation(keyPath: "transform.scale")
        expand.duration = 0.2
        expand.fromValue = 1
        expand.toValue = 1.3
        expand.autoreverses = false
        expand.repeatCount = 1
        expand.initialVelocity = 0.8
        expand.damping = 1.0
        expand.fillMode = kCAFillModeForwards
        expand.isRemovedOnCompletion = false
        //layer.bounds = self.bounds
        self.ImageView.layer.contentsGravity = "center"
        self.ImageView.layer.add(expand, forKey: "expand")
    }
    
    private func shrinkAnimation() {
        let shrink = CABasicAnimation(keyPath: "transform.scale")
        shrink.duration = 0.2
        shrink.fromValue = 1.3
        shrink.toValue = 1
        shrink.autoreverses = false
        shrink.repeatCount = 1
        shrink.fillMode = kCAFillModeForwards
        shrink.isRemovedOnCompletion = false
        self.ImageView.layer.add(shrink, forKey: "shrink")
    }
    
    func addPulse(){
        let pulse = Pulsing(numberOfPulses: 1, radius: 60, position: ImageView.center)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.red.cgColor
        ImageView.layer.insertSublayer(pulse, below: ImageView.layer)
    }
    
    func addCircularAnimation(iv: UIImageView){
        //circularpathを追加
        cP.trackColor = UIColor.lightGray
        cP.progressColor = UIColor.green
        ImageView.addSubview(cP)
        cP.center = iv.center
    }
    
    @objc func animateProgress(iv: UIImageView) {
        //cP.setProgressWithAnimation(duration: 1.0, value: 0.99)
        let timer = 5.0
        cP.reduceProgressWithAnimation(duration: timer, value: 0.001)
        Timer.scheduledTimer(withTimeInterval: timer - 1, repeats: false){ t in
            NotificationCenter.default.post(name: CustomCollectionViewCell.setNotification, object: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
