#!/usr/bin/env swift

import Foundation

extension String {
	mutating func regReplace(pattern: String, replaceWith: String = "") {
		do {
			let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
			let range = NSRange(location: 0, length: count)
			self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
		} catch { return }
	}
}

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}

let url_CHS_MCBP = "../components/chs/phrases-mcbp-chs.txt"
let url_CHS_MOE = "../components/chs/phrases-moe-chs.txt"
let url_CHS_VCHEW = "../components/chs/phrases-vchewing-chs.txt"
let url_CHT_MCBP = "../components/cht/phrases-mcbp-cht.txt"
let url_CHT_MOE = "../components/cht/phrases-moe-cht.txt"
let url_CHT_VCHEW = "../components/cht/phrases-vchewing-cht.txt"

var textCHS = ""
var textCHT = ""

// 档案载入
do {
	textCHS += "@# phrases-moe-chs.txt\n"
	textCHS += try String(contentsOfFile: url_CHS_MOE, encoding: .utf8)
	textCHS += "\n@# phrases-mcbp-chs.txt\n"
	textCHS += try String(contentsOfFile: url_CHS_MCBP, encoding: .utf8)
	textCHS += "\n@# phrases-moe-vchewing.txt\n"
	textCHS += try String(contentsOfFile: url_CHS_VCHEW, encoding: .utf8)
}
catch {print("Exception happened when reading raw CHS data.")}

do {
	textCHT += "@# phrases-moe-cht.txt\n"
	textCHT += try String(contentsOfFile: url_CHT_MOE, encoding: .utf8)
	textCHT += "\n@# phrases-mcbp-cht.txt\n"
	textCHT += try String(contentsOfFile: url_CHT_MCBP, encoding: .utf8)
	textCHT += "\n@# phrases-moe-vchewing.txt\n"
	textCHT += try String(contentsOfFile: url_CHT_VCHEW, encoding: .utf8)
}
catch {print("Exception happened when reading raw CHT data.")}

// 转成 Vector
var arrData = textCHS.components(separatedBy: "\n")
var varLineData = ""
var strProcessed = ""
for lineData in arrData {
	varLineData = lineData
	varLineData.regReplace(pattern: "　", replaceWith: " ") // CJKWhiteSpace to ASCIISpace
	varLineData.regReplace(pattern: " ", replaceWith: " ") // NonBreakWhiteSpace to ASCIISpace
	varLineData.regReplace(pattern: "\\s+", replaceWith: " ") // Consolidating Consecutive Spaves
	varLineData.regReplace(pattern: "^\\s", replaceWith: "") // Trim Leading Space
	varLineData.regReplace(pattern: "\\s$", replaceWith: "") // Trim Trailing Space
	varLineData.regReplace(pattern: "^#.*$", replaceWith: "") // Make Comment Lines Empty
	strProcessed += varLineData
	strProcessed += "\n"
}
arrData = strProcessed.components(separatedBy: "\n")
let arrCHS = Array(NSOrderedSet(array: arrData).array as! [String]) // Deduplication

arrData = textCHT.components(separatedBy: "\n")
varLineData = ""
strProcessed = ""
for lineData in arrData {
	varLineData = lineData
	varLineData.regReplace(pattern: "　", replaceWith: " ") // CJKWhiteSpace to ASCIISpace
	varLineData.regReplace(pattern: " ", replaceWith: " ") // NonBreakWhiteSpace to ASCIISpace
	varLineData.regReplace(pattern: "\\s+", replaceWith: " ") // Consolidating Consecutive Spaves
	varLineData.regReplace(pattern: "^\\s", replaceWith: "") // Trim Leading Space
	varLineData.regReplace(pattern: "\\s$", replaceWith: "") // Trim Trailing Space
	varLineData.regReplace(pattern: "^#.*$", replaceWith: "") // Make Comment Lines Empty
	strProcessed += varLineData
	strProcessed += "\n"
}
arrData = strProcessed.components(separatedBy: "\n")
let arrCHT = Array(NSOrderedSet(array: arrData).array as! [String]) // Deduplication

// Print Out
for lineData in arrCHT {
	varLineData = lineData
	print(varLineData)
}
print("@@@@@@@@@@@@@@@@@@@@")
for lineData in arrCHS {
	varLineData = lineData
	print(varLineData)
}