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
        movementJoypad.hidden = true
        shootingJoypad = sprite.createInstance()
        shootingJoypad.hidden = true

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
        GameManager.sharedManager.isPaused = movementJoypad.hidden && shootingJoypad.hidden && GameManager.sharedManager.gameState.state == .Playing
        GameManager.sharedManager.nextFrameWithTimestamp(displayLink.timestamp)
    }

    private func getJoypadSpriteInstanceFromTouchType(touchType: TouchHandler.TouchType) -> SpriteInstance {
        return touchType == .Movement ? movementJoypad : shootingJoypad
    }
}

extension ViewController: TouchHandlerDelegate {
    func touchHandler(touchHandler: TouchHandler, center: float2, direction: float2, forTouchType touchType: TouchHandler.TouchType) {
        if let player = GameManager.sharedManager.player {
            if touchType == .Movement {
                player.setVelocity(float3(direction, 0))
            } else {
                player.setShootingDirection(float3(direction, 0))
            }

            let joypadSpriteInstance = getJoypadSpriteInstanceFromTouchType(touchType)
            joypadSpriteInstance.position = float2(center[0] - joypadSpriteInstance.size[0] / 2, center[1] - joypadSpriteInstance.size[1] / 2)
            joypadSpriteInstance.hidden = false
        }
    }

    func touchHandler(touchHandler: TouchHandler, didEndForTouchType touchType: TouchHandler.TouchType) {
        if let player = GameManager.sharedManager.player {
            if touchType == .Movement {
                player.stop()
            } else {
                player.stopShooting()
            }

            getJoypadSpriteInstanceFromTouchType(touchType).hidden = true
        }
    }
}