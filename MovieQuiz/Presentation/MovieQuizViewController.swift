import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let presenter = MovieQuizPresenter()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var correctAnswers: Int = 0
    
    
    private var questionFactory: QuestionFactoryProtocol?
    //    private var currentQuestion: QuizQuestion?
    
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        activityIndicator.startAnimating()
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader() ,delegate: self)
        questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        hideLoadingIndicator()
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // запускаем задачу через 1 секунду
            [weak self]  in
            guard let self = self else {return}
            // код, который вы хотите вызвать через 1 секунду,
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.changeButtonsStatus()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService!.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let text = "Ваш результат:\(correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов:\(statisticService!.gamesCount)\nРекорд: \(statisticService!.bestGame.correct)/\(statisticService!.bestGame.total) (\(statisticService!.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f%%", 100*statisticService!.totalAccuracy))"
            
            self.show(quiz: QuizResultsViewModel(title: "Результаты", text: text, buttonText: "Сыграть еще раз"))
        } else {
            presenter.switchToNextQuestion()
            
            // показать следующий вопрос
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        //здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let action =  {
            self.presenter.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.imageView.layer.borderWidth = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        // здесь мы показываем результат прохождения квиза
        let alert: AlertPresenter = AlertPresenter(title: result.title, message: result.text,
                                                   buttonText: result.buttonText, completion: action)
        alert.show(viewController: self)
    }
    
    func changeButtonsStatus() {
        if yesButton.isEnabled == true && noButton.isEnabled == true {
            yesButton.isEnabled = false
            noButton.isEnabled = false
        } else if yesButton.isEnabled == false && noButton.isEnabled == false {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    internal func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertPresenter(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.loadData()
        }
        
        model.show(viewController: self)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        activityIndicator.isHidden = false
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didFailToLoadImage() {
        let alert: AlertPresenter = AlertPresenter(title: "Ошибка", message: "Картинка не загружена",
                                                   buttonText: "Попробовать еще раз") {[weak self] in
            self?.questionFactory?.requestNextQuestion()
        }
        alert.show(viewController: self)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.yesButtonClicked(yesButton)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.noButtonClicked(noButton)
    }
}
