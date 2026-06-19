enum TargetSkill { dribbling, shooting, passing, speed, heading, stamina }

extension TargetSkillApi on TargetSkill {
  String get apiValue => name.toUpperCase();

  static TargetSkill fromApi(String value) {
    return TargetSkill.values.firstWhere(
      (skill) => skill.apiValue == value,
      orElse: () => TargetSkill.dribbling,
    );
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}
