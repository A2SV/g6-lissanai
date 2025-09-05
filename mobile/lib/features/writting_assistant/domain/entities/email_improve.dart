class EmailCorrection {
  final String original;
  final String corrected;
  final String explanation;

  const EmailCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });
}

class EmailImprove {
  final String subject;
  final String improvedBody;
  final List<EmailCorrection> corrections;

  const EmailImprove({
    required this.subject,
    required this.improvedBody,
    this.corrections = const [],
  });
}