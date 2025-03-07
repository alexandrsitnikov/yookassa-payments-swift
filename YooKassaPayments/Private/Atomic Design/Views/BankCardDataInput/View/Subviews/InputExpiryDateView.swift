import UIKit
@_implementationOnly import YooMoneyUI

protocol InputExpiryDateViewDelegate: AnyObject {
    func expiryDateDidChange(_ value: String)
    func expiryDateDidBeginEditing()
    func expiryDateDidEndEditing()
}

final class InputExpiryDateView: UIControl {

    // MARK: - InputExpiryDateViewDelegate

    weak var delegate: InputExpiryDateViewDelegate?

    // MARK: - Public accessors

    var hint: String? {
        get {
            expiryDateHintLabel.text
        }
        set {
            expiryDateHintLabel.styledText = newValue
        }
    }

    override var isSelected: Bool {
        didSet {
            guard !isError else { return }

            if isSelected {
                expiryDateHintLabel.textColor = Constants.LabelHintColor.selected
            } else {
                expiryDateHintLabel.textColor = Constants.LabelHintColor.normal
            }
        }
    }

    var isError: Bool = false {
        didSet {
            if isError {
                expiryDateHintLabel.textColor = Constants.LabelHintColor.error
            } else {
                expiryDateHintLabel.textColor = isSelected
                ? Constants.LabelHintColor.selected
                : Constants.LabelHintColor.normal
            }
        }
    }

    var text: String? {
        get {
            expiryDateTextField.text
        }
        set {
            expiryDateTextField.text = inputPresenter
                .style
                .appendedFormatting(
                to: newValue ?? ""
            )
        }
    }

    var placeholder: String? {
        get {
            expiryDateTextField.placeholder
        }
        set {
            expiryDateTextField.placeholder = newValue
        }
    }

    // MARK: - UI properties

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var expiryDateHintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.Styles.singleLine
        )
        return view
    }()

    private(set) lazy var expiryDateTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(UITextField.Styles.numeric)
        view.delegate = self
        return view
    }()

    // MARK: - Input presenter

    private lazy var inputPresenter: InputPresenter = {
        let textInputStyle = ExpiryDateInputPresenterStyle()
        let inputPresenter = InputPresenter(
            textInputStyle: textInputStyle
        )
        inputPresenter.output = expiryDateTextField
        return inputPresenter
    }()

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - SetupView

    private func setupView() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            verticalStackView,
        ].forEach(addSubview)
        [
            expiryDateHintLabel,
            expiryDateTextField,
        ].forEach(verticalStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            verticalStackView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            verticalStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            verticalStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            verticalStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),

            expiryDateTextField.heightAnchor.constraint(equalToConstant: 30),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITextFieldDelegate

extension InputExpiryDateView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        inputPresenter.input(
            changeCharactersIn: range,
            replacementString: string,
            currentString: expiryDateTextField.text ?? ""
        )
        let value = inputPresenter.style.removedFormatting(
            from: expiryDateTextField.text ?? ""
        )
        delegate?.expiryDateDidChange(value)
        return false
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        delegate?.expiryDateDidBeginEditing()
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.expiryDateDidEndEditing()
    }
}

private extension InputExpiryDateView {
    enum Constants {
        enum LabelHintColor {
            static let error = UIColor.YKSdk.redOrange
            static let normal = UIColor.YKSdk.ghost
            static let selected = UIColor.YKSdk.secondary
        }
    }
}
