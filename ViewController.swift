import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Diary 타입의 비어있는 배열로 초기화한다
    // diaryList 프로퍼티를 프로퍼티 옵저버로 만든다 (UserDefaults 때문)
    private var diaryList = [Diary](){
        didSet { // didSet 될 때
            self.saveDiaryList()
            // diaryList 배열에 일기가 추가되거나 변경될 때마다 userDefaults 에 저장된다.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // 좌우위아래 간격을 10으로 준다
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // protocol을 채택하고 필수 메서드를 채택하러 가보자
    }
    
    // segue 통해 이동하므로 prepare 메서드를 오버라이드 한다
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self // Delegate를 위임받는다
        }
            // segue 로 이동되는 View Controller가 뭔지 알 수 있게 한다
    }
    
    // 일기들을 userDefaults에 딕셔너리 배열 형태로 저장한다
    private func saveDiaryList(){
        let date = self.diaryList.map { // 배열에 있는 요소들을 딕셔너리 형태로 매핑 시켜준다
            [
                "title": $0.title, // 딕셔너리 title key에 다이어리의 title이 저장되도록 한다.
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard // UserDefaults에 접근한다
        userDefaults.set(date, forKey: "diaryList") // 첫 번째 파라미터 -> 일기가 저장되어 있는 날짜를 넘겨주고 / 두 번째 파라미터에는 배열 이름을 넘겨준다
    }
    
    // 이제 저장된 값을 불러오자
    private func loadDiaryList(){
        let userDefaults = UserDefaults.standard // UserDefaults 에 접근한다
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else {return}
        // 일기장 리스트를 가져온다
        // object 메서드는 any 타입으로 리턴되므로 딕셔너리 배열 형태로 타입 캐스팅을 해준다
        // 타입캐스팅 실패 시 nil이 될 수 있으므로 guard 문으로 옵셔널 바인딩까지 해준 코드이다
        
        // 불러온 데이터를 diaryList에 넣어준다 (diary 타입이 되게 매핑 시켜준다)
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else {return nil}
            // 축약인자로 딕셔너리에 접근하고 title 키로 딕셔너리 value를 가져온다
            // 딕셔너리 밸류가 any 타입이므로 string으로 타입 변환 해준 것
            // 타입 캐스팅 실패할 경우 대비해 guard 문으로 옵셔널 바인딩 한 것
            // 아래도 모두 동일
            guard let contents = $0["contents"] as? String else {return nil}
            guard let date = $0["date"] as? Date else {return nil}
            guard let isStar = $0["isStar"] as? Bool else {return nil}
            
            return Diary(title: title, contents: contents, date: date, isStar: false)
            // Diary 타입이 되게 인스턴스화 한다
        }
        
        // 일기를 불러올 때 날짜를 최신순으로 정렬되도록 한다
        // 고차함수 sort() 이용
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending // 내림차순으로 정렬되게
                // 배열에 왼쪽과 오른쪽 날짜를 iteration 돌면서 비교
                // 왼쪽 값과 오른쪽 값을 비교한다
        })
    }
    
    // date 타입을 전달받으면 문자열 포맷으로 전달해주는 함수
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter() // dateFormatter() 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        // 데이터포맷이 한국어로 표시되도록
        return formatter.string(from:date)
    }
}

extension ViewController: UICollectionViewDataSource {

    // Collection View로 보여주는 데이터소스들을 관리하는 객체
    // 필수 메서드부터 구현해보자
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 지정된 섹션에 표시할 셀의 갯수를 표시한다
        // diaryList 배열의 갯수만큼 표시되게 한다.
        return self.diaryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // collection View 지정된 위치에 표시할 셀을 요청하는 메서드
        // table view에서 cell for row at 메서드와 동일한 역할을 한다
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell()}
        // 스토리보드에서 구성한 커스텀 셀을 가져오기 위해 (재사용할 셀을 가져온다)
        // -> withReuseIdentifier 에 커스텀셀의 identifier 값인 DiaryCell 넣어준것.
        // Diary Cell로 다운캐스팅 해준것
        // 다운캐스팅에 실패하면 UICollectionViewCell이 빈 상태로 반환되도록 해준다.
        
        // 이제 재사용한 셀이 일기의 제목과 날짜가 표시되도록 하자.
        let diary = self.diaryList[indexPath.row]
        
        // 일기가 저장되어 있는 배열에서 일기를 가져오자
        cell.titleLabel.text = diary.title // 제목 가져오기
        
        // cell.dateLabel.text = diary.date라고 입력하면 오류가 뜬다
        // diary instance에 있는 date는 date type으로 되어 있으므로
        // date formatter를 이용해 문자열로 만들어준다
        // date타입을 전달받으면 문자열로 만들어주는 메서드를 만들어주러 위로 가보자! (dateToString())
        
        cell.dateLabel.text = self.dateToString(date: diary.date)
        // 위에서 구현한 dateToString 메서드를 가져와 date 가 문자열로 표시되게 한다
        return cell
        // collection view에 일기장 목록 표시할 준비 완료
    }
}

extension ViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
    // 셀의 사이즈를 설정하는 역할
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //didSelectItemAt : 특정 셀이 선택되었음을 알려주는 메서드
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return}
        let diary = self.diaryList[indexPath.row] //선택한 일기가 무엇인지 diary 상수에 대입한다
        viewController.diary = diary
        viewController.indexPath = indexPath
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
        // 일기장 상세화면이 푸쉬되게 한다
    } //DiaryDetailViewController가 푸쉬되도록 구현한다
}

extension ViewController: WriteDiaryViewDelegate{
    func didSelectedRegister(diary: Diary) {
        self.diaryList.append(diary) // 일기 작성화면에서 등록될 때마다 diary 배열에 추가되게 된다
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending // 내림차순으로 정렬되게
                // 배열에 왼쪽과 오른쪽 날짜를 iteration 돌면서 비교
                // 왼쪽 값과 오른쪽 값을 비교한다
        })
        self.collectionView.reloadData() // 일기를 추가할 때마다 collection view에 일기목록이 표시되게 된다
    }
}

extension ViewController : DiaryDetailViewDelegate {
    func didSelectDelete(indexPath: IndexPath) {
        self.diaryList.remove(at: indexPath.row) // row값에 있는 배열의 요소를 삭제한다
        self.collectionView.deleteItems(at: [indexPath])
    }
}
