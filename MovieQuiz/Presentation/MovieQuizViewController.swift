import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    //MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    let alertPresenter = AlertPresenter()
     var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.startAnimating()
    }
    
    // MARK: - UI
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки не скрыт
    }
    
    func makeButtonsInactive() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        yesButton.setTitleColor(UIColor.ypGray, for: .normal)
        noButton.setTitleColor(UIColor.ypGray, for: .normal)
    }
    
    func makeButtonsActive() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        yesButton.setTitleColor(UIColor.black, for: .normal)
        noButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    func highlightImageBorder(isCorrectAnswer:Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        makeButtonsInactive()
    }
    
    func turnOffHighlighting() {
        imageView.layer.borderWidth = 0
    }
    
    
    
    
    // MARK: - Alerts and Errors
    func showAlert(model: AlertModel){
        alertPresenter.show(in: self, model: model)
    }
    
    
    func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") {[weak self] in
            guard let self = self else { return }
            self.presenter.resetGame()
            
        }
        self.showAlert(model: alertModel)
    }
    
    
    // MARK: - Screen
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    //MARK: - Actions
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
}
