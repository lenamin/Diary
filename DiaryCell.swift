

import UIKit

class DiaryCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
        
    required init?(coder: NSCoder) {
        // NSCoder 파라미터를 가지고 있는 생성자를 정의해준다
        // 이 생성자는 UIView가 xib나 스토리보드에서 생성될 때 이 생성자를 통해 객체가 생성된다
        super.init(coder: coder)
        
        // 셀의 테두리를 그려준다
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.darkGray.cgColor
    }
}
