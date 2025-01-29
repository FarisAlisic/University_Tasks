const fs = require('fs');
const readlineSync = require('readline-sync');

class Question {
    constructor(questionData, answer) {
        this.questionData = questionData;
        this.answer = answer;
    }

    askQuestion() {
        console.log(this.questionData.question);
        console.log(" ");

        const abc = [" a) ", " b) ", " c) ", " d) ", " e) ", " f) "];
        let i = 0;
        let j = 0;
        for (let choices of this.questionData.choices) {
            j = j + 1;
        }
        if (j === 2) {
            return 0;
        } else {
            for (const choices of this.questionData.choices) {
                console.log(abc[i] + choices);
                i++;
            }
        }
    }

    loadQuestion(fileName, random) {
        try {
            const jsonData = JSON.parse(fs.readFileSync(fileName, 'utf8'));
            this.questionData = jsonData[random];
            this.answer = this.questionData.correctAnswer;
        } catch (error) {
            if (error.code === 'ENOENT') {
                console.log("Error: The file was not found.");
                process.exit(1);
            } else {
                console.log("Error decoding JSON.");
                process.exit(1);
            }
        }
    }

    validateQuestion(userAnswer) {
        const abc = ["a", "b", "c", "d", "e", "f"];
        if(abc.includes(userAnswer)){
            let i = 0;
            for (const choices of this.questionData.choices) {
                if (choices === this.answer) {
                    break;
                }
                i++;
            }
            return abc[i] === userAnswer ? 1 : 0;
        }
        else if (userAnswer === 'true' || userAnswer === 'false') {
            return userAnswer === this.questionData.correctAnswer ? 1 : 0;
        } else {
            return userAnswer === this.questionData.correctAnswer ? 1 : 0;
        }
    }

    generateReport(correctAnswers) {
        console.log("You have completed the quiz!");
        console.log(`Number of correct answers: ${correctAnswers}`);
        console.log(`Number of incorrect answers: ${5 - correctAnswers}`);
    }

    numberOfAnswers() {
        let i = 0;
        for (const choices in this.questionData.choices) {
            i++;
        }
        return i;
    }
}

function getValidInput(noa) {
    if (noa === 0) {
        try {
            while (true) {
                try {
                    user_input = readlineSync.question("Enter your answer: ").toLowerCase();
            
                    if (user_input.length < 3) {
                        throw new Error("Please enter a word. ");
                    }
                    return user_input;
                } catch (error) {
                    console.error(error.message);
                }
            }
        } catch (ve) {
            console.log(ve);
        }
    } else if (noa === 2) {
        while (true) {
            try {
                let user_input = readlineSync.question("Enter your answer: ").toLowerCase();
                if (user_input === 'true' || user_input === 'false') {
                    return user_input;
                } else {
                    console.log("Invalid input. Please enter a valid character.");
                }
            } catch (ve) {
                console.log(ve);
            }
        }
    } else {
        const letters = "abcdef";
        const allowedCharacters = letters.slice(0, noa);
        while (true) {
            try {
                const userInput = readlineSync.question("Enter your answer: ").toLowerCase();
                const validLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
                if (userInput !== null && userInput.length === 1 && validLetters.includes(userInput)) {
                if (allowedCharacters.includes(userInput)) {
                    return userInput;
                } else {
                    throw new Error("Invalid input. Please enter a valid character.");
                }
            } else {
                console.log("Invalid input. Please enter a single letter.");
            }
            } catch (error) {
                console.log(error.message);
            }
        }
    }
}

function askQuestionWithTime(noa, timeoutSeconds) {
    
    let elapsed = 0;
    const startTime = Date.now();

    let answer = getValidInput(noa);
    elapsed = Date.now() - startTime;
    //  I tried to use threads as in python and C# but it is not possible in JS, 
    //  there are som other methods but I gave up :( , so I just made a simple 
    //  function where if the time runs out, after the answer it just does 
    //  not count the points even if the answer was right.
    if(elapsed < timeoutSeconds * 1000){
    return answer;
    }
    else{
    console.log('\nYou didn\'t answer in time!');}
  }

function writeToFile(score, difficulty, qAsked) {
    const data = `${score}\n${difficulty}\n${qAsked.join('\n')}\n`;
    fs.writeFileSync('quiz_data.txt', data);
}

function readFromFile() {
    try {
        const data = fs.readFileSync('quiz_data.txt', 'utf-8');
        const lines = data.trim().split('\n');
        const score = parseInt(lines[0]);
        const difficulty = lines[1];
        const numbers = lines.slice(2).map(line => parseInt(line));
        return { score, difficulty, numbers };
    } catch (error) {
        console.log(`An error occurred: ${error}`);
    }
}

function exitOption() {
    while (true) {
        const userInput = readlineSync.question("Do you want to exit the program? (yes/no): ").toLowerCase();
        if (userInput === 'yes') {
            console.log("Exiting program. Goodbye!");
            process.exit();
        } else if (userInput === 'no') {
            console.log("Continuing with the program...");
            break;
        } else {
            console.log("Invalid input. Please enter 'yes' or 'no'.");
        }
    }
}

function emptyFile() {
    fs.writeFileSync('quiz_data.txt', '');
}
//  Set time here:
const timeLimit = 3;
console.log(`You have ${timeLimit} seconds to answer each question.`);

let list = [];
let listForTxt = [];

function ifEmpty() {
    let correctAnswers = 0;
    for (let i = 0; i < 5; i++) {
        const randomElement = getRandomElement(list);
        const q1 = new Question();
        q1.loadQuestion('questions.json', randomElement);
        q1.askQuestion();
        console.log(" ");
        const userInput = askQuestionWithTime(q1.numberOfAnswers(), timeLimit);
        correctAnswers += q1.validateQuestion(userInput);
        console.log(`Number of correct answers: ${correctAnswers}`);
        listForTxt.push(randomElement);
        writeToFile(correctAnswers, difficulty, listForTxt);
        if (i !== 4) {
            exitOption();
        }
        console.log(" ");
        removeElement(list, randomElement);
    }
    emptyFile();
    return correctAnswers;
}

function notEmpty() {
    const { score, difficulty, numbers } = readFromFile();
    let correctAnswers = score;
    let list;

    if (difficulty === 'easy') {
        list = list_easy;
    } else {
        list = list_hard;
    }

    const filteredList = list.filter(number => !numbers.includes(number));

    for (let i = 0; i < filteredList.length; i++) {
        const randomElement = getRandomElement(filteredList);
        const q1 = new Question();
        q1.loadQuestion('questions.json', randomElement);
        q1.askQuestion();
        console.log(" ");
        const userInput = askQuestionWithTime(q1.numberOfAnswers(), timeLimit);
        correctAnswers += q1.validateQuestion(userInput);
        console.log(`Number of correct answers: ${correctAnswers}`);
        listForTxt.push(randomElement);
        writeToFile(correctAnswers, difficulty, listForTxt);
        if (i !== filteredList.length - 1) {
            exitOption();
        }
        console.log(" ");
        removeElement(filteredList, randomElement);
    }
    emptyFile();
    return correctAnswers;
}

const list_easy = [];
const list_hard = [];

try {
    const jsonData = JSON.parse(fs.readFileSync('questions.json', 'utf8'));
    const numQuestions = jsonData.length;

    for (let i = 0; i < numQuestions; i++) {
        if (jsonData[i]["difficulty"] === "hard") {
            list_hard.push(i);
        } else {
            list_easy.push(i);
        }
    }
} catch (error) {
    console.log("Error: The file was not found or there was an error decoding JSON.");
    process.exit();
}

let difficulty = 's';
let nbCorrectAnswers = 0;

if (fs.existsSync('quiz_data.txt')) {
    if (fs.statSync('quiz_data.txt').size === 0) {
        while (true) {
            try {
                difficulty = readlineSync.question("Choose difficulty (easy/hard): ").toLowerCase();
                if (difficulty === 'easy') {
                    list = list_easy;
                } else if (difficulty === 'hard') {
                    list = list_hard;
                } else {
                    throw new Error("Invalid input. Please choose 'easy' or 'hard'.");
                }
                break;
            } catch (error) {
                console.log(error.message);
            }
        }
        console.log(" ");
        nbCorrectAnswers = ifEmpty();
    } else {
        nbCorrectAnswers = notEmpty();
    }
} else {
    while (true) {
        try {
            difficulty = readlineSync.question("Choose difficulty (easy/hard): ").toLowerCase();
            if (difficulty === 'easy') {
                list = list_easy;
            } else if (difficulty === 'hard') {
                list = list_hard;
            } else {
                throw new Error("Invalid input. Please choose 'easy' or 'hard'.");
            }
            break;
        } catch (error) {
            console.log(error.message);
        }
        console.log(" ");
    }
    nbCorrectAnswers = ifEmpty();
}

const q1 = new Question();
q1.generateReport(nbCorrectAnswers);

function getRandomElement(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
}

function removeElement(arr, element) {
    const index = arr.indexOf(element);
    if (index !== -1) {
        arr.splice(index, 1);
    }
}

