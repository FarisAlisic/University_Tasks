using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

class Questions
{
    public string Question { get; set; }
    public List<string> Choices { get; set; }
    public string CorrectAnswer { get; set; }
}

class Program
{
    static int correctAnswers = 0;

    static void AskQuestion(Questions questionData)
    {
        Console.WriteLine(questionData.Question);
        Console.WriteLine(" ");

        string[] abc = { " a) ", " b) ", " c) ", " d) ", " e) ", " f) " };
        int i = 0;

        var choices = questionData.Choices;
        
        while (i < choices.Count)
        {
            Console.WriteLine(abc[i] + choices[i]);
            i++;
        }
    }

    static Questions LoadQuestion(string fileName, int random)
    {
        try
        {
            //The json file has to be in a specific place if it can not be loaded by name, code to load by path:
            
            //string jsonFilePath = filePath;
            //string jsonString = File.ReadAllText(jsonFilePath);

            StreamReader read = new StreamReader(fileName);
            string jsonString = read.ReadToEnd();

            Questions[] questions = JsonConvert.DeserializeObject<Questions[]>(jsonString);

            return questions[random];
           
        }
        catch (FileNotFoundException)
        {
            Console.WriteLine("Error: The file was not found.");
            Environment.Exit(1);
        }
        catch (System.Text.Json.JsonException)
        {
            Console.WriteLine("Error decoding JSON. Please check if the JSON file is correctly formatted.");
            Environment.Exit(1);
        }
        catch (IndexOutOfRangeException e)
        {
            Console.WriteLine(e.Message);
            Environment.Exit(1);
        }
        return null!;
    }

    
    static int ValidateQuestion(Questions questionData, string userAnswer)
    {
        string[] abc = { "a", "b", "c", "d", "e", "f" };
        int i = 0;

        var choices = questionData.Choices;

        while (i < choices.Count)
        {
            if (choices[i] == questionData.CorrectAnswer)
            {
                break;
            }
            i++;
        }

        if (abc[i] == userAnswer)
        {
            return 1;
        }
        else
        {
            return 0;
        }

    }

    static void GenerateReport()
    {
        Console.WriteLine("You have completed the quiz!");
        Console.WriteLine($"Number of correct answers: {correctAnswers}");
        Console.WriteLine($"Number of incorrect answers: {5 - correctAnswers}");
    }
    
    static int NumberOfAnswers(Questions questionData)
    {
        int[] abc = { 0, 0, 0, 0, 4, 5, 6 };
        int i = 3;

        
        var choices = questionData.Choices;

        while (i < choices.Count)
        {
            i++;
        }
        return abc[i];
    }

    static string GetValidInput(int noa)
    {
        List<char> allowedCharacters = new List<char>();

        for (int i = 0; i < noa; i++)
        {
            allowedCharacters.Add((char)('a' + i));
        }

        while (true)
        {
            try
            {

                Console.Write("Enter your answer: ");
                string? userInput = Console.ReadLine().ToLower();

                if (!string.IsNullOrEmpty(userInput) && userInput.Length == 1 && char.IsLetter(userInput[0]))
                //Checks if the input is a not null, is just one letter and is an actual letter, if all conditions true than proceeded to next if.
                {
                    if (allowedCharacters.Contains(userInput[0]))
                    //In this if it checks if the letter is the one in range of the number of allowed letters
                    {
                        return userInput;
                }
                else
                {
                    throw new Exception("Invalid input. Please enter a valid character.");
                }
            }
                else
                {
                    throw new Exception("Invalid input. Please enter a valid character.");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }
    }
    
    static void Main()
    {
        

        List<int> questionList = new List<int> { 0, 1, 2, 3, 4 };
        Random random = new Random();
        for (int i = 0; i < 5; i++)
        {
            int randomElement = questionList[random.Next(questionList.Count)];
            Questions questionData = LoadQuestion("questions.json", randomElement);
            //The json file has to be in a specific place if it can not be loaded by name, code to load by path:
            //Questions questionData = LoadQuestion(@"YourPath", randomElement);
            if (questionData != null)
            {
                AskQuestion(questionData);
                Console.WriteLine(" ");
                string userInput = GetValidInput(NumberOfAnswers(questionData));
                Console.WriteLine(" ");
                correctAnswers += ValidateQuestion(questionData, userInput);
                questionList.Remove(randomElement);
            }
        }

        GenerateReport();
    }
}
