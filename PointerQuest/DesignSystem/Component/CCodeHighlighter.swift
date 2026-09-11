import SwiftUI

/// C 코드 스니펫에 키워드·문자열·주석 색상을 입혀 AttributedString으로 변환하는 유틸리티
/// `Text(LocalizedStringResource)`의 자동 마크다운 파싱을 거치지 않고 직접 색을 입히기 위한 용도로 사용한다
enum CCodeHighlighter {
  private static let keywords: Set<String> = [
    "int", "char", "float", "double", "void", "long", "short",
    "struct", "const", "static", "return", "printf", "sizeof", "NULL"
  ]

  static func highlight(_ code: String) -> AttributedString {
    let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
    var result = AttributedString()

    for (index, line) in lines.enumerated() {
      result += highlightLine(String(line))
      if index != lines.count - 1 {
        result += AttributedString("\n")
      }
    }

    return result
  }

  /// 한 줄을 "// 이전 코드"와 "// 주석"으로 나눠 각각 채색
  private static func highlightLine(_ line: String) -> AttributedString {
    guard let commentRange = line.range(of: "//") else {
      return highlightCode(line)
    }

    let codePart = String(line[line.startIndex..<commentRange.lowerBound])
    let commentPart = String(line[commentRange.lowerBound...])

    var comment = AttributedString(commentPart)
    comment.foregroundColor = .green

    return highlightCode(codePart) + comment
  }

  /// 주석을 제외한 코드 부분에서 키워드와 문자열 리터럴에 색을 입힌다
  ///
  /// 키워드는 `Main`이 아니라 `CodeKeyword`를 쓴다. 코드 패널은 시스템 모드와 무관하게
  /// 항상 어두운 배경(`Color(white: 0.15)`)이라, 라이트 배경 기준으로 어두워진 `Main`을
  /// 그대로 쓰면 대비가 나오지 않는다 — 에디터 팔레트는 별도 축이다(`VISUAL_LANGUAGE.md` §6)
  private static func highlightCode(_ code: String) -> AttributedString {
    var result = AttributedString()
    var token = ""
    var stringLiteral: String?

    func flushToken() {
      guard !token.isEmpty else { return }
      var attributed = AttributedString(token)
      attributed.foregroundColor = keywords.contains(token) ? Color(.codeKeyword) : .white
      result += attributed
      token = ""
    }

    for character in code {
      if var literal = stringLiteral {
        literal.append(character)
        if character == "\"" {
          var attributed = AttributedString(literal)
          attributed.foregroundColor = .orange
          result += attributed
          stringLiteral = nil
        } else {
          stringLiteral = literal
        }
        continue
      }

      if character == "\"" {
        flushToken()
        stringLiteral = String(character)
        continue
      }

      if character.isLetter || character == "_" {
        token.append(character)
      } else {
        flushToken()
        var punctuation = AttributedString(String(character))
        punctuation.foregroundColor = .white
        result += punctuation
      }
    }
    flushToken()

    return result
  }
}
