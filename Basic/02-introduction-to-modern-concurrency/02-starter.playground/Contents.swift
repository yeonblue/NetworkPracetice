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

// actor는 class와 마찬가지로 reference 타입, 단 한번에 한 개 일만 수행 가능.
let task = Task {
    print("First")
    let sum = (1...100000).reduce(0, +)
    
    try Task.checkCancellation()
    print(sum) // cancel이 없다면 Second가 표시되고 결과가 표시될 것임
}

print("Second: main thread/main actor")
task.cancel() // cancel로 인해 1 ~ 100000은 호출이 되지 않음


// 응용
func performTask() async throws {
    Task {
        print("Start")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("End")
    }
}

Task {
    try await performTask()
}

func fetchDomain() async throws -> [Domain] {
    let url = URL(string: "https://api.raywenderlich.com/api/domains")!
    let (data, _) = try await URLSession.shared.data(from: url)
    
    return try JSONDecoder().decode([Domain].self, from: data)
}

Task {
    do {
        let domains = try await fetchDomain()
        
        for (idx, domain) in domains.enumerated() {
            let attr = domain.attributes
            print("\(idx + 1), \(attr.name), \(attr.description), \(attr.level),")
        }
        
    } catch let error {
        print(error.localizedDescription)
    }
}
