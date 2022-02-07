

import UIKit

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker() // UIDatePicker 인스턴스로 초기화
    private var diaryDate: Date? // 데이트 피커에 선택된 데이트를 저장하는 프로퍼티
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView() // 아래에서 만든 configureContentsTextView() 함수를 호출한다
        self.configureDatePicker()
        self.confirmButton.isEnabled = false
            // 제목, 내용, 날짜에 아무것도 작성 안된 경우인 경우니까 등록버튼을 비활성화되도록 만들어준다.
        self.configureInputField()
    }
    
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date
        // 날짜만 나오도록 설정한다
        
        self.datePicker.preferredDatePickerStyle = .wheels
        
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        // UIController 객체가 이벤트에 응답하는 방식을 설정해주는 메서드
        // 첫 번째 파라미터 : targer (해당 컨트롤러에서 처리할 거니까 self)
        // 두 번째 파라미터 : action (이벤트가 발생했을 때 응답하여 호출될 메서드를 selector로 넘겨준다. 이에 넘겨줄 메서드 별도로 만들어야 한다. -> datePickerValueDidChange()메서드 넘겨주기)
        // 세 번째 파라미터 : 어떤 이벤트가 일어났을 때 액션에 정의한 메서드를 호출할 것인지 설정한다 (값이 변경될 때 date Picker did change 메서드를 호출한다
        
        self.dateTextField.inputView = self.datePicker // text field를 선택했을 때 키보드가 뜨는 것이 아닌 datePicker가 뜬다

    }
    
    private func configureInputField(){
        self.contentsTextView.delegate = self // UITextViewDelegate를 채택해야 한다
        
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        // 제목 텍스트필드에 텍스트가 입력될 때마다 selector가 받아온 메서드를 호출한다
        
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
        // 날짜가 변경될 때마다 selector가 받아온 메서드를 호출한다
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
        let formmater = DateFormatter()
        // 날짜와 텍스트를 변환해주는 역할 (데이트 타입을 사람이 읽을 수 있도록 해주거나, 반대의 역할)
        
        formmater.dateFormat = "YYYY년 MM월 DD일 (EEEEE)"
        //데이트 타입을 어떤 형태로 입력할 지 포맷을 입력해준다
        //EEEEE : 요일을 한 글자만 표현하도록 함
        
        formmater.locale = Locale(identifier: "ko_KR")
        // 데이트 포맷이 한국어로 표현하도록 해준다
        
        self.diaryDate = datePicker.date
        // diaryDate 프로퍼티에 datePicker에서 선택한 date 타입을 선택
        
        self.dateTextField.text = formmater.string(from: datePicker.date)
        // 데이트를 포맷터에서 지정한 문자열로 변환시켜 date text field에 표시되도록 해준다.
        
        
        self.dateTextField.sendActions(for: .editingChanged)
        // 날짜가 변경될 때마다 editingChanged 액션을 발생시켜서
        // dateTextFieldDidChanged 메서드가 호출되게 된다
        
        
    }// 이 함수를 정의했으니 configureDatePicker() 함수의 addTarget selector로 이 함수를 넘겨준다.
    
    // configureInputField() 메서드에서 보내는 selector 정의를 위해 다음과 같이 구현한다.
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func configureContentsTextView(){
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
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
        // touchesBegan()은 사용자가 화면을 터치하면 호출되는 메서드
        self.view.endEditing(true)
        
    }

    private func validateInputField(){
        self.confirmButton.isEnabled =
        !(self.titleTextField.text?.isEmpty ?? true)
        && !(self.dateTextField.text?.isEmpty ?? true)
        && !self.contentsTextView.text.isEmpty
        // 제목의 텍스트필드가 비어있지 않고, 날짜 텍스트필드가 비어있지 않고, 내용텍스트뷰가 비어있지 않으면
        // 즉, 모든 inputField가 비어있지않으면 등록 버튼 활성화되게 한다.
    }
}

extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 일기장에 내용을 입력할 때마다 호출함
        
        self.validateInputField()
        // 텍스트필드에 내용이 입력될 때마다 이 함수가 호출되도록 만들어서 등록버튼 활성화 여부를 판단할 수 있도록 한다
    }
}
