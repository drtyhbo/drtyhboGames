//
//  ViewController.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Metal
import QuartzCore
import UIKit

class ViewController: UIViewController {
    var device: MTLDevice!
    var displayLink: CADisplayLink!

    private var movementJoypad: SpriteInstance!
    private var shootingJoypad: SpriteInstance!
    private var pauseDate: NSDate?

    lazy private var touchHandler: TouchHandler = {
        [unowned self] in
        let touchHandler = TouchHandler()
        touchHandler.delegate = self
        return touchHandler
        }();

    // MARK: UIViewController overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMetal()

        displayLink = UIScreen.mainScreen().displayLinkWithTarget(self, selector: "nextFrame:")
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)

        let sprite = SpriteManager.sharedManager.createSpriteWithSize(float2(100, 100))
        movementJoypad = sprite.createInstance()
        shootingJoypad = sprite.createInstance()

        view.multipleTouchEnabled = true
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        touchHandler.touchesBegan(touches)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        touchHandler.touchesMoved(touches)
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        if let touches = touches {
            touchHandler.touchesEnded(touches)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        touchHandler.touchesEnded(touches)
    }

    private func setupMetal() {
        device = MTLCreateSystemDefaultDevice()

        let metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = Constants.Metal.pixelFormat
        metalLayer.framebufferOnly = false
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)

        GameManager.sharedManager.setupWithDevice(device, renderManager: RenderManager(device: device, metalLayer: metalLayer))
    }
    
    @objc private func nextFrame(displayLink: CADisplayLink) {
        let isPaused = touchHandler.numTouches == 0 && GameManager.sharedManager.gameState.state == .Playing
        handlePause(isPaused)

        GameManager.sharedManager.nextFrameWithTimestamp(displayLink.timestamp)
    }

    private func handlePause(isPaused: Bool) {
        GameManager.sharedManager.isPaused = isPaused

        if !isPaused {
            pauseDate = nil
            return
        }

        if let pauseDate = pauseDate {
            let timeSincePause = Float(NSDate().timeIntervalSinceDate(pauseDate))
            if timeSincePause > Constants.UI.gamePauseHelperTime {
                let screenSize = float2(Float(UIScreen.mainScreen().bounds.width), Float(UIScreen.mainScreen().bounds.height))
                movementJoypad.position = float2(20, screenSize[1] - 20 - movementJoypad.size[1])
                shootingJoypad.position = float2(screenSize[0] - 20 - movementJoypad.size[0], screenSize[1] - 20 - movementJoypad.size[1])

                let alpha = Float(abs(sin(timeSincePause - Constants.UI.gamePauseHelperTime)))
                movementJoypad.alpha = alpha
                shootingJoypad.alpha = alpha
            }
        } else {
            pauseDate = NSDate()
        }
    }

    private func getJoypadSpriteInstanceFromTouchType(touchType: TouchHandler.TouchType) -> SpriteInstance {
        return touchType == .Movement ? movementJoypad : shootingJoypad
    }

    private func showJoypadForTouchType(touchType: TouchHandler.TouchType, atLocation location: float2) {
        let joypadSpriteInstance = getJoypadSpriteInstanceFromTouchType(touchType)
        joypadSpriteInstance.position = location - (joypadSpriteInstance.size * 0.5)
        joypadSpriteInstance.alpha = 1
    }
}

extension ViewController: TouchHandlerDelegate {
    func touchHandler(touchHandler: TouchHandler, didBeginTouchWithLocation location: float2, forTouchType touchType: TouchHandler.TouchType) {
        showJoypadForTouchType(touchType, atLocation: location)
    }

    func touchHandler(touchHandler: TouchHandler, didMoveWithLocation location: float2, direction: float2, forTouchType touchType: TouchHandler.TouchType) {
        if let player = GameManager.sharedManager.player {
            if touchType == .Movement {
                player.setVelocity(float3(direction, 0))
            } else {
                player.setShootingDirection(float3(direction, 0))
            }

            showJoypadForTouchType(touchType, atLocation: location)
        }
    }

    func touchHandler(touchHandler: TouchHandler, didEndForTouchType touchType: TouchHandler.TouchType) {
        if let player = GameManager.sharedManager.player {
            if touchType == .Movement {
                player.stop()
            } else {
                player.stopShooting()
            }

            getJoypadSpriteInstanceFromTouchType(touchType).alpha = 0
        }
    }
}