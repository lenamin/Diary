

import UIKit

protocol DiaryDetailViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
}// 일기를 삭제하기 위한 delegate

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: DiaryDetailViewDelegate?
    
    
    // 일기장에서 전달받을 프로퍼티를 선언한다
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView() // 일기장 리스트화면에서 일기장을 선택했을 때 다이어리 프로퍼티에 다이어리 객체를 넘겨주게 되면 일기장 상세화면에 제목, 날짜가 표시된다.
    }
    
    // 프로퍼티를 통해 전달받은 다이어리 객체를 View에 초기화 시켜준다
    private func configureView() {
        guard let diary = self.diary else { return } // 옵셔널 바인딩해서 초기화 한 것
        self.titleLabel.text = diary.title // diary의 제목이 표시되게
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        // date 타입으로 되어 있으므로 dateformatter로 문자열을 만들어준다. 
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter() // dateFormatter() 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        // 데이터포맷이 한국어로 표시되도록
        return formatter.string(from:date)
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteDiaryViewController") as? WriteDiaryViewController else {return}
        // instantiateViewController 메서드를 통해 "WriteDiaryViewController"에 인스턴스를 가져온다.
        
        
        // 열거형에서 정의했던 값을 가져온다
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        
        viewController.diaryEditorMode = .edit(indexPath, diary)
        // 열거형값 edit을 전달하고 연관값을 전달한다
        // -> 수정 버튼을 누르면 객체들이 전달된다
        
        self.navigationController?.pushViewController(viewController, animated: true)
        // writeDiaryViewController화면으로 푸쉬되도록 설정한다
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {return}
        self.delegate?.didSelectDelete(indexPath: indexPath)
            // delegate에서 정의한 didSelectDelete 메서드를 호출해서 indexPath를 전달해준다
        self.navigationController?.popViewController(animated: true)
            // 삭제한 이후에는 전화면으로 이동하도록 한다
    }
}
