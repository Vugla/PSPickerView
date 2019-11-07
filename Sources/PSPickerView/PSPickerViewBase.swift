//
//  File.swift
//  
//
//  Created by Predrag Samardzic on 30/10/2019.
//

import UIKit

public class PSPickerViewBase: UIView {
    public typealias PSPickerViewCallback = (_ madeChoice: Bool) -> Void
    
    public var toolbarHeight: CGFloat = 44 {
        didSet {
            toolbarHeightConstraint?.constant = toolbarHeight
        }
    }
    public var pickerHeight: CGFloat = 260 {
        didSet {
            pickerViewHeightConstraint?.constant = pickerHeight
        }
    }
    public var pickerBackgroundColor: UIColor? {
        didSet {
            pickerView.backgroundColor = pickerBackgroundColor
        }
    }
    public var cancelButton = UIButton() {
        didSet {
            buttonsStackView.removeArrangedSubview(oldValue)
            oldValue.removeFromSuperview()
            buttonsStackView.addArrangedSubview(cancelButton)
        }
    }
    public var doneButton = UIButton() {
        didSet {
            buttonsStackView.removeArrangedSubview(oldValue)
            oldValue.removeFromSuperview()
            buttonsStackView.insertArrangedSubview(doneButton, at: 0)
        }
    }
    public var backgroundView: UIView = UIView() {
        didSet {
            oldValue.removeFromSuperview()
            addBackgroundViewToViewHierarchy()
        }
    }
    public var toolbar: UIView = UIView() {
        didSet {
            oldValue.removeFromSuperview()
            addToolbarToViewHierarchy()
        }
    }
    
    private lazy var pickerView: UIView = {
        return customPicker()
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        doneButton.setTitle(NSLocalizedString("Done", comment: "Title for done button in PSPickerView"), for: .normal)
        doneButton.tintColor = tintColor
        doneButton.addTarget(self, action: #selector(onDone(sender:)), for: .touchUpInside)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Title for cancel button in PSPickerView"), for: .normal)
        cancelButton.tintColor = tintColor
        cancelButton.addTarget(self, action: #selector(onCancel(sender:)), for: .touchUpInside)
        let spacingView = UIView()
        spacingView.backgroundColor = .clear
        spacingView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [doneButton, spacingView, cancelButton])
        stackView.axis = .horizontal
        return stackView
    }()
    
    private var pickerViewBottomConstraint: NSLayoutConstraint?
    private var pickerViewHeightConstraint: NSLayoutConstraint?
    private var toolbarHeightConstraint: NSLayoutConstraint?
    
    internal func customPicker() -> UIView {
        fatalError("Fatal error - has to be implemented in subclasses")
    }
    
    public func present(in view:UIView, callback:@escaping PSPickerViewCallback) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        backgroundView.alpha = 0
        pickerViewBottomConstraint?.constant = -pickerHeight
        setNeedsLayout()
        
        pickerViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundView.alpha = 1
            self.setNeedsLayout()
        })
    }
    
    public func presentInWindowWithBlock(callback: @escaping PSPickerViewCallback) {
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            present(in: window, callback: callback)
        } else {
            fatalError("There is no window!")
        }
    }

    @objc public func onDone(sender: AnyObject) {
        dismiss()
    }
    
    @objc public func onCancel(sender: AnyObject) {
        dismiss()
    }
    
    public func dismiss() {
        pickerViewBottomConstraint?.constant = -pickerHeight
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundView.alpha = 0
            self.setNeedsLayout()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .clear
        if #available(iOS 13.0, *) {
            pickerView.backgroundColor = .tertiarySystemBackground
        } else {
            pickerView.backgroundColor = .white
        }
        addPickerToViewHierarchy()
        
        setupDefaultToolBar()
        addToolbarToViewHierarchy()
        
        setupDefaultBackgroundView()
        addBackgroundViewToViewHierarchy()
    }
    
    private func addPickerToViewHierarchy() {
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        
        if #available(iOS 11.0, *) {
            pickerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
            pickerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        
        pickerViewHeightConstraint? = pickerView.heightAnchor.constraint(equalToConstant: pickerHeight)
        pickerViewHeightConstraint?.isActive = true
        
        pickerViewBottomConstraint = pickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        pickerViewBottomConstraint?.isActive = true
    }
    
    private func addToolbarToViewHierarchy() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbar)
        
        toolbarHeightConstraint = toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
        toolbarHeightConstraint?.isActive = true
        
        toolbar.bottomAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
        
        toolbar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupDefaultToolBar() {
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(buttonsStackView)
        
        if #available(iOS 13.0, *) {
            toolbar.backgroundColor = UIColor.secondarySystemBackground
        } else {
            toolbar.backgroundColor = .white
        }
        
        buttonsStackView.topAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
        buttonsStackView.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            buttonsStackView.leadingAnchor.constraint(equalTo: toolbar.safeAreaLayoutGuide.leadingAnchor).isActive = true
            buttonsStackView.trailingAnchor.constraint(equalTo: toolbar.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            buttonsStackView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor).isActive = true
            buttonsStackView.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor).isActive = true
        }
    }
    
    private func addBackgroundViewToViewHierarchy() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        sendSubviewToBack(backgroundView)
    }
    
    private func setupDefaultBackgroundView() {
        if #available(iOS 13.0, *) {
            backgroundView.backgroundColor = UIColor.tertiarySystemFill
        } else {
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        let tap = UIGestureRecognizer(target: self, action: #selector(onCancel(sender:)))
        backgroundView.addGestureRecognizer(tap)
    }
}

