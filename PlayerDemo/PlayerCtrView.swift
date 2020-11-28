//
//  PlayerCtrView.swift
//  PlayerDemo
//
//  Created by Arex on 2020/11/27.
//

import UIKit

import SnapKit

let PROGRESS_SLIDER_MAXVALUE:Float = 10
let PROGRESS_SLIDER_MINVALUE:Float = 0

protocol PlayerCtrViewDelegate{
    
    func onPauseStatusChange(pause:Bool)
    func onSliderChangeValue(_ value:Float)
}

class PlayerCtrView: UIView {

    var delegate:PlayerCtrViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapEvent(ges:)))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews(){
     
        addSubview(progressSlider)
        progressSlider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(20 )
        }
        
        addSubview(progressLabel)
        progressLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(progressSlider)
            make.bottom.equalTo(progressSlider.snp_top).offset(-4)
        }
        
        addSubview(pauseBtn)
        pauseBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalTo(progressSlider)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        
        addSubview(fullBtn)
        fullBtn.snp.makeConstraints { (make) in
            make.left.equalTo(progressSlider.snp_right).offset(10)
            make.centerY.equalTo(progressSlider)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
    }
    
    @objc func tapEvent(ges:UIGestureRecognizer){
        pauseBtn.isSelected = !pauseBtn.isSelected
        delegate?.onPauseStatusChange(pause: pauseBtn.isSelected)
    }
    
    @objc func pauseBtnClick(btn:UIButton){
        btn.isSelected = !btn.isSelected
                
        delegate?.onPauseStatusChange(pause: btn.isSelected)
    }
    
    @objc func fullBtnClick(btn:UIButton){
        
    }
    
    @objc func sliderValueChange(slider:UISlider){
        
        delegate?.onSliderChangeValue(slider.value/PROGRESS_SLIDER_MAXVALUE)
    }
    
    lazy var progressLabel:UILabel = {
        let progressLabel = UILabel()
        progressLabel.textColor = .white
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textAlignment = .center
        progressLabel.text = "00:00"
        
        return progressLabel
    }()
    
    lazy var pauseBtn:UIButton = {
        
        let pauseBtn = UIButton.init(type: .custom)
        pauseBtn.setBackgroundImage(UIImage.init(named: "pause"), for: .normal)
        pauseBtn.setBackgroundImage(UIImage.init(named: "playing"), for: .selected)
        pauseBtn.addTarget(self, action: #selector(pauseBtnClick(btn:)), for: .touchUpInside)
        return pauseBtn
    }()
    
    lazy var fullBtn:UIButton = {
        
        let fullBtn = UIButton.init(type: .custom)
        fullBtn.setBackgroundImage(UIImage.init(named: "fullscreen"), for: .normal)
        fullBtn.addTarget(self, action: #selector(fullBtnClick(btn:)), for: .touchUpInside)
        return fullBtn
    }()
    
    lazy var progressSlider:UISlider = {
        let progresSlider = UISlider()
        progresSlider.setThumbImage(UIImage.init(named: "sliderIcon"), for: .normal)
        progresSlider.maximumValue = PROGRESS_SLIDER_MAXVALUE
        progresSlider.minimumValue = PROGRESS_SLIDER_MINVALUE
        progresSlider.minimumTrackTintColor = UIColor.colorWithHex(rgb: 0xFA2337)
        progresSlider.maximumTrackTintColor = UIColor.colorWithHex(rgb: 0xFFFFFF,alpha: 0.5)
        progresSlider.setThumbImage(UIImage(named:"axis_time"), for: .normal)
        progresSlider.value = 5
        progresSlider.addTarget(self, action: #selector(sliderValueChange(slider:)), for: .valueChanged)
        
        return progresSlider
    }()
}
