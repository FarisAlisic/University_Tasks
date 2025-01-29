from http.client import INSUFFICIENT_STORAGE
import json
import random
import sys
import time
import threading
import queue
import os

class Question:
    def __init__(self, question_data, answer):
        self.question_data = question_data
        self.answer = answer        

    def ask_question(self):
        print(self.question_data['question'])
        print(" ")
        abc = [" a) ", " b) ", " c) ", " d) ", " e) ", " f) "]
        i = 0
        j = 0
        for choices in self.question_data['choices']:
                j = j + 1
        if(j == 2):
            return 0
        else:
            for choices in self.question_data['choices']:
                print(abc[i]+choices)
                i = i + 1
            return 0
            
    def load_question(self, filename, random):
        try:
            with open(filename, 'r') as f:
                json_data = json.loads(f.read())
                
            self.question_data = json_data[random]
            self.answer = self.question_data['correctAnswer']

        except FileNotFoundError:
            print("Error: The file was not found.")
            sys.exit()

        except json.JSONDecodeError as json_error:
            print(f"Error decoding JSON.")
            sys.exit()

    def validate_question(self, answer):
        abc = ["a", "b", "c", "d", "e", "f"]
        if(answer in abc):
            i = 0
            for choices in self.question_data['choices']:
                if(choices == self.answer):
                    break
                i = i + 1
            if(abc[i]==answer): return 1
            else: return 0
        elif(answer == 'true' or answer == 'false'):
            if(answer == self.question_data['correctAnswer']):
                return 1
            else: return 0
        else:
            if(answer == self.question_data['correctAnswer']):
                return 1
            else: return 0
    def generate_report(self, correct):
        print("You have completed the quiz!")
        print(f"Number of correct answers: {correct}" )
        print(f"Number of incorrect answers: {5-correct}")
        
    def number_of_answers(self):
        i = 0
        for choices in self.question_data['choices']:
            i = i + 1
        return i


def get_valid_input(noa):
    if(noa == 0):
        try:
            user_input = input(f"Enter your answer: ").lower()
            return user_input
        except ValueError as ve:
            print(ve)
    elif(noa == 2):
        while True:
            try:
                user_input = input(f"Enter your answer: ").lower()
                if (user_input == 'true' or user_input == 'false'):
                    return user_input
                else:
                    raise ValueError("Invalid input. Please enter a valid character.")
            except ValueError as ve:
                print(ve)
    else:  
        allowed_characters = set(chr(ord('a') + i) for i in range(noa))
        while True:
            try:
                user_input = input(f"Enter your answer: ").lower()
                if user_input in allowed_characters:
                    return user_input
                else:
                    raise ValueError("Invalid input. Please enter a valid character.")
            except ValueError as ve:
                print(ve)

def ask_question_with_time(noa, timeout_seconds):
    
    def ask_a_question_internal():
        while True:
            try:
                user_input = get_valid_input(noa)
                user_queue.put(user_input)
                return
            except ValueError as ve:
                print(ve)

    user_queue = queue.Queue()
    question_thread = threading.Thread(target=ask_a_question_internal, daemon=True)
    question_thread.start()
    start_time = time.time()
    elapsed_time = 0

    while elapsed_time < timeout_seconds:
        try:
            user_input = user_queue.get(timeout=timeout_seconds - elapsed_time)
            return user_input
        except queue.Empty:
            elapsed_time = time.time() - start_time

    print("\nYou didn't answer in time!")
    time.sleep(1)
   
def write_to_file(score, difficulty, q_asked):
    with open('quiz_data.txt', 'w') as file:
        file.write(f'{score}\n')
        file.write(f'{difficulty}\n')
        string_list = [str(num) for num in q_asked]
        for num_str in string_list:
            file.write(num_str + '\n')

def read_file():
    try:
        with open('quiz_data.txt', 'r') as file:
            score = int(file.readline().strip())
            difficulty = file.readline().strip()
            numbers = [int(line.strip()) for line in file.readlines()]
            return score, difficulty, numbers
    except FileNotFoundError:
        print("File not found!")
    except Exception as e:
        print(f"An error occurred: {e}")
        
def empty_file():
    with open('quiz_data.txt', 'w') as file:
        file.write('')
        
def exit_option():
    while True:
        user_input = input("Do you want to exit the program? (yes/no): ").lower()
        if user_input == 'yes':
            print("Exiting program. Goodbye!")
            sys.exit()
        elif user_input == 'no':
            print("Continuing with the program...")
            break
        else:
            print("Invalid input. Please enter 'yes' or 'no'.")

#   Set time here
time_limit = 10
list = []
list_for_txt = []

def if_empty():
    correct_answers = 0
    for i in range(5):
        random_element = random.choice(list)
        q1 = Question(None, None)
        q1.load_question('questions.json', random_element)
        q1.ask_question()
        print(" ")
        user_input = ask_question_with_time(q1.number_of_answers(), time_limit)
        correct_answers = correct_answers + q1.validate_question(user_input)
        print(f"Number of correct answers: {correct_answers}" )
        list_for_txt.append(random_element)
        write_to_file(correct_answers, difficulty, list_for_txt)
        if (i != 4):
            exit_option()
        print(" ")
        list.remove(random_element)
    empty_file()
    return correct_answers

def not_empty():
    score, difficulty, numbers = read_file()
    correct_answers = score
    if difficulty == 'easy':
        list = list_easy
    else:
        list = list_hard
        
    filtered_list = [number for number in list if number not in numbers] #  Only leaves remaining questions

    for i in range(len(filtered_list)):
        random_element = random.choice(filtered_list)
        q1 = Question(None, None)
        q1.load_question('questions.json', random_element)
        q1.ask_question()
        print(" ")
        user_input = ask_question_with_time(q1.number_of_answers(), time_limit)
        correct_answers = correct_answers + q1.validate_question(user_input)
        print(f"Number of correct answers: {correct_answers}" )
        list_for_txt.append(random_element)
        write_to_file(correct_answers, difficulty, list_for_txt)
        if (i != len(filtered_list)):
            exit_option()
        print(" ")
        filtered_list.remove(random_element)
    empty_file()
    return correct_answers

try:
    with open('questions.json', 'r') as f:
        json_data = json.loads(f.read())
        num_questions = len(json_data)
        list_easy = []
        list_hard = []
    for i in range(num_questions):
        if(json_data[i]["difficulty"] == "hard"):
            list_hard.append(i) 
        else:
            list_easy.append(i)
except FileNotFoundError:
    print("Error: The file was not found.")
    sys.exit()
except json.JSONDecodeError as json_error:
    print(f"Error decoding JSON.")
    sys.exit()
difficulty = 's'

nb_correct_answers = 0

if os.path.exists('quiz_data.txt'):
    if os.path.getsize('quiz_data.txt') == 0:
        while True:
            try:
                difficulty = input("Choose difficulty (easy/hard): ").lower()
                if difficulty == 'easy':
                    list = list_easy
                elif difficulty == 'hard':
                    list = list_hard
                else:
                    raise ValueError("Invalid input. Please choose 'easy' or 'hard'.")
                break
            except ValueError as e:
                print(e)
        print(" ")
        nb_correct_answers=if_empty()
    else:
        nb_correct_answers=not_empty()
else:
    while True:
            try:
                difficulty = input("Choose difficulty (easy/hard): ").lower()
                if difficulty == 'easy':
                    list = list_easy
                elif difficulty == 'hard':
                    list = list_hard
                else:
                    raise ValueError("Invalid input. Please choose 'easy' or 'hard'.")
                break
            except ValueError as e:
                print(e)
            print(" ")
    nb_correct_answers=if_empty()
    

q1 = Question(None, None)
q1.generate_report(nb_correct_answers)