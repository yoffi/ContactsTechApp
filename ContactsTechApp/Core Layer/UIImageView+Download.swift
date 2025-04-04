//
//  UIImageView+Download.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import UIKit

extension UIImageView {
  static var ImageDataLoader: ImageDataLoader = .init()
  
  func loadImage(from url: URL) async {
    guard let (dataImage, isFromCache) = try? await UIImageView.ImageDataLoader.download(url: url),
          let image = UIImage(data: dataImage) else {
      return
    }
    guard !Task.isCancelled else { return }

    await MainActor.run {
      if isFromCache {
        self.image = image
      } else {
        UIView.transition(with: self,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
          self.image = image
        })
      }
    }
  }
}
