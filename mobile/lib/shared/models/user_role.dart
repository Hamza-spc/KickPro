enum UserRole {
  player('PLAYER'),
  scout('SCOUT'),
  admin('ADMIN'),
  agent('AGENT');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole fromApi(String value) {
    return UserRole.values.firstWhere(
      (role) => role.apiValue == value,
      orElse: () => UserRole.player,
    );
  }
}
