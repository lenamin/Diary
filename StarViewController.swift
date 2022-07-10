

import UIKit

class StarViewController: UIViewController {
    // 탭바에서 즐겨찾기만 모아보기 step 1 : outlet 변수 정의하기
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 탭바에서 즐겨찾기만 모아보기 step 2 : diaryList 프로퍼티 초기화
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadStarDiaryList()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil)
    }
    
    /// 탭바에서 즐겨찾기만 모아보기 step 4 : StarViewController로 이동할 때마다 즐겨찾기 된 일기들을 불러온다
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter() // dateFormatter() 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR") // 데이터포맷이 한국어로 표시되도록
        return formatter.string(from: date)
    }
    
    /// 컬렉션뷰에 즐겨찾기 내용 나타내기 step 1
    private func configureCollectionView() {
        // collectionView를 코드로 UI를 구성하기 위해, UICollectionViewFlowLayout 인스턴스를 대입시켜 준다
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    /// 탭바에서 즐겨찾기만 모아보기 step 3 : 즐겨찾기 일기들을 가져오기
    private func loadStarDiaryList() {
        let userDefaults = UserDefaults.standard // userDefaults에 접근
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String : Any]] else { return } // guard 문으로 옵셔널 바인딩
        // object 메서드는 Any 타입으로 리턴되므로 dictionary 배열로 타입캐스팅 해줘야 함
        self.diaryList = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(
                uuidString: uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: isStar)
            // Diary 타입이 되도록 인스턴스화를 해준다
        }.filter({ // 불러온 diaryList를 filter 함수에 넣어서 isStar가 true인 일기만 필터링한다
            $0.isStar == true
        }).sorted(by: { // 그 중에서 날짜가 최신순으로 정렬되도록 한다
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString}) else { return }
        self.diaryList[index] = diary // 수정된 내용 대입
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending // 최신 순 정렬
        })
        self.collectionView.reloadData()
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let diary = starDiary["diary"] as? Diary else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }

        if isStar {
            self.diaryList.append(diary)
            self.diaryList = self.diaryList.sorted(by: {
                $0.date.compare($1.date) == .orderedDescending // 최신 순 정렬
            })
            self.collectionView.reloadData()
        } else {
            guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString}) else { return }
            self.diaryList.remove(at: index)
            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString}) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
}

// 컬렉션뷰에 즐겨찾기 내용 나타내기 step 2 : 필수 메서드 구현하기
extension StarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row] // 배열에 저장되어 있는 Row값을 가져온다
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

extension StarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
}

extension StarViewController: UICollectionViewDelegate {
    /// 즐겨찾기 탭에서 해당 일기를 누르면 해당 일기 화면으로 이동한다
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
