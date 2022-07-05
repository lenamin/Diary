

import UIKit

class StarViewController: UIViewController {
    // 탭바에서 즐겨찾기만 모아보기 step 1 : outlet 변수 정의하기
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 탭바에서 즐겨찾기만 모아보기 step 2 : diaryList 프로퍼티 초기화
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // 탭바에서 즐겨찾기만 모아보기 step 4 : StarViewController로 이동할 때마다 즐겨찾기 된 일기들을 불러온다 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadStarDiaryList()
    }
    
    // 탭바에서 즐겨찾기만 모아보기 step 3 : 즐겨찾기 일기들을 가져오기
    private func loadStarDiaryList() {
        let userDefaults = UserDefaults.standard // userDefaults에 접근
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String : Any]] else { return } // guard 문으로 옵셔널 바인딩
        // object 메서드는 Any 타입으로 리턴되므로 dictionary 배열로 타입캐스팅 해줘야 함
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
            // Diary 타입이 되도록 인스턴스화를 해준다
        }.filter({ // 불러온 diaryList를 filter 함수에 넣어서 isStar가 true인 일기만 필터링한다
            $0.isStar == true
        }).sorted(by: { // 그 중에서 날짜가 최신순으로 정렬되도록 한다
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }

}
