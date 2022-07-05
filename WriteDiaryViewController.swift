

import UIKit

// 수정할 diary 객체를 받을 프로퍼티를 추가한다
enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary) // 연관값으로 indexPath와 Diary객체를 전달받을 수 있도록 전달해준다.
}

// *4 Delegate 정의 : 일기장 리스트 화면에 일기가 작성된 Diary 객체를 전달하기 위해
protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectedRegister(diary: Diary)
} // 일기가 작성된 diary 객체를 전달 할 것

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker() // UIDatePicker 인스턴스로 초기화
    private var diaryDate: Date? // 데이트 피커에 선택된 데이트를 저장하는 프로퍼티
    weak var delegate: WriteDiaryViewDelegate? // Delegate 프로퍼티를 정의한 것 *4
    var diaryEditorMode: DiaryEditorMode = .new // 초기값을 new로 선언 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .black
        // back 버튼 파란색이 보기싫어 검정색으로 변경
        
        self.configureContentsTextView() // 아래에서 만든 configureContentsTextView() 함수를 호출한다
        self.configureDatePicker()
        self.confirmButton.isEnabled = false // 제목, 내용, 날짜에 아무것도 작성 안된 경우인 경우니까 등록버튼을 비활성화되도록 만들어준다.
        self.configureInputField()
    }
    
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date
        // 날짜만 나오도록 설정한다
        
        self.datePicker.preferredDatePickerStyle = .wheels
        
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        // UIController 객체가 이벤트에 응답하는 방식을 설정해주는 메서드
        // 첫 번째 파라미터 : target 설정해준다 (해당 컨트롤러에서 처리할 거니까 self)
        // 두 번째 파라미터 : action (이벤트가 발생했을 때 응답하여 호출될 메서드를 selector로 넘겨준다. selector 안에 넘겨줄 메서드 별도로 만들어야 한다. -> datePickerValueDidChange()메서드 넘겨주기)*1
        // 세 번째 파라미터 : 어떤 이벤트가 일어났을 때 액션에 정의한 메서드를 호출할 것인지 설정한다 (값이 변경될 때 date Picker did change 메서드를 호출한다

        self.dateTextField.inputView = self.datePicker // text field를 선택했을 때 키보드가 뜨는 것이 아닌 datePicker가 뜬다

    }
    
    private func configureInputField(){
        self.contentsTextView.delegate = self
        // UITextViewDelegate를 채택해야 한다 *2에서 extension으로 delegate 채택함
        
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        // 제목 텍스트필드에 텍스트가 입력될 때마다 selector가 받아온 메서드(titleTextFieldDidChange) 를 호출한다
        
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
        // 날짜가 변경될 때마다 selector가 받아온 메서드를 호출한다
    }
    
    //가져온다
    // 일기 작성을 모두 마친 뒤 confirmButton을 누르면 diary 객체를 생성하고 delegate에 정의한 didSelect method를 호출해서
    // method 파라미터에 생성된 diary 객체를 생성해준다
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else {return} // 작성한 제목을 가져오고 (옵셔널 바인딩)
        guard let contents = self.contentsTextView.text else {return} // 작성한 내용을 가져오고
        guard let date = self.diaryDate else {return} // date picker에서 선택된 날짜를 가져온다
        
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        // diary 객체 생성 (제목, 내용, 날짜 각각 넘겨주고, 즐겨찾기는 우선 false로 넘겨준다)
        
        self.delegate?.didSelectedRegister(diary: diary)
        // didSelectedRegister에 diary 객체를 넘겨준다
        
        self.navigationController?.popViewController(animated: true)
        // 화면이 이전 화면으로 이동되게 한다. (일기장 화면으로)
    } // 전달될 준비 마침! 이제 View controller 로 가자 
    
    // *1
    @objc private func datePickerValueDidChange(_ sender: UIDatePicker){
        let formmater = DateFormatter()
        // 날짜와 텍스트를 변환해주는 역할 (데이트 타입을 사람이 읽을 수 있도록 해주거나, 반대의 역할)
        
        formmater.dateFormat = "yyyy년 MM월 dd일 (EEEEE)"
        // 실행하면 이상한 월과 일이 떠서 대소문자 구분해서 입력해주었더니 수정되었다
        //데이트 타입을 어떤 형태로 입력할 지 포맷을 입력해준다
        //EEEEE : 요일을 한 글자만 표현하도록 함
        
        formmater.locale = Locale(identifier: "ko_KR")
        // 데이트 포맷이 한국어로 표현하도록 해준다
        
        self.diaryDate = datePicker.date
        // diaryDate 프로퍼티에 datePicker에서 선택한 date 타입을 선택
        
        formmater.timeZone = TimeZone(abbreviation: "GMT +9")
        
        self.dateTextField.text = formmater.string(from: datePicker.date)
        // 데이트를 포맷터에서 지정한 문자열로 변환시켜 date text field에 표시되도록 해준다.
        
        
        self.dateTextField.sendActions(for: .editingChanged)
        // 날짜가 변경될 때마다 editingChanged 액션을 발생시켜서
        // dateTextFieldDidChanged 메서드가 호출되게 된다
        

        
    }// 이 함수를 정의했으니 configureDatePicker() 함수의 addTarget selector로 이 함수를 넘겨준다.
    
    // configureInputField() 메서드에서 보내는 selector 정의를 위해 다음과 같이 구현한다.
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    } // 제목이 변경될 때 마다 등록버튼이 활성화되는지 여부를 판단한다
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    } // 날짜가 변경될 때 마다 등록버튼이 활성화되는지 여부를 판단한다
    
    private func configureContentsTextView(){
        let borderColor = UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 0.2)
        // border Color에 UIColor를 설정한다
        
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        // border color에 border color 상수를 넣어준다
        // layer관련된 색상 설정하는 경우 UIColor가 아닌 cgColor로 설정해야 한다
        
        self.contentsTextView.layer.borderWidth = 0.5
        // 테두리 너비
        
        self.contentsTextView.layer.cornerRadius = 5.0
        // 둥글게 설정한다.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touchesBegan()은 사용자가 빈 화면을 터치하면 호출되는 메서드
        // 키보드가 사라진다
        self.view.endEditing(true)
    }

    // *3
    // 등록버튼의 활성화 여부를 판단하는 메서드
    private func validateInputField(){
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true)
                                    && !(self.dateTextField.text?.isEmpty ?? true)
                                    && !self.contentsTextView.text.isEmpty
        // 제목의 텍스트필드가 비어있지 않고, 날짜 텍스트필드가 비어있지 않고, 내용텍스트뷰가 비어있지 않으면
        // 즉, 모든 inputField가 비어있지않으면 등록 버튼 활성화되게 한다.
    }
}

/*2*/
extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 일기장에 내용을 입력할 때마다 이 메서드가 호출됨
        // *3
        self.validateInputField()
        // 텍스트필드에 내용이 입력될 때마다 이 함수가 호출되도록 만들어서 등록버튼 활성화 여부를 판단할 수 있도록 한다
    }
}
