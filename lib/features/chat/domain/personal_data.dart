class PersonalDataPayload {
  const PersonalDataPayload({
    this.vacationDays,
    this.sickLeaveDays,
    this.salaryDate,
    this.dmsPrograms,
    this.probationEndDate,
    this.nextDate,
  });

  final int? vacationDays;
  final int? sickLeaveDays;
  final DateTime? salaryDate;
  final List<String>? dmsPrograms;
  final DateTime? probationEndDate;
  final DateTime? nextDate;

  bool get hasVacation => vacationDays != null;
  bool get hasSickLeave => sickLeaveDays != null;
  bool get hasSalary => salaryDate != null;
  bool get hasDms => dmsPrograms != null && dmsPrograms!.isNotEmpty;
  bool get hasProbation => probationEndDate != null;

  Map<String, dynamic> toJson() => {
        'vacation_days': vacationDays,
        'sick_leave_days': sickLeaveDays,
        'salary_date': salaryDate?.toIso8601String(),
        'dms_programs': dmsPrograms,
        'probation_end_date': probationEndDate?.toIso8601String(),
        'next_date': nextDate?.toIso8601String(),
      };

  static PersonalDataPayload fromJson(Map<String, dynamic> json) =>
      PersonalDataPayload(
        vacationDays: json['vacation_days'] as int?,
        sickLeaveDays: json['sick_leave_days'] as int?,
        salaryDate: json['salary_date'] != null
            ? DateTime.tryParse(json['salary_date'] as String)
            : null,
        dmsPrograms: (json['dms_programs'] as List?)?.cast<String>(),
        probationEndDate: json['probation_end_date'] != null
            ? DateTime.tryParse(json['probation_end_date'] as String)
            : null,
        nextDate: json['next_date'] != null
            ? DateTime.tryParse(json['next_date'] as String)
            : null,
      );
}