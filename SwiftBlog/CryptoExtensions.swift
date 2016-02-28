//
//  CryptoExtensions.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 24/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

#if os(OSX)
    import CommonCrypto
#else
    import OpenSSL
#endif

extension String {
    public var md5: [UInt8] {
        #if os(Linux)
            let bytes = UnsafeMutablePointer<UInt8>.alloc(Int(MD5_DIGEST_LENGTH))
            defer { bytes.destroy() ; bytes.dealloc(Int(MD5_DIGEST_LENGTH)) }
            
            MD5(Array<UInt8>(self.utf8), (self.utf8.count), bytes)
            
            var r = [UInt8]()
            for idx in 0..<Int(MD5_DIGEST_LENGTH) {
                r.append(bytes[idx])
            }
        #else
            let bytes = UnsafeMutablePointer<UInt8>.alloc(Int(CC_MD5_DIGEST_LENGTH))
            defer { bytes.destroy() ; bytes.dealloc(Int(CC_MD5_DIGEST_LENGTH)) }
            
            CC_MD5(Array<UInt8>(self.utf8), CC_LONG(self.utf8.count), bytes)
            
            var r = [UInt8]()
            for idx in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                r.append(bytes[idx])
            }
        #endif
        return r
    }
}

func toHex(a: [UInt8]) -> String {
    var s = ""
    for i8 in a {
        let b = i8 >> 4
        s.append(UnicodeScalar(b > 9 ? b - 10 + 65 : b + 48))
        
        let b2 = i8 & 0x0F
        s.append(UnicodeScalar(b2 > 9 ? b2 - 10 + 65 : b2 + 48))
    }
    return s.lowercaseString
}
