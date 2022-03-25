import Foundation
import UIKit

public struct EmptyCellViewModel {
	public let text: String
	public let image: UIImage?
	
	public init(text: String, image: UIImage?) {
		self.text = text
		self.image = image
	}
}

public class EmptyCell: BaseCell {
	public typealias Item = EmptyCellViewModel
	

	// MARK: - Properties
	
	public static var EstimatedHeight: CGFloat {
		// TODO: Phone size?
		return 200
	}

	private let _stackView = UIStackView()
	private let _imageView = UIImageView()
	private let _label = UILabel()


	// MARK: - Inits

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(_stackView)
		_stackView.addArrangedSubview(_imageView)
		_stackView.addArrangedSubview(_label)
	
		_stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(x(1))
		}
		
		_stackView.axis = .vertical
		_stackView.spacing = x(1)
		
		selectionStyle = .none
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError(NotImplementedError)
	}
	
	
	// MARK: - Functions
	
	public func configure(with item: EmptyCellViewModel) {
		_imageView.image = item.image
		_label.text = item.text
	}
	
	public func selected() {
	}
	
	public func deselected() {
	}
}
