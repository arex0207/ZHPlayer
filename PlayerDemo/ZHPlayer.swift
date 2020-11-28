//
//  ZHPlayer.swift
//  DonewLive
//
//  Created by Arex on 2019/11/29.
//  Copyright © 2019 Donew. All rights reserved.
//

import UIKit

import AVKit

typealias completionHandler = (_ finished:Bool) -> Void

@objc public enum ZHPlayerStatus:Int {
    
    case    Unknow //未知状态
    case    Playing //正在播放
    case    Paused //暂停
    case    Stopped //停止
    case    Failed//播放失败
    case    Error //出错
    case    Completed //完成
    case    Cacheing//正在缓存
    case    Cached//缓存好了
    case    Ready//准备好播放
}

public enum ZHPlayerOrientation:Int {
    
    case    Landscape //横屏
    case    Portrait //竖屏
}

protocol ZHPlayerDelegate: NSObjectProtocol {
    
    //更新播放时间（当前播放时间、总时间）
    func updatePlayerTimeValue(currentTime:Float64, totalTime:Float64)
    //更新播放状态（播放状态）
    func updatePlayerStatus(status:ZHPlayerStatus)
    //更新缓存时间（开始时间、缓存时间、总时长）
//    func updateLoadedTime(startTime:Float, durationTime:Float, totalTime:Float)
    //已完成定点播放
    func seekToCompleted(isCompleted:Bool)
    //获取视频分辨率
    func updateVideoResolution(size:CGSize)
}

class ZHPlayer: NSObject {

    var delegate:ZHPlayerDelegate?
    var _url:URL?
    var status:ZHPlayerStatus = .Unknow

    var player:AVPlayer?//播放器
    fileprivate var playerLayer:AVPlayerLayer?//显示视频的图层
    fileprivate var urlAsset:AVURLAsset?
    fileprivate var playerItem:AVPlayerItem?//媒体资源管理对象
    var playerItemContext:Any?
    var timeObserver:NSObject?//实时监听者
    
    fileprivate var playerView:UIView?
    var launchView:UIView?//视频封面
    
    var currentTime:Float64 = 0.0//当前时间
    var totalDuration:Float64 = 0.0//视频总时长
    var videoSize:CGSize = CGSize.zero//视频分辨率
    
    var loopPlay:Bool = false//是否循环播放
    fileprivate var isFullScreen:Bool = false//是否全屏播放
    var isPlaying:Bool = false//是否正在播放
    var isPaused:Bool = false//已暂停
    var isMuted:Bool = false//是否静音
    
    convenience init(containerView:UIView)
    {
        self.init()
        playerView = containerView
        
        initPlayer()
    }
    
    private func initPlayer() {
        
        self.player = AVPlayer()
        self.player?.volume = 3
        self.player?.isMuted = false
        isPlaying = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func preparePlayer(){
        
        playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer!.videoGravity = .resizeAspectFill
        playerLayer!.frame = self.playerView!.bounds
//        self.playerView!.layer.addSublayer(playerLayer!)
        self.playerView!.layer.insertSublayer(playerLayer!, at: 0)
    }

    private func updatePlayerLayerFrame(){
        playerLayer!.frame = self.playerView!.bounds
    }
    
    @objc private func switchToForeground(){
        print("应用进入Active")
        pause()
    }
    
    @objc private func switchToBackground(){
        print("应用进入进入后台")
        play()
    }
    
    func setPlayUrl(videoUrl:URL){
        stop()
        
        self._url = videoUrl
        self.playerItem = AVPlayerItem.init(url: videoUrl)
        self.player?.replaceCurrentItem(with: self.playerItem)
        addObserver()
    }
    
    //播放
    func play(){
        
        updatePlayerLayerFrame()
        if(!isPlaying){
            player?.play()
            isPlaying = true
            isPaused = false
        }
    }
    
    //暂停
    func pause(){
        
        if(isPlaying){
            player?.pause()
            isPlaying = false
            isPaused = true
        }
    }
    
    //停止播放器 -- 切换视频源的时候调用
    func stop(){
        pause()
        player?.currentItem?.cancelPendingSeeks()
        player?.currentItem?.asset.cancelLoading()
        removeObserver()
        _url = nil
        playerItem = nil
        player?.replaceCurrentItem(with: nil)
    }
    
    //重置播放器 -- 退出播放页面和刚进入播放页面的时候调用
    func reset(){
        
        pause()
        player?.currentItem?.cancelPendingSeeks()
        player?.currentItem?.asset.cancelLoading()
        removeObserver()
        _url = nil
        playerItem = nil
        playerLayer = nil
        timeObserver = nil
        player?.replaceCurrentItem(with: nil)
    }
    
    //静音设置(暂时保留设置)
    private func mute(_ value:Bool){
        
        isMuted = value
        player?.isMuted = value
    }
    
    private func addObserver(){
        
        let _totalTime:Float64 = CMTimeGetSeconds((self.player?.currentItem?.duration)!).isNaN ? 0 : Float64(CMTimeGetSeconds((self.player?.currentItem?.duration)!))
        self.totalDuration = _totalTime
        
        //实时的获取播放时长
        self.timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 60), queue: DispatchQueue.main) { [weak self] (time) in
            guard self?.player?.currentItem != nil else {
                return
            }
            
            let _currentTime:Float64 = (CMTimeGetSeconds(time).isNaN ? 0 : Float64(CMTimeGetSeconds(time)))
            let _totalTime:Float64 = CMTimeGetSeconds((self?.player?.currentItem?.duration)!).isNaN ? 0 : Float64(CMTimeGetSeconds((self?.player?.currentItem?.duration)!))
            
            self!.currentTime = _currentTime
            self!.totalDuration = _totalTime
            
            //更新进度显示
            self?.delegate?.updatePlayerTimeValue(currentTime: _currentTime, totalTime: _totalTime)
            
        } as? NSObject
        
        
        //playerItem-添加监听
        //添加播放结束的监听
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        //播放状态
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //获取视频分辨率
        player?.currentItem?.addObserver(self, forKeyPath: "presentationSize", options: .new, context: nil)
        //加载的缓存时间
        player?.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        //已缓冲
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        //缓存不够(正在缓存)
        player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        //缓存ok,可播放
        player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new,context:nil)
        
    }
    
    private func removeObserver(){
        
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.currentItem?.removeObserver(self, forKeyPath: "presentationSize")
        player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    //定点播放
    func seekToTime(seconds:Float,handler:@escaping completionHandler ){
        
        self.player?.seek(to: CMTime.init(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC)), completionHandler: { (finished) in
            
            handler(finished)
            self.delegate?.seekToCompleted(isCompleted: finished)
        })
    }
    
    //播放结束的监听
    @objc fileprivate func playToEndTime() {
        self.player?.seek(to: CMTime.zero)//回退到0
        isPlaying = false
        isPaused = true
        self.delegate?.updatePlayerStatus(status: .Completed)
        if loopPlay {
            player?.play()
        }
    }
    
    //MARK: - 监听方法
    //playerItem的监听
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard let item = self.player?.currentItem else { return }
        
        if keyPath == "status" {//播放状态
            switch item.status{
            case .readyToPlay:
                //准备播放
                delegate?.updatePlayerStatus(status: .Ready)
            case .failed:
                //播放失败
                delegate?.updatePlayerStatus(status: .Failed)
            case.unknown:
                //未知情况
                delegate?.updatePlayerStatus(status: .Unknow)
            @unknown default:
                break
            }
        }else if keyPath == "presentationSize"{
            
            videoSize = item.presentationSize
            
            delegate?.updateVideoResolution(size: videoSize)
            
            print("videoSize:\(videoSize)")
            
        }else if keyPath == "loadedTimeRanges"{//加载的缓存区间
            
//            let loadTimeArray = item.loadedTimeRanges
//            //获取最新缓存的区间
//            guard let newTimeRange : CMTimeRange = loadTimeArray.first as? CMTimeRange else { return }
//            let startSeconds = CMTimeGetSeconds(newTimeRange.start)
//            let durationSeconds = CMTimeGetSeconds(newTimeRange.duration)
//            let totalBuffer = startSeconds + durationSeconds//缓冲总长度
//
//            let totalSeconds = CMTimeGetSeconds(item.duration)//总时长
//            self.totalDuration = totalSeconds
//            self.delegate?.updateLoadedTime(startTime: startSeconds.isNaN ? 0 : Float(startSeconds), durationTime: durationSeconds.isNaN ? 0 : Float(durationSeconds), totalTime: totalSeconds.isNaN ? 0 : Float(totalSeconds))
        } else if keyPath == "playbackBufferEmpty"{
            
            //正在缓存
            if item.isPlaybackBufferEmpty{
                delegate?.updatePlayerStatus(status: .Cacheing)
            }
        } else if keyPath == "playbackLikelyToKeepUp"{
            
            //缓存好了
            delegate?.updatePlayerStatus(status: .Cached)
        }
    }
    
    //转时间格式
    func changeTimeFormat(time:Float64) -> String{
        
        let value = Int(time)
        
        let h = value/3600
        let m = value/60
        let s = value%60
        
        print(String(format: "%02d:%02d:%02d",h,m,s))
        
        let str = h < 1 ? String(format: "%02d:%02d",m,s):String(format: "%02d:%02d:%02d",h,m,s)
        return str
    }
}
