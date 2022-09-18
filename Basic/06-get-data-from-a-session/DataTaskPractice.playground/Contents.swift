// Data Task
// 1. URLSessionDataTask
// 메모리상 response 존재, 백그라운드 지원하지 않음
// 2. URLSessionUploadTask
// request body 작성이 좀 더 용이
// 3. URLSessionDownloadTask
// 결과가 디스크에 쓰임, 디스크에 쓴 location이 return 됨

import SwiftUI

let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)

guard let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=BTS") else {
    fatalError()
}


Task {
    let (data, response) = try await session.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let str = String(data: data, encoding: .utf8) else {
        fatalError()
    }
    
    print(str)
}
