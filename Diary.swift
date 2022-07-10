
import Foundation

// 일기장에 작성한 내용을 collection view에 나타내기 위한 구조체를 정의한다

struct Diary {
    var uuidString: String // 일기를 특정할 수 있는 고유한 uuid 값을 넣어줄 예정
    var title: String // 일기의 제목을 저장한다
    var contents: String // 내용을 저장한다
    var date: Date // 일기가 작성된 날짜를 저장한다
    var isStar: Bool // 즐겨찾기 여부를 결정한다
}
