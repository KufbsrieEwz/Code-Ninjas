# Docs for Kahoot! project!

there are 2 parts to this project index.html + script.js in frontend folder and the backend folder

- index.html + script.js is the frond end that the students will see and use to anwser questions 
- backend will be what is displayed it will also commuicate with the clients to provide questions and answers 

## JSON Format

#### server to client
```
{
    "type": "question",
    "questionId": 1234567890,
    "questionText": "What is the capital of Canada?",
    "options": [
        {
            "optionId": "a",
            "text": "Paris"
        },
        {
            "optionId": "b",
            "text": "London"
        },
        {
            "optionId": "c",
            "text": "Berlin"
        },
        {
            "optionId": "d",
            "text": "Ottawa"
        }
    ],
    "timeLimit": 30
}
```
- type: will determine question type (for now we have 4 option multi-choice can be expanded in the future)
- questionId: will be a unique ID for every question the contruction will be X-YYY-ZZZ-III 
  - where: X is the belt the question is from (white (0) to black (8))
  - YYY is the level of the belt (1 to 8 white-belt, 1 to 10 yellow, etc)
  - ZZZ is the section in the level (Build, Debug, Quest, Adventure, etc)
  - III is a unqiue ID
- questionText: is the question being asked
- options: possible answers (one must be right)
  - optionId: used to simplify data being passed back and forth 
  - text: what the user sees the option as
- timeLimit: sets up a contdown timer on clients side

#### client to server
```
{
    "type": "answer",
    "name": "Jin Chan"
    "ninjaID": 1234567890
    "questionId": 1234567890,
    "selectedOptionId": "d",
    "timeRemaining": 25
}
```
- type: will determine question type (for now we have 4 option multi-choice can be expanded in the future)
- name: ninjas display name
- ninjaID: unique student ID
- questionId: will be a unique ID for every question the contruction will be X-YYY-ZZZ-III 
  - where: X is the belt the question is from (white (0) to black (8))
  - YYY is the level of the belt (1 to 8 white-belt, 1 to 10 yellow, etc)
  - ZZZ is the section in the level (Build, Debug, Quest, Adventure, etc)
  - III is a unqiue ID
- selectedOptionId: students anwsers
- timeRemaining: how much time was left before timer hit zero (lower is bad)

## Running the backend
1. verify node is installed 
2. in the backend folder run ```node index.js``` 
