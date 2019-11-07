import UIKit

public class PSPickerView: PSPickerViewBase {
    public typealias PSPickerViewOptionView = (_ reusedView: UIView?, _ index: Int) -> UIView
    
    private var customOptionView: PSPickerViewOptionView?
    private var numberOfOptions: Int = 0
    private var values: [String]?
    private var indexSelectedBeforeDismissal:Int?
    
    public var selectedIndex:Int = 0
    
    public init(values: [String]) {
        super.init(frame: CGRect.zero)
        self.values = values
    }
    
    public init(numberOfOptions: Int, customOptionView: @escaping PSPickerViewOptionView) {
        super.init(frame: CGRect.zero)
        self.numberOfOptions = numberOfOptions
        self.customOptionView = customOptionView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customPicker() -> UIView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        pickerView.selectRow(selectedIndex, inComponent:0, animated:false)
        indexSelectedBeforeDismissal = selectedIndex
        return pickerView
    }
    
    override public func onDone() {
        if let indexBeforeDismiss = indexSelectedBeforeDismissal {
            selectedIndex = indexBeforeDismiss
        }
        super.onDone()
    }
}

extension PSPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values?.count ?? numberOfOptions
    }
    
    //  Picker View Delegate
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let customOptionView = customOptionView?(view, row) else {
            let label = (view as? UILabel) ?? UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.text =  values?[row]
            label.textAlignment = .center
            return label
        }
        return customOptionView
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexSelectedBeforeDismissal = row
    }
}
