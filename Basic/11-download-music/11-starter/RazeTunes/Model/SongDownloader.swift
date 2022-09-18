import SwiftUI

class SongDownloader: ObservableObject {
  @Published var downloadLocation: URL?
  
  private let session: URLSession
  private let config: URLSessionConfiguration
  
  init() {
    self.config = URLSessionConfiguration.default
    self.session = URLSession(configuration: self.config)
  }
}

extension SongDownloader {
  func downloadSong(url: URL) async {
    // 다운받고 있는 임시 location을 반환, 이를 영구 저장소에 따로 저장 필요. 여기서는 FileManager 이용
    guard let (downloadURL, response) = try? await session.download(from: url) else {
      print("Error Downloading")
      return
    }
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      print("invalid response statusCode")
      return
    }
    
    // 다운받은 것을 FileManager로 영구 저장
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("download failed")
      return
    }
    
    let lastPathCompoment = url.lastPathComponent
    let destionationURL = documentDirectory.appendingPathComponent(lastPathCompoment)
    
    do {
      if fileManager.fileExists(atPath: destionationURL.path) {
        try fileManager.removeItem(at: destionationURL)
      }
      
      try fileManager.copyItem(at: downloadURL, to: destionationURL)
      await MainActor.run {
        downloadLocation = destionationURL
      }
    } catch {
      print("failed to store the song")
    }
  }
}
