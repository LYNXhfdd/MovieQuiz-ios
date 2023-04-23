import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        app = XCUIApplication()
        app.launch()
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testExample() throws {
        
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testYesButton(){
        sleep(3)
        let firstPoster = app.images["Poster"] // Находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap() // Находим кнопку 'Да' и нажимаем её
        sleep(3)
        let secondPoster = app.images["Poster"] // снова находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)   // сравниваем постеры
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    func testNoButton(){
        sleep(3)
        let firstPoster = app.images["Poster"] // Находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap() // Находим кнопку 'Да' и нажимаем её
        sleep(3)
        let secondPoster = app.images["Poster"] // снова находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)   // сравниваем постеры
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish(){
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Результаты"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Результаты")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
        
    }
    
    func testAlertDismiss(){
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        let alert = app.alerts["Результаты"]
        alert.buttons.firstMatch.tap()
        sleep(2)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
    
    
}
