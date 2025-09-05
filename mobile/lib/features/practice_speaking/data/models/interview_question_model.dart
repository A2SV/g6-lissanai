import 'package:lissan_ai/features/practice_speaking/domain/entities/interview_question.dart';

class InterviewQuestionModel extends InterviewQuestion {
  InterviewQuestionModel({required super.question});

  factory InterviewQuestionModel.fromJson(Map<String, dynamic> json){
    return InterviewQuestionModel(
      question: json['question'] ?? ''
    );
  }
  Map<String, dynamic> toJson(){
    return {'question': question};
  }
  

  }


