//
//  ViewController.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import GameKit
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

      displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(self.nextFrame(displayLink:)))
        displayLink.frameInterval = 1
      displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)

      let sprite = SpriteManager.sharedManager.createSpriteWithSize(size: float2(100, 100))
        movementJoypad = sprite.createInstance()
        shootingJoypad = sprite.createInstance()

      view.isMultipleTouchEnabled = true

      GKLocalPlayer.local.authenticateHandler = {
            viewController, error in
            if let viewController = viewController {
              self.present(viewController, animated: true, completion: nil)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      touchHandler.touchesBegan(touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesMoved(touches, with: event)
      touchHandler.touchesMoved(touches: touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
      super.touchesCancelled(touches!, with: event)
        if let touches = touches {
          touchHandler.touchesEnded(touches: touches)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      touchHandler.touchesEnded(touches: touches)
    }

    private func setupMetal() {
        device = MTLCreateSystemDefaultDevice()

        let metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = Constants.Metal.pixelFormat
        metalLayer.framebufferOnly = false
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)

      GameManager.sharedManager.setupWithDevice(device: device, renderManager: RenderManager(device: device, metalLayer: metalLayer))
    }
    
    @objc private func nextFrame(displayLink: CADisplayLink) {
        let isPaused = touchHandler.numTouches == 0 && EntityManager.sharedManager.numberOfEnemies > 0
      handlePause(isPaused: isPaused)

      GameManager.sharedManager.nextFrameWithTimestamp(timestamp: displayLink.timestamp)
    }

    private func handlePause(isPaused: Bool) {
        GameManager.sharedManager.isPaused = isPaused

        if !isPaused {
            if pauseDate != nil {
                movementJoypad.alpha = 0
                shootingJoypad.alpha = 0
            }
            pauseDate = nil
            return
        }

        if let pauseDate = pauseDate {
          let timeSincePause = Float(NSDate().timeIntervalSince(pauseDate as Date))
            if timeSincePause > Constants.UI.gamePauseHelperTime {
              let screenSize = float2(Float(UIScreen.main.bounds.width), Float(UIScreen.main.bounds.height))
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
      let joypadSpriteInstance = getJoypadSpriteInstanceFromTouchType(touchType: touchType)
        joypadSpriteInstance.position = location - (joypadSpriteInstance.size * 0.5)
        joypadSpriteInstance.alpha = 1
    }
}

extension ViewController: TouchHandlerDelegate {
    func touchHandler(touchHandler: TouchHandler, didBeginTouchWithLocation location: float2, forTouchType touchType: TouchHandler.TouchType) {
      showJoypadForTouchType(touchType: touchType, atLocation: location)
    }

    func touchHandler(touchHandler: TouchHandler, didMoveWithLocation location: float2, direction: float2, forTouchType touchType: TouchHandler.TouchType) {
        if let player = GameManager.sharedManager.player {
            if touchType == .Movement {
              player.setVelocity(velocity: float3(direction, 0))
            } else {
              player.setShootingDirection(shootingDirection: float3(direction, 0))
            }

          showJoypadForTouchType(touchType: touchType, atLocation: location)
        }
    }

    func touchHandler(touchHandler: TouchHandler, didEndForTouchType touchType: TouchHandler.TouchType) {
        if let player = GameManager.sharedManager.player {
            if touchType == .Movement {
                player.stop()
            } else {
                player.stopShooting()
            }

          getJoypadSpriteInstanceFromTouchType(touchType: touchType).alpha = 0
        }
    }
}
