import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegete
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didFailToLoadImage() {
        let model = AlertModel(title: "Ошибка", message:  "Картинка не загружена", buttonText: "Попробовать еще раз") {[weak self] in
            guard let self = self else { return }
            self.questionFactory?.requestNextQuestion()
            
        }
        self.viewController?.showAlert(model: model)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.hideLoadingIndicator()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isYes:Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        
        let totalPlaysCountLine = "Количество сыгранных квизов:\(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат:\(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f%%", 100*statisticService!.totalAccuracy))"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            let text = self.makeResultsMessage()
            
            self.show(quiz: QuizResultsViewModel(title: "Результаты", text: text, buttonText: "Сыграть ещё раз"))
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
            viewController?.turnOffHighlighting()
            viewController?.makeButtonsActive()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        // здесь мы показываем результат прохождения квиза
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) {[weak self] in
            guard let self = self else { return }
            self.resetGame()
            self.correctAnswers = 0
            self.viewController?.turnOffHighlighting()
            self.questionFactory?.requestNextQuestion()
            self.viewController?.makeButtonsActive()
            
        }
        self.viewController?.showAlert(model: model)
    }
    
    
    private func proceedWithAnswer(isCorrect: Bool) {
        correctAnswers += isCorrect ? 1 : 0
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }

}
