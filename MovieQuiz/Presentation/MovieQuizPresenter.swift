import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticService?
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(), // распаковываем картинку
            question: model.text, // берём текст вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
    }
    
    func yesButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        viewController?.changeButtonsStatus()
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
    
     func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                let text = "Ваш результат:\(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов:\(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f%%", 100*statisticService.totalAccuracy))"
                
                viewController?.show(quiz: QuizResultsViewModel(title: "Результаты", text: text, buttonText: "Сыграть еще раз"))
            }
        } else {
            self.switchToNextQuestion()
            
            // показать следующий вопрос
            viewController?.questionFactory?.requestNextQuestion()
        }
    }
    
}
