//
//  ViewController.swift
//  PlayerDemo
//
//  Created by Arex on 2020/11/27.
//

import UIKit

import SnapKit

class ViewController: UIViewController {

    private var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        initPlayer()
    }
    
    private func initPlayer(){
        
        if let videoUrl = URL(string: "http://vfx.mtime.cn/Video/2019/03/14/mp4/190314223540373995.mp4") {
            url = videoUrl
            player.preparePlayer()
            player.setPlayUrl(videoUrl: videoUrl)
        }else{
            print("视频链接有误!")
        }
    }
    
    lazy var player:ZHPlayer = {
        
        let player = ZHPlayer.init(containerView: playerView)
        player.delegate = self
        player.loopPlay = true
        
        return player
    }()
    
    private func setupUI(){
        
        view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(240)
        }
        
        playerView.addSubview(playerCtrView)
        playerCtrView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    lazy var playerView:UIView = {
        let playerView = UIView()
        
        return playerView
    }()
    
    lazy var playerCtrView:PlayerCtrView = {
        let playerCtrView = PlayerCtrView()
        playerCtrView.delegate = self
        
        return playerCtrView
    }()
}

extension ViewController:PlayerCtrViewDelegate{
    
    func onPauseStatusChange(pause: Bool) {
        if pause {
            player.pause()
        }else if !pause,!player.isPlaying{
            player.play()
        }
    }
    
    func onSliderChangeValue(_ value: Float) {
        
        print("slider value:\(value)")
        player.pause()
        player.seekToTime(seconds: value * Float(player.totalDuration)) { (finished) in
            
        }
    }
}

extension ViewController:ZHPlayerDelegate{
    
    //MARK: - 代理
    //告知代理对象播放器状态变更
    func updatePlayerTimeValue(currentTime: Float64, totalTime: Float64) {
        
        let timeStr:String = String.init(format: "%@/%@", String(describing: player.changeTimeFormat(time:currentTime)),String(describing: player.changeTimeFormat(time:totalTime)))
        playerCtrView.progressLabel.text = timeStr
        
        if player.isPlaying {
            playerCtrView.progressSlider.setValue(Float(currentTime/totalTime)*PROGRESS_SLIDER_MAXVALUE, animated: true)
        }
    }
    
    func updatePlayerStatus(status: ZHPlayerStatus) {
        
        print("player -- \(status)")

        switch status {
        case .Unknow:
            break
        case .Failed:
            break
        case .Error:
            break
        case .Cacheing:
            player.pause()
            break
        case .Cached:
            player.play()
            break
        case .Playing:
            break
        case .Paused:
            break
        case .Stopped:
            break
        case .Ready:
            break
        case .Completed:
            break
        }
    }
    
    func seekToCompleted(isCompleted: Bool) {
        self.player.play()
    }
    
    func updateVideoResolution(size: CGSize) {
        
        
    }
}
