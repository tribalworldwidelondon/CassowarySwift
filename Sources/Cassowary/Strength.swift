/*

 Copyright (c) 2017, Tribal Worldwide London
 Copyright (c) 2015, Alex Birkett
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 * Neither the name of kiwi-java nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */


public class Strength {

    public static var REQUIRED: Double = create(1000.0, 1000.0, 1000.0)

    public static var STRONG: Double = create(1.0, 0.0, 0.0)

    public static var MEDIUM: Double = create(0.0, 1.0, 0.0)

    public static var WEAK: Double = create(0.0, 0.0, 1.0)


    public static func create(_ a: Double, _ b: Double, _ c: Double, _ w: Double) -> Double {
        var result = 0.0
        result += max(0.0, min(1000.0, a * w)) * 1000000.0
        result += max(0.0, min(1000.0, b * w)) * 1000.0
        result += max(0.0, min(1000.0, c * w))
        return result
    }

    public static func create(_ a: Double, _ b: Double, _ c: Double) -> Double {
        return create(a, b, c, 1.0)
    }

    public static func clip(_ value: Double) -> Double {
        return max(0.0, min(REQUIRED, value))
    }
    
    public static func readableString(_ strength: Double) -> String {
        switch strength {
        case Strength.REQUIRED:
            return "REQUIRED"
        case Strength.STRONG:
            return "STRONG"
        case Strength.MEDIUM:
            return "MEDIUM"
        case Strength.WEAK:
            return "WEAK"
        default:
            return "\(strength)"
        }
    }

}
