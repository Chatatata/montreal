import UIKit

class QuestionMasterTableViewController: UITableViewController {
  var clientConfiguration = ClientConfiguration.shared
  
  //  MARK: - Data
  
  var question: Question!
  
  //  MARK: - View state handling
  
  var visibleOptions: [(Int, Question.Option)] {
    return question
      .options
      .filter { !eliminatedOptions.contains($0) }
      .map { option in
        return (question.options.firstIndex(of: option)!, option)
    }
  }
  
  var eliminatedOptions = [Question.Option]() {
    didSet {
      do {
        reloadOptionsSection()
      }
    }
  }
  
  var markedOption: Question.Option? = nil {
    didSet {
      guard markedOption != nil else {
        return
      }
      
      tableView.selectRow(at: nil,
                          animated: false,
                          scrollPosition: .none)
    }
  }
  
  var selectedOption: Question.Option? {
    guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
      return nil
    }
    
    return visibleOptions[indexPathForSelectedRow.row].1;
  }
  
  var questionHeight: CGFloat? = nil
  var optionHeights = [Question.Option : CGFloat]()
  
  //  MARK: - Bar button items
  
  var submitBarButtonItem: UIBarButtonItem! = {
    let barButtonItem = UIBarButtonItem(title: NSLocalizedString("Submit", comment: "Submits the answer of the question as selected option."),
                                        style: .done,
                                        target: nil,
                                        action: nil)
    
    barButtonItem.isEnabled = false
    
    return barButtonItem
  }()
  
  //  MARK: - View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    
    let titleView = QuestionMasterNavigationBarTitleView(frame: .zero)
    titleView.contextLabel.text = "Lorem ipsum"
    titleView.identifierLabel.text = "#712374"
    
    navigationItem.titleView = titleView
    
    navigationController!.setToolbarHidden(false, animated: true)
    toolbarItems = [
      UIBarButtonItem(title: NSLocalizedString("Skip", comment: "Skips the current question."), style: .plain, target: nil, action: nil),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      submitBarButtonItem
    ]
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController!.setToolbarHidden(true, animated: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    RenderSizeCache.shared.flush()
  }
  
  // MARK: - UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return visibleOptions.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
      let cell = tableView.dequeueReusableCell(withIdentifier: QuestionContentTableViewCell.identifier, for: indexPath) as! QuestionContentTableViewCell
      
      cell.question = question
      cell.delegate = self
      
      return cell
    }
    
    if (indexPath.section == 1) {
      let cell = tableView.dequeueReusableCell(withIdentifier: OptionContentTableViewCell.identifier, for: indexPath) as! OptionContentTableViewCell
      let (_, option) = visibleOptions[indexPath.row]
      
      cell.option = option
      cell.delegate = self
      cell.setSelected(option == selectedOption, animated: false)
      cell.setMarked(option == markedOption, animated: false)
      
      return cell
    }
    
    fatalError("Section not handled.")
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return NSLocalizedString("Question", comment: "Notes the content as the body of the question.")
    case 1:
      return NSLocalizedString("Options", comment: "Notes the content as the body of the options.")
    default:
      return nil
    }
  }
  
  //  MARK: - UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if indexPath.section == 1 {
      let cell = tableView.cellForRow(at: indexPath)!
      
      if cell.isSelected {
        cell.setSelected(false, animated: false)
        
        return nil
      }
    }
    
    return indexPath
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let precalculated = super.tableView(tableView, heightForRowAt: indexPath)
    let offset: CGFloat = 48.00
    
    switch indexPath.section {
    case 0:
      if let height = questionHeight {
        return height + offset
      }
      
      return precalculated
    case 1:
      if let height = optionHeights[question.options[indexPath.row]] {
        return height + offset
      }
      
      return precalculated
    default:
      return precalculated
    }
  }
  
  //  MARK: - Convenience methods
  
  func reloadOptionsSection() {
    tableView.reloadSections(IndexSet(integer: 1),
                             with: .none)
    
    if let selectedRowIndex = visibleOptions.map({ $0.1 }).firstIndex(of: selectedOption) {
      tableView.selectRow(at: IndexPath(row: selectedRowIndex, section: 1),
                          animated: false,
                          scrollPosition: .none)
    }
  }
  
  //  MARK: - Unwind segues
  
  @IBAction func unwindToQuestionMasterTableViewController(segue: UIStoryboardSegue) {
    //  Empty implementation
  }
}
