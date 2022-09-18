import Foundation
let sharedSession = URLSession.shared

sharedSession.configuration.allowsCellularAccess = false
sharedSession.configuration.allowsCellularAccess // 여전히 true, read only임

let sessionConfig = URLSessionConfiguration.default
sessionConfig.allowsCellularAccess = true
sessionConfig.allowsCellularAccess

sessionConfig.allowsExpensiveNetworkAccess = true // 셀룰러 네트워크와 개인용 핫스팟을 iOS에서는 expansive로 간주함
sessionConfig.allowsConstrainedNetworkAccess = true // low data 모드 통신 허용

let defaultConfig = URLSessionConfiguration.default
let ephemeralConfig = URLSessionConfiguration.ephemeral // Default와 유사하지만 캐싱처리가 Memory에만 수행, 주로 private한 처리를 하려할 때 사용
let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.background.practice") // identifier로 recreate 가능
