/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

func fetchDomains() async throws -> [Domain] {
  let url = URL(string: "https://api.raywenderlich.com/api/domains")!
  let (data, _) = try await URLSession.shared.data(from: url)
  
  return try JSONDecoder().decode(Domains.self, from: data).data
}

func findTitle(url: URL) async throws -> String? {
    for try await line in url.lines {
        if line.contains("<title>") {
            return line.trimmingCharacters(in: .whitespaces)
        }
    }
    
    return nil
}

Task {
    if let title = try await findTitle(url: URL(string: "https://www.raywenderlich.com")!) {
        print(title)
    }
}

extension Domains {
    static var domains: [Domain]{
        // read only 값도 asynchronous 될 수 있음
        get async throws {
            try await fetchDomains()
        }
    }
    
    enum Error: Swift.Error { case outOfRange}
    
    static subscript (_ idx: Int) -> String {
        get async throws {
            let domains = try await Self.domains
            
            guard domains.indices.contains(idx) else {
                throw Error.outOfRange
            }
            
            return domains[idx].attributes.name
        }
    }
}

Task {
    dump(try await Domains.domains)
}

Task {
    dump(try await Domains[4])
}

// actor
// class와 마찬가지로 reference type, 다만 thread safe, 은행 알고리즘 참고

let favoriteList = Playlist(title: "favorite", author: "author", songs: ["song1"])
let partyList = Playlist(title: "party", author: "party", songs: ["hello"])

Task { // await를 통해 safe safe, concurrency safe 해짐, add하거나 단순히 call할 때는 await를 쓸 필요 없음
    
    await favoriteList.move(song: "hello", from: partyList)
    await favoriteList.move(song: "song1", to: partyList)
    
    await print(favoriteList.songs)
    await print(partyList.songs)
}

// main actor
let url = URL(string: "https://api.raywenderlich.com/api/domains")!
let session = URLSession.shared.dataTask(with: url) { data, _, _ in
    guard let data = data,
          let domain = try? JSONDecoder().decode(Domains.self, from: data).data.first else {
              print("failed")
              return
          }
    
    Task {
        await MainActor.run(body: {
            print(domain)
            print(Thread.isMainThread)
        })
    }
    
    // 위와 아래는 동일
    Task { @MainActor in
        
    }
}

session.resume()

extension Domains {
    
    // 항상 Main Thread 동작, 받을 때 await로 받아야 함
    @MainActor func domainNames() -> [String] {
        return data.map { $0.attributes.name }
    }
}

URLSession.shared.dataTask(with: URL(string: "")!) { data, _, _ in
    
    guard let data = data,
          let domain = try? JSONDecoder().decode(Domains.self, from: data) else {
              print("failed")
              return
          }
    
    // 그냥 쓰면 아래와 같은 경고 발생
    // Call to main actor-isolated instance method 'domainNames()' in a synchronous nonisolated context; this is an error in Swift 6
    print(domain.domainNames())
    
    // 아래와 같이 써야 함
    Task {
        await print(domain.domainNames())
    }
}
